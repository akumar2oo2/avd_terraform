# =============================================================================
# SCALING PLAN
# =============================================================================

output "scaling_plan_id" {
  description = "ID of the AVD scaling plan."
  value       = azurerm_virtual_desktop_scaling_plan.this.id
}

output "scaling_plan_name" {
  description = "Name of the AVD scaling plan."
  value       = azurerm_virtual_desktop_scaling_plan.this.name
}

output "scaling_plan_time_zone" {
  description = "Time zone configured for the scaling plan."
  value       = azurerm_virtual_desktop_scaling_plan.this.time_zone
}

# =============================================================================
# HOST POOL ASSOCIATION
# =============================================================================

output "scaling_plan_host_pool_association_id" {
  description = "ID of the scaling plan to host pool association."
  value       = azurerm_virtual_desktop_scaling_plan_host_pool_association.this.id
}

# =============================================================================
# AVD SERVICE PRINCIPAL ROLE ASSIGNMENT
# =============================================================================

output "scaling_plan_role_assignment_id" {
  description = "ID of the role assignment granting AVD SP power-on/off permissions."
  value       = azurerm_role_assignment.scaling_plan.id
}

output "avd_service_principal_object_id" {
  description = "Object ID of the AVD service principal used by scaling plan."
  value       = data.azuread_service_principal.avd.object_id
}