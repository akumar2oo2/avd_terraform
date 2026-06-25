# =============================================================================
# PORTAL DASHBOARD
# =============================================================================

output "dashboard_id" {
  description = "ID of the AVD insights portal dashboard (null when disabled)."
  value       = var.enable_dashboards ? azurerm_portal_dashboard.avd_insights[0].id : null
}

output "dashboard_name" {
  description = "Name of the AVD insights portal dashboard (null when disabled)."
  value       = var.enable_dashboards ? azurerm_portal_dashboard.avd_insights[0].name : null
}

# =============================================================================
# ACTION GROUP
# =============================================================================

output "cost_action_group_id" {
  description = "ID of the cost alerts action group (null when disabled)."
  value       = var.enable_cost_alerts ? azurerm_monitor_action_group.cost_alerts[0].id : null
}

output "cost_action_group_name" {
  description = "Name of the cost alerts action group (null when disabled)."
  value       = var.enable_cost_alerts ? azurerm_monitor_action_group.cost_alerts[0].name : null
}

# =============================================================================
# CONSUMPTION BUDGET
# =============================================================================

output "consumption_budget_id" {
  description = "ID of the consumption budget (null when disabled)."
  value       = var.enable_cost_alerts ? azurerm_consumption_budget_resource_group.avd_budget[0].id : null
}

output "consumption_budget_amount" {
  description = "Monthly budget amount."
  value       = var.enable_cost_alerts ? azurerm_consumption_budget_resource_group.avd_budget[0].amount : null
}