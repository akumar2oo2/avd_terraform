# =============================================================================
# LOG ANALYTICS WORKSPACE
# =============================================================================

output "log_analytics_workspace_id" {
  description = "ID of the Log Analytics workspace."
  value       = azurerm_log_analytics_workspace.avd_monitoring.id
}

output "log_analytics_workspace_name" {
  description = "Name of the Log Analytics workspace."
  value       = azurerm_log_analytics_workspace.avd_monitoring.name
}

output "log_analytics_workspace_resource_id" {
  description = "Full Azure Resource ID of the Log Analytics workspace."
  value       = azurerm_log_analytics_workspace.avd_monitoring.id
}

output "log_analytics_primary_shared_key" {
  description = "Primary shared key (use only when required)."
  value       = azurerm_log_analytics_workspace.avd_monitoring.primary_shared_key
  sensitive   = true
}

output "log_analytics_workspace_customer_id" {
  description = "Workspace customer ID (GUID)."
  value       = azurerm_log_analytics_workspace.avd_monitoring.workspace_id
}

# =============================================================================
# DATA COLLECTION RULE
# =============================================================================

output "data_collection_rule_id" {
  description = "ID of the AVD session host Data Collection Rule (used by session-hosts module)."
  value       = azurerm_monitor_data_collection_rule.avd_session_hosts.id
}

output "data_collection_rule_name" {
  description = "Name of the AVD session host DCR."
  value       = azurerm_monitor_data_collection_rule.avd_session_hosts.name
}

# =============================================================================
# DIAGNOSTIC SETTINGS
# =============================================================================

output "host_pool_diagnostic_id" {
  description = "ID of the host pool diagnostic setting."
  value       = azurerm_monitor_diagnostic_setting.avd_host_pool.id
}

output "workspace_diagnostic_id" {
  description = "ID of the AVD workspace diagnostic setting."
  value       = azurerm_monitor_diagnostic_setting.avd_workspace.id
}

output "application_group_diagnostic_id" {
  description = "ID of the application group diagnostic setting."
  value       = azurerm_monitor_diagnostic_setting.avd_application_group.id
}