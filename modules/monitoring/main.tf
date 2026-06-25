# =============================================================================
# LOCAL VALUES — Tags
# =============================================================================
# Tag merging for consistency across all monitoring resources in this module.
locals {
  default_tags = {
    environment = var.environment
    prefix      = var.prefix
    created_by  = "terraform"
  }
  tags = merge(local.default_tags, var.tags)
}

# =============================================================================
# LOG ANALYTICS WORKSPACE
# =============================================================================
# Central Log Analytics workspace that collects all logs and metrics from AVD
# control-plane resources and session hosts. Retention is configurable via
# variable, and the SKU is PerGB2018 (modern pay-as-you-go pricing).
resource "azurerm_log_analytics_workspace" "avd_monitoring" {
  name                = "law-${var.prefix}-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "PerGB2018"
  retention_in_days   = var.monitoring_retention_days
  tags                = local.tags
}

# =============================================================================
# DATA COLLECTION RULE — AVD SESSION HOSTS
# =============================================================================
# Defines what data Azure Monitor Agent collects from each session host. This
# safe baseline collects core Windows performance counters and standard Windows
# event logs first. Additional AVD-specific counters can be added later.
resource "azurerm_monitor_data_collection_rule" "avd_session_hosts" {
  name                = "dcr-avd-${var.prefix}-${var.environment}-sessionhosts"
  resource_group_name = var.resource_group_name
  location            = var.location
  kind                = "Windows"
  description         = "Collects Windows events and performance counters from AVD session hosts."

  destinations {
    log_analytics {
      name                  = "log-analytics-destination"
      workspace_resource_id = azurerm_log_analytics_workspace.avd_monitoring.id
    }
  }

  data_sources {
    performance_counter {
      name                          = "windows-performance-counters"
      streams                       = ["Microsoft-Perf"]
      sampling_frequency_in_seconds = 60

      counter_specifiers = [
        "\\Processor(_Total)\\% Processor Time",
        "\\Memory\\Available MBytes",
        "\\LogicalDisk(_Total)\\% Free Space"
      ]
    }

    windows_event_log {
      name    = "windows-event-logs"
      streams = ["Microsoft-Event"]

      x_path_queries = [
        "Application!*[System[(Level=1 or Level=2 or Level=3)]]",
        "System!*[System[(Level=1 or Level=2 or Level=3)]]"
      ]
    }
  }

  data_flow {
    streams      = ["Microsoft-Perf"]
    destinations = ["log-analytics-destination"]
  }

  data_flow {
    streams      = ["Microsoft-Event"]
    destinations = ["log-analytics-destination"]
  }

  tags = local.tags
}

# =============================================================================
# DIAGNOSTIC SETTING — HOST POOL
# =============================================================================
# Sends all AVD host pool logs (Connection, HostRegistration, Checkpoint,
# Error, Management, etc.) to the Log Analytics workspace. Uses category_group
# "allLogs" so new categories are automatically included as Azure adds them.
resource "azurerm_monitor_diagnostic_setting" "avd_host_pool" {
  name                       = "diag-${var.host_pool_name}"
  target_resource_id         = var.host_pool_id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.avd_monitoring.id

  enabled_log {
    category_group = "allLogs"
  }
}

# =============================================================================
# DIAGNOSTIC SETTING — WORKSPACE
# =============================================================================
# Sends all AVD workspace logs (Checkpoint, Error, Management, Feed) to the
# Log Analytics workspace. Required for AVD Insights workspace data.
resource "azurerm_monitor_diagnostic_setting" "avd_workspace" {
  name                       = "diag-${var.workspace_name}"
  target_resource_id         = var.workspace_id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.avd_monitoring.id

  enabled_log {
    category_group = "allLogs"
  }
}

# =============================================================================
# DIAGNOSTIC SETTING — APPLICATION GROUP
# =============================================================================
# Sends all AVD application group logs (Checkpoint, Error, Management) to the
# Log Analytics workspace. Required for AVD Insights application group data.
resource "azurerm_monitor_diagnostic_setting" "avd_application_group" {
  name                       = "diag-${var.application_group_name}"
  target_resource_id         = var.application_group_id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.avd_monitoring.id

  enabled_log {
    category_group = "allLogs"
  }
}