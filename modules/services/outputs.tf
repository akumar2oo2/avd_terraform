# =============================================================================
# RESOURCE GROUP
# =============================================================================

output "resource_group_name" {
  description = "Name of the AVD services resource group."
  value       = azurerm_resource_group.services.name
}

output "resource_group_id" {
  description = "ID of the AVD services resource group."
  value       = azurerm_resource_group.services.id
}

# =============================================================================
# HOST POOL
# =============================================================================

output "host_pool_id" {
  description = "ID of the AVD host pool."
  value       = azurerm_virtual_desktop_host_pool.services.id
}

output "host_pool_name" {
  description = "Name of the AVD host pool."
  value       = azurerm_virtual_desktop_host_pool.services.name
}

output "host_pool_type" {
  description = "Type of the AVD host pool (Pooled / Personal)."
  value       = azurerm_virtual_desktop_host_pool.services.type
}

# =============================================================================
# APPLICATION GROUP
# =============================================================================

output "application_group_id" {
  description = "ID of the AVD application group."
  value       = azurerm_virtual_desktop_application_group.services.id
}

output "application_group_name" {
  description = "Name of the AVD application group."
  value       = azurerm_virtual_desktop_application_group.services.name
}

# =============================================================================
# WORKSPACE
# =============================================================================

output "workspace_id" {
  description = "ID of the AVD workspace."
  value       = azurerm_virtual_desktop_workspace.services.id
}

output "workspace_name" {
  description = "Name of the AVD workspace."
  value       = azurerm_virtual_desktop_workspace.services.name
}

# =============================================================================
# REGISTRATION TOKEN (sensitive)
# =============================================================================

output "registration_token" {
  description = "Registration token for session host enrolment."
  value       = azurerm_virtual_desktop_host_pool_registration_info.services.token
  sensitive   = true
}

output "registration_expiration_date" {
  description = "Expiration date of the registration token."
  value       = azurerm_virtual_desktop_host_pool_registration_info.services.expiration_date
}