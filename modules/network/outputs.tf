# =============================================================================
# RESOURCE GROUP
# =============================================================================

output "resource_group_name" {
  description = "Name of the network resource group."
  value       = azurerm_resource_group.network.name
}

output "resource_group_id" {
  description = "ID of the network resource group."
  value       = azurerm_resource_group.network.id
}

output "location" {
  description = "Azure region of the network."
  value       = azurerm_resource_group.network.location
}

# =============================================================================
# VIRTUAL NETWORK
# =============================================================================

output "vnet_id" {
  description = "ID of the virtual network."
  value       = azurerm_virtual_network.network.id
}

output "vnet_name" {
  description = "Name of the virtual network."
  value       = azurerm_virtual_network.network.name
}

output "vnet_address_space" {
  description = "Address space of the virtual network."
  value       = azurerm_virtual_network.network.address_space
}

# =============================================================================
# SUBNET
# =============================================================================

output "subnet_id" {
  description = "ID of the AVD subnet (used by session-hosts module)."
  value       = azurerm_subnet.network.id
}

output "subnet_name" {
  description = "Name of the AVD subnet."
  value       = azurerm_subnet.network.name
}

output "subnet_address_prefixes" {
  description = "Address prefixes of the AVD subnet."
  value       = azurerm_subnet.network.address_prefixes
}