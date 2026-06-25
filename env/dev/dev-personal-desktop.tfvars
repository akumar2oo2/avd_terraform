# Deployment Configuration
deployment_type = "personal_desktop"
environment     = "dev"
prefix          = "avd"
location        = "centralindia"

# Network configuration
vnet_address_space    = ["192.168.5.0/24"]
subnet_address_prefix = ["192.168.5.0/24"]

# Personal Desktop Configuration
# Each user gets their own dedicated VM (1:1 assignment).
session_host_count               = 2
load_balancer_type               = "Persistent"
personal_desktop_assignment_type = "Automatic"
vm_size                          = "Standard_D4ds_v4"

# Image configuration
marketplace_gallery_image_sku = "win11-24h2-avd-m365"

# Security principals for development team access
# REQUIRED: Replace with actual Azure AD object IDs
security_principal_object_ids = [
  "56300c16-4d94-455e-b81c-43cce706e239",
  "cbb04528-1578-48a9-9639-0caaf9547f92",
  "8c792c9f-ee23-4385-ae29-eca14afa5a80",
  "130d7af0-3e07-4e4b-800b-9af948f19a19"
]

# Local administrator credentials
admin_username = "localadmin"
# REQUIRED: Set development password
admin_password = "Welcome@20!" # Replace with actual password

# Registration token expiration - longer for development
registration_token_expiration_hours = 8 # 8 hours for dev convenience

# =============================================================================
# ENHANCED MONITORING AND SCALING CONFIGURATION
# =============================================================================

# Enable comprehensive monitoring
enable_monitoring         = true
monitoring_retention_days = 30

# Scaling plans not supported for Personal host pools (1:1 assignment).
# Cost control on personal desktops is achieved through monitoring + auto-shutdown,
# not via scaling plans.
enable_scaling_plans   = false
scaling_plan_schedules = []

# Enable cost monitoring alerts
enable_cost_alerts   = true
cost_alert_threshold = 200 # Personal desktops cost more (always-on per user)

# Enable custom dashboards for insights
enable_dashboards          = true
dashboard_refresh_interval = 15

# Enhanced tags with personal desktop indicators
tags = {
  environment     = "development"
  workload        = "azure-virtual-desktop"
  deployment_type = "personal-desktop"
  cost_center     = "IT-AVD"
  owner           = "dev-team"
  criticality     = "low"
  monitoring      = "enabled"
  scaling         = "disabled"
  dashboards      = "enabled"
  created_by      = "terraform"
}