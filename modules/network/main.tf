# =============================================================================
# LOCAL VALUES — Names & Tags
# =============================================================================
# Centralized resource naming and tag merging for consistency across the module.
locals {
  names = {
    rg   = format("rg-%s-%s-network", var.prefix, var.environment)
    nsg  = format("nsg-%s-%s", var.prefix, var.environment)
    vnet = format("vnet-%s-%s", var.prefix, var.environment)
    snet = format("snet-%s-%s", var.prefix, var.environment)
  }

  default_tags = {
    environment = var.environment
    prefix      = var.prefix
    created_by  = "terraform"
  }
  tags = merge(local.default_tags, var.tags)
}

# =============================================================================
# RESOURCE GROUP
# =============================================================================
# Dedicated resource group for all network resources (VNet, Subnet, NSG).
resource "azurerm_resource_group" "network" {
  name     = local.names.rg
  location = var.location
  tags     = var.enhanced_tags
}

# =============================================================================
# NETWORK SECURITY GROUP
# =============================================================================
# NSG attached to the AVD subnet — controls inbound/outbound traffic rules.
resource "azurerm_network_security_group" "network" {
  name                = local.names.nsg
  location            = azurerm_resource_group.network.location
  resource_group_name = azurerm_resource_group.network.name
  tags                = local.tags
}

# =============================================================================
# VIRTUAL NETWORK
# =============================================================================
# Virtual network that hosts the AVD subnet for session hosts.
resource "azurerm_virtual_network" "network" {
  name                = local.names.vnet
  location            = azurerm_resource_group.network.location
  resource_group_name = azurerm_resource_group.network.name
  address_space       = var.vnet_address_space
  tags                = local.tags
}

# =============================================================================
# SUBNET (AVD)
# =============================================================================
# Subnet used by session host NICs. Address prefix comes from variable directly.
resource "azurerm_subnet" "network" {
  name                 = local.names.snet
  resource_group_name  = azurerm_resource_group.network.name
  virtual_network_name = azurerm_virtual_network.network.name
  address_prefixes     = var.subnet_address_prefix
}

# =============================================================================
# SUBNET <-> NSG ASSOCIATION
# =============================================================================
# Binds the NSG to the AVD subnet so its rules apply to all session host NICs.
resource "azurerm_subnet_network_security_group_association" "network" {
  subnet_id                 = azurerm_subnet.network.id
  network_security_group_id = azurerm_network_security_group.network.id
}

# =============================================================================
# CLEANUP: NetworkWatcherRG (auto-created by Azure)
# =============================================================================
# Azure auto-creates "NetworkWatcherRG" in the same region as the first VNet.
# Terraform doesn't manage it, so it's left behind on destroy. This block
# deletes it during `terraform destroy` only when delete_network_watcher_rg = true.
resource "null_resource" "delete_network_watcher_rg" {
  count = var.delete_network_watcher_rg ? 1 : 0

  triggers = {
    location = var.location
  }

  provisioner "local-exec" {
    when       = destroy
    command    = "az group delete --name NetworkWatcherRG --yes --no-wait || echo 'NetworkWatcherRG not found or already deleted'"
    on_failure = continue
  }

  depends_on = [
    azurerm_virtual_network.network
  ]
}