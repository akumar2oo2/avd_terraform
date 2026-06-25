# =============================================================================
# LOCAL VALUES — Names, Deployment Config & Tags
# =============================================================================
# Centralized configuration logic. Resource names, deployment-type-specific
# settings, and tag merging are all defined here for clarity and reuse.
locals {
  names = {
    rg        = format("rg-%s-%s-services", var.prefix, var.environment)
    host_pool = format("vdpool-%s-%s-%s", var.prefix, var.environment, local.deployment_suffixes[var.deployment_type])
    app_group = format("vdag-%s-%s-%s", var.prefix, var.environment, local.deployment_suffixes[var.deployment_type])
    workspace = format("vdws-%s-%s", var.prefix, var.environment) # Workspace serves all deployment types
  }

  deployment_suffixes = {
    pooled_desktop     = "desktop"
    personal_desktop   = "personal"
    pooled_remoteapp   = "apps"
    personal_remoteapp = "personalapps"
  }

  deployment_config = {
    pooled_desktop = {
      host_pool_type           = "Pooled"
      app_group_type           = "Desktop"
      load_balancer_type       = var.load_balancer_type
      max_sessions             = var.max_session_limit
      start_vm_on_connect      = false
      friendly_name_suffix     = "Desktop Pool"
      description_suffix       = "Pooled Desktop Environment"
      personal_assignment_type = null
      supports_load_balancing  = true
      supports_applications    = false
    }
    personal_desktop = {
      host_pool_type           = "Personal"
      app_group_type           = "Desktop"
      load_balancer_type       = "Persistent"
      max_sessions             = 1
      start_vm_on_connect      = true
      friendly_name_suffix     = "Personal Desktop"
      description_suffix       = "Personal Desktop Environment"
      personal_assignment_type = var.personal_desktop_assignment_type
      supports_load_balancing  = false
      supports_applications    = false
    }
    pooled_remoteapp = {
      host_pool_type           = "Pooled"
      app_group_type           = "RemoteApp"
      load_balancer_type       = var.load_balancer_type
      max_sessions             = var.max_session_limit
      start_vm_on_connect      = false
      friendly_name_suffix     = "RemoteApp Pool"
      description_suffix       = "Pooled RemoteApp Environment"
      personal_assignment_type = null
      supports_load_balancing  = true
      supports_applications    = true
    }
    personal_remoteapp = {
      host_pool_type           = "Personal"
      app_group_type           = "RemoteApp"
      load_balancer_type       = "Persistent"
      max_sessions             = 1
      start_vm_on_connect      = true
      friendly_name_suffix     = "Personal RemoteApp"
      description_suffix       = "Personal RemoteApp Environment"
      personal_assignment_type = var.personal_desktop_assignment_type
      supports_load_balancing  = false
      supports_applications    = true
    }
  }

  current_config = local.deployment_config[var.deployment_type]

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
# Dedicated resource group for all AVD control-plane resources (Host Pool,
# Application Group, Workspace, Apps, Registration Info).
resource "azurerm_resource_group" "services" {
  name     = local.names.rg
  location = var.location
  tags     = var.enhanced_tags
}

# =============================================================================
# AVD HOST POOL
# =============================================================================
# Defines how session hosts behave (Pooled/Personal, max sessions, load balancing).
# RDP properties enable AAD join, clipboard, printer, audio, and multimon redirection.
resource "azurerm_virtual_desktop_host_pool" "services" {
  name                             = local.names.host_pool
  location                         = azurerm_resource_group.services.location
  resource_group_name              = azurerm_resource_group.services.name
  type                             = local.current_config.host_pool_type
  friendly_name                    = "${var.prefix}-${var.environment}-${local.current_config.friendly_name_suffix}"
  description                      = "${local.current_config.description_suffix} created via Terraform"
  maximum_sessions_allowed         = local.current_config.max_sessions
  load_balancer_type               = local.current_config.load_balancer_type
  validate_environment             = true
  start_vm_on_connect              = local.current_config.start_vm_on_connect
  personal_desktop_assignment_type = local.current_config.personal_assignment_type
  custom_rdp_properties            = "targetisaadjoined:i:1;drivestoredirect:s:*;audiomode:i:0;videoplaybackmode:i:1;redirectclipboard:i:1;redirectprinters:i:1;devicestoredirect:s:*;redirectcomports:i:1;redirectsmartcards:i:1;usbdevicestoredirect:s:*;enablecredsspsupport:i:1;redirectwebauthn:i:1;use multimon:i:1;enablerdsaadauth:i:1;"
  tags                             = local.tags

  scheduled_agent_updates {
    enabled  = true
    timezone = "Australia/Melbourne"
    schedule {
      day_of_week = "Sunday"
      hour_of_day = 2
    }
  }
  lifecycle {
    ignore_changes = [tags]
  }
}

# =============================================================================
# HOST POOL REGISTRATION TOKEN
# =============================================================================
# Generates a token that session hosts use to register themselves to the host
# pool during DSC bootstrapping. Expiration is configurable via variable.
resource "azurerm_virtual_desktop_host_pool_registration_info" "services" {
  hostpool_id     = azurerm_virtual_desktop_host_pool.services.id
  expiration_date = timeadd(timestamp(), "${var.registration_token_expiration_hours}h")
}

# =============================================================================
# APPLICATION GROUP
# =============================================================================
# Entry point users see in the AVD client. Type is either Desktop (full desktop)
# or RemoteApp (individual published applications).
resource "azurerm_virtual_desktop_application_group" "services" {
  name                = local.names.app_group
  location            = azurerm_resource_group.services.location
  resource_group_name = azurerm_resource_group.services.name
  host_pool_id        = azurerm_virtual_desktop_host_pool.services.id
  type                = local.current_config.app_group_type
  friendly_name       = "${var.prefix}-${var.environment}-${local.current_config.friendly_name_suffix}"
  description         = "${local.current_config.description_suffix} Application Group"
  tags                = local.tags
}

# =============================================================================
# WORKSPACE
# =============================================================================
# AVD workspace groups application groups for end users. Public network access
# is enabled so users can connect over the internet.
resource "azurerm_virtual_desktop_workspace" "services" {
  name                          = local.names.workspace
  location                      = azurerm_resource_group.services.location
  resource_group_name           = azurerm_resource_group.services.name
  friendly_name                 = "${var.prefix}-${var.environment}-workspace"
  description                   = "${local.current_config.description_suffix} workspace for ${var.environment} environment"
  public_network_access_enabled = true
  tags                          = local.tags
}

# =============================================================================
# PUBLISHED APPLICATIONS (RemoteApp only)
# =============================================================================
# Creates individual AVD applications only when deployment type is RemoteApp.
# Each app comes from var.published_applications with its path, args, and icon.
resource "azurerm_virtual_desktop_application" "apps" {
  for_each = local.current_config.supports_applications ? {
    for app in var.published_applications : app.name => app
  } : {}

  name                         = each.value.name
  application_group_id         = azurerm_virtual_desktop_application_group.services.id
  friendly_name                = each.value.display_name
  description                  = each.value.description
  path                         = each.value.path
  command_line_arguments       = each.value.command_line_arguments != "" ? each.value.command_line_arguments : null
  command_line_argument_policy = each.value.command_line_setting
  show_in_portal               = each.value.show_in_portal
  icon_path                    = each.value.icon_path != "" ? each.value.icon_path : null
  icon_index                   = each.value.icon_index
}

# =============================================================================
# WORKSPACE <-> APPLICATION GROUP ASSOCIATION
# =============================================================================
# Binds the application group to the workspace so it appears in the AVD client.
# Without this, the app group is not discoverable by end users.
resource "azurerm_virtual_desktop_workspace_application_group_association" "services" {
  workspace_id         = azurerm_virtual_desktop_workspace.services.id
  application_group_id = azurerm_virtual_desktop_application_group.services.id
}

# =============================================================================
# ROLE DEFINITION LOOKUP — Desktop Virtualization User
# =============================================================================
# Reads the built-in "Desktop Virtualization User" role used in the role
# assignment below. This role lets users connect to the application group.
data "azurerm_role_definition" "desktop_virtualization_user" {
  name = "Desktop Virtualization User"
}

# =============================================================================
# ROLE ASSIGNMENT — User/Group Access to AVD
# =============================================================================
# Grants each AAD object in var.security_principal_object_ids the "Desktop
# Virtualization User" role on the application group, allowing AVD access.
resource "azurerm_role_assignment" "app_group" {
  for_each           = toset(var.security_principal_object_ids)
  scope              = azurerm_virtual_desktop_application_group.services.id
  role_definition_id = data.azurerm_role_definition.desktop_virtualization_user.id
  principal_id       = each.value
}