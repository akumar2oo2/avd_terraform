# =============================================================================
# NETWORK
# =============================================================================

output "network_resource_group" {
  description = "Network resource group name."
  value       = module.network.resource_group_name
}

output "vnet_id" {
  description = "Virtual network ID."
  value       = module.network.vnet_id
}

output "subnet_id" {
  description = "AVD subnet ID."
  value       = module.network.subnet_id
}

# =============================================================================
# AVD SERVICES (CORE)
# =============================================================================

output "services_resource_group" {
  description = "AVD services resource group name."
  value       = module.services.resource_group_name
}

output "host_pool_name" {
  description = "AVD host pool name."
  value       = module.services.host_pool_name
}

output "host_pool_id" {
  description = "AVD host pool ID."
  value       = module.services.host_pool_id
}

output "workspace_name" {
  description = "AVD workspace name."
  value       = module.services.workspace_name
}

output "application_group_name" {
  description = "AVD application group name."
  value       = module.services.application_group_name
}

# =============================================================================
# SESSION HOSTS
# =============================================================================

output "session_host_resource_group" {
  description = "Session host resource group name."
  value       = module.session_hosts.resource_group_name
}

output "session_host_vm_names" {
  description = "Session host VM names."
  value       = module.session_hosts.vm_names
}

output "session_host_count" {
  description = "Total number of session hosts deployed."
  value       = module.session_hosts.session_host_count
}

# =============================================================================
# MONITORING
# =============================================================================

output "log_analytics_workspace_id" {
  description = "Log Analytics workspace ID (null if monitoring disabled)."
  value       = var.enable_monitoring ? module.monitoring[0].log_analytics_workspace_id : null
}

output "log_analytics_workspace_name" {
  description = "Log Analytics workspace name (null if monitoring disabled)."
  value       = var.enable_monitoring ? module.monitoring[0].log_analytics_workspace_name : null
}

output "data_collection_rule_id" {
  description = "Data Collection Rule ID for AVD session hosts (null if monitoring disabled)."
  value       = var.enable_monitoring ? module.monitoring[0].data_collection_rule_id : null
}

# =============================================================================
# SCALING
# =============================================================================

output "scaling_plan_id" {
  description = "AVD scaling plan ID (null if scaling disabled)."
  value       = length(module.scaling) > 0 ? module.scaling[0].scaling_plan_id : null
}

output "scaling_plan_name" {
  description = "AVD scaling plan name (null if scaling disabled)."
  value       = length(module.scaling) > 0 ? module.scaling[0].scaling_plan_name : null
}

# =============================================================================
# DASHBOARD
# =============================================================================

output "dashboard_id" {
  description = "Portal dashboard ID (null if disabled)."
  value       = length(module.dashboard) > 0 ? module.dashboard[0].dashboard_id : null
}

output "cost_action_group_id" {
  description = "Cost alerts action group ID (null if disabled)."
  value       = length(module.dashboard) > 0 ? module.dashboard[0].cost_action_group_id : null
}

# =============================================================================
# DEPLOYMENT SUMMARY
# =============================================================================

output "deployment_summary" {
  description = "Quick summary of the deployment."
  value = {
    environment     = var.environment
    location        = var.location
    deployment_type = var.deployment_type
    session_hosts   = var.session_host_count
    monitoring      = var.enable_monitoring
    scaling         = var.enable_scaling_plans
    cost_alerts     = var.enable_cost_alerts
    dashboards      = var.enable_dashboards
  }
}