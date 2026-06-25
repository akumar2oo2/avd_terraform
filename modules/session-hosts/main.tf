# =============================================================================
# LOCAL VALUES — Names & Tags
# =============================================================================
# Centralized resource naming and tag merging for consistency across the module.
locals {
  names = {
    rg = format("rg-%s-%s-session_host", var.prefix, var.environment)
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
# Dedicated resource group for all session host resources (VMs, NICs, OS disks,
# and extensions).
resource "azurerm_resource_group" "session_host" {
  name     = local.names.rg
  location = var.location
  tags     = var.enhanced_tags
}

# =============================================================================
# ROLE DEFINITION LOOKUP — Virtual Machine User Login
# =============================================================================
# Reads the built-in "Virtual Machine User Login" role used in the role
# assignment below. This role lets users sign in to session host VMs.
data "azurerm_role_definition" "virtual_machine_user_login" {
  name = "Virtual Machine User Login"
}

# =============================================================================
# ROLE ASSIGNMENT — User/Group Login on Session Hosts
# =============================================================================
# Grants each AAD object in var.security_principal_object_ids the "Virtual
# Machine User Login" role on the session host resource group, enabling them
# to sign in to session host VMs using their Entra ID credentials.
resource "azurerm_role_assignment" "session_host_login" {
  for_each           = toset(var.security_principal_object_ids)
  scope              = azurerm_resource_group.session_host.id
  role_definition_id = data.azurerm_role_definition.virtual_machine_user_login.id
  principal_id       = each.value
}

# =============================================================================
# NETWORK INTERFACES
# =============================================================================
# One NIC is created per session host with accelerated networking enabled.
# Each NIC is attached to the AVD subnet with a dynamic private IP.
resource "azurerm_network_interface" "session_host" {
  count               = var.session_host_count
  name                = format("nic-%s-%s-%02d", var.prefix, var.environment, count.index + 1)
  location            = azurerm_resource_group.session_host.location
  resource_group_name = azurerm_resource_group.session_host.name

  ip_configuration {
    name                          = "ipconfig"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
  }

  accelerated_networking_enabled = true
  tags                           = local.tags
}

# =============================================================================
# SESSION HOST VIRTUAL MACHINES
# =============================================================================
# Windows VMs provisioned for each session host. System-assigned managed
# identity is enabled, Trusted Launch (Secure Boot + vTPM) is on, and the
# Windows_Client license type complies with AVD licensing.
resource "azurerm_windows_virtual_machine" "session_host" {
  count                 = var.session_host_count
  name                  = format("vm-%s-%s-%02d", var.prefix, var.environment, count.index + 1)
  resource_group_name   = azurerm_resource_group.session_host.name
  location              = azurerm_resource_group.session_host.location
  size                  = var.vm_size
  admin_username        = var.admin_username
  admin_password        = var.admin_password
  computer_name         = format("avd-%s-%s-%02d", var.prefix, var.environment, count.index + 1)
  network_interface_ids = [element(azurerm_network_interface.session_host[*].id, count.index)]
  license_type          = "Windows_Client"
  tags                  = local.tags

  os_disk {
    name                 = format("osdisk-%s-%s-%02d", var.prefix, var.environment, count.index + 1)
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsDesktop"
    offer     = "office-365"
    sku       = var.marketplace_gallery_image_sku
    version   = "latest"
  }

  secure_boot_enabled = true
  vtpm_enabled        = true

  identity {
    type = "SystemAssigned"
  }
}

# =============================================================================
# GUEST ATTESTATION EXTENSION
# =============================================================================
# Enables Trusted Launch integrity monitoring on each session host. No
# protected settings are required for this extension.
resource "azurerm_virtual_machine_extension" "guest_attestation" {
  count                      = var.session_host_count
  name                       = "GuestAttestation"
  virtual_machine_id         = azurerm_windows_virtual_machine.session_host[count.index].id
  publisher                  = "Microsoft.Azure.Security.WindowsAttestation"
  type                       = "GuestAttestation"
  type_handler_version       = "1.0"
  auto_upgrade_minor_version = true
  settings = jsonencode({
    AttestationConfig = {
      MaaSettings = {
        maaEndpoint   = ""
        maaTenantName = "GuestAttestation"
      }
      AscSettings = {
        ascReportingEndpoint  = ""
        ascReportingFrequency = ""
      }
      useCustomToken = "false"
      disableAlerts  = "false"
    }
  })
  depends_on = [azurerm_windows_virtual_machine.session_host]

  lifecycle {
    create_before_destroy = false
  }
}

# =============================================================================
# DSC EXTENSION — AVD Registration
# =============================================================================
# Uses Microsoft's official DSC configuration to register each session host to
# the AVD host pool using the registration token. This is the supported method
# for session host enrolment.
resource "azurerm_virtual_machine_extension" "avd_dsc" {
  count                      = var.session_host_count
  name                       = "Microsoft.Powershell.DSC"
  virtual_machine_id         = azurerm_windows_virtual_machine.session_host[count.index].id
  publisher                  = "Microsoft.Powershell"
  type                       = "DSC"
  type_handler_version       = "2.73"
  auto_upgrade_minor_version = true

  settings = <<-SETTINGS
    {
      "modulesUrl": "${var.configuration_zip_file}",
      "configurationFunction": "Configuration.ps1\\AddSessionHost",
      "properties": {
        "HostPoolName": "${var.host_pool_name}",
        "aadJoin": true
      }
    }
SETTINGS

  protected_settings = <<PROTECTED_SETTINGS
  {
    "properties": {
      "registrationInfoToken": "${var.registration_token}"
    }
  }
PROTECTED_SETTINGS

  lifecycle {
    create_before_destroy = false
  }
}

# =============================================================================
# AAD LOGIN EXTENSION
# =============================================================================
# Enables Entra ID (Azure AD) authentication on session hosts. Without this
# extension, users cannot sign in using their Entra ID credentials.
resource "azurerm_virtual_machine_extension" "aadlogin" {
  count                      = var.session_host_count
  name                       = "AADLoginForWindows"
  virtual_machine_id         = azurerm_windows_virtual_machine.session_host[count.index].id
  publisher                  = "Microsoft.Azure.ActiveDirectory"
  type                       = "AADLoginForWindows"
  type_handler_version       = "2.0"
  auto_upgrade_minor_version = true

  settings = jsonencode({
    mdmId = ""
  })

  lifecycle {
    create_before_destroy = false
  }
}

# =============================================================================
# SESSION HOST CLEANUP ON DESTROY (AzAPI)
# =============================================================================
# Removes session host registrations from the host pool when VMs are destroyed.
# Prevents "SessionHostPool could not be deleted because it still has
# SessionHosts associated" errors during terraform destroy.
resource "azapi_resource_action" "remove_session_host" {
  count = var.session_host_count

  type        = "Microsoft.DesktopVirtualization/hostPools/sessionHosts@2024-04-03"
  resource_id = "${var.host_pool_id}/sessionHosts/${azurerm_windows_virtual_machine.session_host[count.index].computer_name}"
  method      = "DELETE"

  when = "destroy"

  depends_on = [
    azurerm_virtual_machine_extension.avd_dsc,
    azurerm_virtual_machine_extension.aadlogin
  ]
}

# =============================================================================
# AZURE MONITOR AGENT EXTENSION
# =============================================================================
# Installs Azure Monitor Agent on each session host to collect performance
# counters and Windows event logs. Only deployed when monitoring is enabled.
resource "azurerm_virtual_machine_extension" "azure_monitor_agent" {
  count                      = var.enable_monitoring ? var.session_host_count : 0
  name                       = "AzureMonitorWindowsAgent"
  virtual_machine_id         = azurerm_windows_virtual_machine.session_host[count.index].id
  publisher                  = "Microsoft.Azure.Monitor"
  type                       = "AzureMonitorWindowsAgent"
  type_handler_version       = "1.0"
  auto_upgrade_minor_version = true
  automatic_upgrade_enabled  = true

  depends_on = [
    azurerm_windows_virtual_machine.session_host
  ]

  lifecycle {
    create_before_destroy = false
  }
}

# =============================================================================
# DATA COLLECTION RULE ASSOCIATION
# =============================================================================
# Associates the AVD session-hosts DCR (created by the monitoring module) to
# each VM so the Azure Monitor Agent knows what to collect and where to send it.
resource "azurerm_monitor_data_collection_rule_association" "session_hosts" {
  count                   = var.enable_monitoring ? var.session_host_count : 0
  name                    = "dcra-${azurerm_windows_virtual_machine.session_host[count.index].name}"
  target_resource_id      = azurerm_windows_virtual_machine.session_host[count.index].id
  data_collection_rule_id = var.avd_session_hosts_dcr_id

  depends_on = [
    azurerm_virtual_machine_extension.azure_monitor_agent
  ]
}