# =============================================================================
# RESOURCE GROUP
# =============================================================================

output "resource_group_name" {
  description = "Name of the session host resource group."
  value       = azurerm_resource_group.session_host.name
}

output "resource_group_id" {
  description = "ID of the session host resource group."
  value       = azurerm_resource_group.session_host.id
}

# =============================================================================
# VIRTUAL MACHINES
# =============================================================================

output "vm_ids" {
  description = "List of session host VM IDs."
  value       = azurerm_windows_virtual_machine.session_host[*].id
}

output "vm_names" {
  description = "List of session host VM names."
  value       = azurerm_windows_virtual_machine.session_host[*].name
}

output "vm_computer_names" {
  description = "List of computer names registered to the AVD host pool."
  value       = azurerm_windows_virtual_machine.session_host[*].computer_name
}

output "vm_principal_ids" {
  description = "System-assigned identity object IDs of session host VMs."
  value       = azurerm_windows_virtual_machine.session_host[*].identity[0].principal_id
  sensitive   = true
}

# =============================================================================
# NETWORK INTERFACES
# =============================================================================

output "nic_ids" {
  description = "List of session host NIC IDs."
  value       = azurerm_network_interface.session_host[*].id
}

output "nic_private_ips" {
  description = "Private IP addresses of session hosts."
  value       = azurerm_network_interface.session_host[*].private_ip_address
}

# =============================================================================
# SESSION HOST COUNT
# =============================================================================

output "session_host_count" {
  description = "Number of session hosts deployed."
  value       = length(azurerm_windows_virtual_machine.session_host)
}