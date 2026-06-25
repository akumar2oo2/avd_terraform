# =============================================================================
# LOCAL VALUES — Tags
# =============================================================================
# Tag merging for consistency across all dashboard and cost alert resources.
locals {
  default_tags = {
    environment = var.environment
    prefix      = var.prefix
    created_by  = "terraform"
  }
  tags = merge(local.default_tags, var.tags)
}

# =============================================================================
# ACTION GROUP — Cost Alerts
# =============================================================================
# Defines the notification target for cost alerts. Sends email notifications to
# the configured cost admin address whenever budget thresholds are breached.
resource "azurerm_monitor_action_group" "cost_alerts" {
  count               = var.enable_cost_alerts ? 1 : 0
  name                = "ag-cost-${var.prefix}-${var.environment}"
  resource_group_name = var.resource_group_name
  short_name          = "cost-alerts"
  tags                = local.tags

  email_receiver {
    name                    = "cost-admin"
    email_address           = var.cost_alert_email
    use_common_alert_schema = true
  }
}

# =============================================================================
# CONSUMPTION BUDGET — AVD Resource Group
# =============================================================================
# Monthly spending budget scoped to the AVD services resource group. Triggers
# email + action group notifications at 90% and 100% of the threshold. Budget
# period rolls automatically from the first day of the current month.
resource "azurerm_consumption_budget_resource_group" "avd_budget" {
  count             = var.enable_cost_alerts ? 1 : 0
  name              = "budget-${var.prefix}-${var.environment}"
  resource_group_id = var.resource_group_id

  amount     = var.cost_alert_threshold
  time_grain = "Monthly"

  time_period {
    start_date = "${substr(timestamp(), 0, 7)}-01T00:00:00Z"
    end_date   = "${tonumber(substr(timestamp(), 0, 4)) + 1}-12-31T23:59:59Z"
  }

  notification {
    enabled        = true
    threshold      = 90.0
    operator       = "GreaterThan"
    contact_emails = [var.cost_alert_email]
    contact_groups = [azurerm_monitor_action_group.cost_alerts[0].id]
  }

  notification {
    enabled        = true
    threshold      = 100.0
    operator       = "GreaterThan"
    contact_emails = [var.cost_alert_email]
    contact_groups = [azurerm_monitor_action_group.cost_alerts[0].id]
  }
}

# =============================================================================
# PORTAL DASHBOARD — AVD Insights
# =============================================================================
# Creates a custom Azure portal dashboard with key AVD metrics rendered from
# the dashboard.tpl template. Includes session counts, performance counters,
# and cost data wired to the Log Analytics workspace and host pool.
resource "azurerm_portal_dashboard" "avd_insights" {
  count               = var.enable_dashboards ? 1 : 0
  name                = "dashboard-${var.prefix}-${var.environment}"
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = local.tags

  dashboard_properties = templatefile("${path.module}/dashboard.tpl", {
    workspace_id     = var.log_analytics_workspace_id
    host_pool_id     = var.host_pool_id
    resource_group   = var.resource_group_name
    environment      = var.environment
    deployment_type  = var.deployment_type
    refresh_interval = var.dashboard_refresh_interval
  })
}