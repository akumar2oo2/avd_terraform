# Deployment Configuration
deployment_type = "pooled_desktop"
environment     = "prod"
prefix          = "avd"
location        = "centralindia"

# Network configuration
vnet_address_space    = ["10.20.0.0/16"]
subnet_address_prefix = ["10.20.1.0/24"]

# Pooled Desktop Configuration
# Higher session host count and capacity for production workloads.
session_host_count = 4
max_session_limit  = 6
load_balancer_type = "BreadthFirst"
vm_size            = "Standard_D8ds_v4"

# Image configuration
marketplace_gallery_image_sku = "win11-24h2-avd-m365"

# Security principals for production user access
# REQUIRED: Replace with actual Azure AD object IDs
security_principal_object_ids = [
  "56300c16-4d94-455e-b81c-43cce706e239",
  "cbb04528-1578-48a9-9639-0caaf9547f92"
]

# Local administrator credentials
admin_username = "localadmin"
# REQUIRED: Use Azure Key Vault or pipeline secret in production
admin_password = "ChangeMeInPipeline@2026!"

# Registration token expiration - shorter for production security
registration_token_expiration_hours = 2 # 2 hours for production security

# =============================================================================
# ENHANCED MONITORING AND SCALING CONFIGURATION
# =============================================================================

# Enable comprehensive monitoring with longer retention for compliance
enable_monitoring         = true
monitoring_retention_days = 90 # 3 months retention for production

# Enable enhanced scaling plans with production-tuned schedules
enable_scaling_plans = true

# Production scaling schedules - earlier ramp-up, larger minimums
scaling_plan_schedules = [
  {
    name                                 = "Weekdays"
    days_of_week                         = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"]
    ramp_up_start_time                   = "07:00"
    ramp_up_load_balancing_algorithm     = "BreadthFirst"
    ramp_up_minimum_hosts_percent        = 40
    ramp_up_capacity_threshold_percent   = 70
    peak_start_time                      = "08:00"
    peak_load_balancing_algorithm        = "BreadthFirst"
    ramp_down_start_time                 = "18:30"
    ramp_down_load_balancing_algorithm   = "BreadthFirst"
    ramp_down_minimum_hosts_percent      = 30
    ramp_down_capacity_threshold_percent = 30
    ramp_down_force_logoff_users         = false
    ramp_down_stop_hosts_when            = "ZeroSessions"
    ramp_down_wait_time_minutes          = 60
    ramp_down_notification_message       = "Your session will be logged off in 60 minutes due to scaling plan. Please save your work and close applications."
    off_peak_start_time                  = "20:00"
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
    ramp_down_notification_message       = "Your session will be logged off in 30 minutes due to scaling plan. Please save your work."
    off_peak_start_time                  = "18:00"
    off_peak_load_balancing_algorithm    = "BreadthFirst"
  }
]

# Enable cost monitoring alerts with higher production threshold
enable_cost_alerts   = true
cost_alert_threshold = 1000 # Production threshold

# Enable custom dashboards for insights
enable_dashboards          = true
dashboard_refresh_interval = 5 # More frequent refresh for production visibility

# Enhanced tags with production indicators
tags = {
  environment     = "production"
  workload        = "azure-virtual-desktop"
  deployment_type = "pooled-desktop"
  cost_center     = "IT-AVD"
  owner           = "ops-team"
  criticality     = "high"
  auto_shutdown   = "enabled"
  monitoring      = "enabled"
  scaling         = "enhanced"
  dashboards      = "enabled"
  created_by      = "terraform"
  compliance      = "in-scope"
  scaling_version = "enhanced"
}