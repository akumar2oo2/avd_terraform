# =============================================================================
# LOCAL VALUES — Tags & Default Scaling Schedules
# =============================================================================
# Tag merging and built-in scaling schedules for dev and prod environments.
# Custom schedules can override these via var.scaling_plan_schedules.
locals {
  default_scaling_schedules = {
    dev = [
      {
        name                                 = "Weekdays"
        days_of_week                         = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"]
        ramp_up_start_time                   = "08:00"
        ramp_up_load_balancing_algorithm     = "BreadthFirst"
        ramp_up_minimum_hosts_percent        = 20
        ramp_up_capacity_threshold_percent   = 80
        peak_start_time                      = "09:00"
        peak_load_balancing_algorithm        = "BreadthFirst"
        ramp_down_start_time                 = "17:00"
        ramp_down_load_balancing_algorithm   = "BreadthFirst"
        ramp_down_minimum_hosts_percent      = 20
        ramp_down_capacity_threshold_percent = 20
        ramp_down_force_logoff_users         = false
        ramp_down_stop_hosts_when            = "ZeroSessions"
        ramp_down_wait_time_minutes          = 30
        ramp_down_notification_message       = "You will be logged off in 30 minutes due to scaling plan. Please save your work."
        off_peak_start_time                  = "18:00"
        off_peak_load_balancing_algorithm    = "BreadthFirst"
      },
      {
        name                                 = "Weekends"
        days_of_week                         = ["Saturday", "Sunday"]
        ramp_up_start_time                   = "09:00"
        ramp_up_load_balancing_algorithm     = "BreadthFirst"
        ramp_up_minimum_hosts_percent        = 10
        ramp_up_capacity_threshold_percent   = 80
        peak_start_time                      = "10:00"
        peak_load_balancing_algorithm        = "BreadthFirst"
        ramp_down_start_time                 = "16:00"
        ramp_down_load_balancing_algorithm   = "BreadthFirst"
        ramp_down_minimum_hosts_percent      = 10
        ramp_down_capacity_threshold_percent = 20
        ramp_down_force_logoff_users         = false
        ramp_down_stop_hosts_when            = "ZeroSessions"
        ramp_down_wait_time_minutes          = 30
        ramp_down_notification_message       = "You will be logged off in 30 minutes due to scaling plan. Please save your work."
        off_peak_start_time                  = "17:00"
        off_peak_load_balancing_algorithm    = "BreadthFirst"
      }
    ]
    prod = [
      {
        name                                 = "Weekdays"
        days_of_week                         = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"]
        ramp_up_start_time                   = "07:00"
        ramp_up_load_balancing_algorithm     = "BreadthFirst"
        ramp_up_minimum_hosts_percent        = 30
        ramp_up_capacity_threshold_percent   = 80
        peak_start_time                      = "08:00"
        peak_load_balancing_algorithm        = "BreadthFirst"
        ramp_down_start_time                 = "18:00"
        ramp_down_load_balancing_algorithm   = "BreadthFirst"
        ramp_down_minimum_hosts_percent      = 30
        ramp_down_capacity_threshold_percent = 20
        ramp_down_force_logoff_users         = false
        ramp_down_stop_hosts_when            = "ZeroSessions"
        ramp_down_wait_time_minutes          = 30
        ramp_down_notification_message       = "You will be logged off in 30 minutes due to scaling plan. Please save your work."
        off_peak_start_time                  = "19:00"
        off_peak_load_balancing_algorithm    = "BreadthFirst"
      },
      {
        name                                 = "Weekends"
        days_of_week                         = ["Saturday", "Sunday"]
        ramp_up_start_time                   = "08:00"
        ramp_up_load_balancing_algorithm     = "BreadthFirst"
        ramp_up_minimum_hosts_percent        = 20
        ramp_up_capacity_threshold_percent   = 80
        peak_start_time                      = "09:00"
        peak_load_balancing_algorithm        = "BreadthFirst"
        ramp_down_start_time                 = "17:00"
        ramp_down_load_balancing_algorithm   = "BreadthFirst"
        ramp_down_minimum_hosts_percent      = 20
        ramp_down_capacity_threshold_percent = 20
        ramp_down_force_logoff_users         = false
        ramp_down_stop_hosts_when            = "ZeroSessions"
        ramp_down_wait_time_minutes          = 30
        ramp_down_notification_message       = "You will be logged off in 30 minutes due to scaling plan. Please save your work."
        off_peak_start_time                  = "18:00"
        off_peak_load_balancing_algorithm    = "BreadthFirst"
      }
    ]
  }

  scaling_schedules = length(var.scaling_plan_schedules) > 0 ? var.scaling_plan_schedules : tolist(local.default_scaling_schedules[var.environment])

  default_tags = {
    environment = var.environment
    prefix      = var.prefix
    created_by  = "terraform"
  }
  tags = merge(local.default_tags, var.tags)
}

# =============================================================================
# CURRENT SUBSCRIPTION LOOKUP
# =============================================================================
# Reads the current Azure subscription details used as the scope for the AVD
# service principal role assignment below.
data "azurerm_subscription" "current" {}

# =============================================================================
# ROLE DEFINITION LOOKUP — Desktop Virtualization Power On Off Contributor
# =============================================================================
# Reads the built-in role that allows starting and stopping VMs as part of the
# AVD scaling plan operations.
data "azurerm_role_definition" "avd_power_role" {
  name = "Desktop Virtualization Power On Off Contributor"
}

# =============================================================================
# AVD SERVICE PRINCIPAL LOOKUP
# =============================================================================
# Reads the official AVD service principal (Microsoft-managed, same client ID
# across all tenants). Required to assign the power on/off role to AVD itself.
data "azuread_service_principal" "avd" {
  client_id = "9cdead84-a844-4324-93f2-b2e6bb768d07"
}

# =============================================================================
# RANDOM UUID FOR ROLE ASSIGNMENT NAME
# =============================================================================
# Generates a stable UUID used as the role assignment name. This prevents
# conflicts and ensures idempotency across applies.
resource "random_uuid" "scaling_plan_role" {}

# =============================================================================
# ROLE ASSIGNMENT — AVD Power On/Off Contributor
# =============================================================================
# Grants the AVD service principal the power on/off role at subscription scope
# so it can start and stop session host VMs based on the scaling plan schedule.
resource "azurerm_role_assignment" "scaling_plan" {
  name                             = random_uuid.scaling_plan_role.result
  scope                            = data.azurerm_subscription.current.id
  role_definition_id               = data.azurerm_role_definition.avd_power_role.id
  principal_id                     = data.azuread_service_principal.avd.object_id
  skip_service_principal_aad_check = true

  lifecycle {
    ignore_changes = all
  }
}

# =============================================================================
# AVD SCALING PLAN
# =============================================================================
# Defines automatic scaling behavior for the host pool with ramp-up, peak,
# ramp-down, and off-peak phases. Schedules come from var.scaling_plan_schedules
# or default to the environment-specific schedule in locals above.
resource "azurerm_virtual_desktop_scaling_plan" "this" {
  name                = "scaling-${var.prefix}-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name
  friendly_name       = "${var.prefix}-${var.environment} Scaling Plan"
  description         = "Automatic scaling plan for ${var.environment} AVD environment"
  time_zone           = "Australia/Melbourne"
  tags                = local.tags

  dynamic "schedule" {
    for_each = local.scaling_schedules
    content {
      name                                 = schedule.value.name
      days_of_week                         = schedule.value.days_of_week
      ramp_up_start_time                   = schedule.value.ramp_up_start_time
      ramp_up_load_balancing_algorithm     = schedule.value.ramp_up_load_balancing_algorithm
      ramp_up_minimum_hosts_percent        = schedule.value.ramp_up_minimum_hosts_percent
      ramp_up_capacity_threshold_percent   = schedule.value.ramp_up_capacity_threshold_percent
      peak_start_time                      = schedule.value.peak_start_time
      peak_load_balancing_algorithm        = schedule.value.peak_load_balancing_algorithm
      ramp_down_start_time                 = schedule.value.ramp_down_start_time
      ramp_down_load_balancing_algorithm   = schedule.value.ramp_down_load_balancing_algorithm
      ramp_down_minimum_hosts_percent      = schedule.value.ramp_down_minimum_hosts_percent
      ramp_down_capacity_threshold_percent = schedule.value.ramp_down_capacity_threshold_percent
      ramp_down_force_logoff_users         = schedule.value.ramp_down_force_logoff_users
      ramp_down_stop_hosts_when            = schedule.value.ramp_down_stop_hosts_when
      ramp_down_wait_time_minutes          = schedule.value.ramp_down_wait_time_minutes
      ramp_down_notification_message       = schedule.value.ramp_down_notification_message
      off_peak_start_time                  = schedule.value.off_peak_start_time
      off_peak_load_balancing_algorithm    = schedule.value.off_peak_load_balancing_algorithm
    }
  }

  depends_on = [azurerm_role_assignment.scaling_plan]
}

# =============================================================================
# SCALING PLAN <-> HOST POOL ASSOCIATION
# =============================================================================
# Binds the scaling plan to the AVD host pool and enables it. Without this
# association, the scaling plan is created but not active.
resource "azurerm_virtual_desktop_scaling_plan_host_pool_association" "this" {
  host_pool_id    = var.host_pool_id
  scaling_plan_id = azurerm_virtual_desktop_scaling_plan.this.id
  enabled         = true
}