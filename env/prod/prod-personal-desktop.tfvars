# Deployment Configuration
deployment_type = "personal_desktop"
environment     = "prod"
prefix          = "avd"
location        = "centralindia"

# Network configuration
vnet_address_space    = ["10.30.0.0/16"]
subnet_address_prefix = ["10.30.1.0/24"]

# Personal Desktop Configuration
# One dedicated VM per user (1:1 assignment) — typical for executives or
# specialized power users in production.
session_host_count               = 5
load_balancer_type               = "Persistent"
personal_desktop_assignment_type = "Automatic"
vm_size                          = "Standard_D8ds_v4"

# Image configuration
marketplace_gallery_image_sku = "win11-24h2-avd-m365"

# Security principals for production user access
# REQUIRED: Replace with actual Azure AD object IDs
security_principal_object_ids = [
  "56300c16-4d94-455e-b81c-43cce706e239",
  "cbb04528-1578-48a9-9639-0caaf9547f92",
  "8c792c9f-ee23-4385-ae29-eca14afa5a80"
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

# Scaling plans not supported for Personal host pools (1:1 assignment).
# Personal desktops must remain available for assigned users at all times.
enable_scaling_plans   = false
scaling_plan_schedules = []

# Enable cost monitoring alerts - higher threshold since personal desktops
# tend to incur more cost (always-on per user).
enable_cost_alerts   = true
cost_alert_threshold = 1500 # Production personal desktop threshold

# Enable custom dashboards for insights
enable_dashboards          = true
dashboard_refresh_interval = 5

# Enhanced tags with personal production indicators
tags = {
  environment     = "production"
  workload        = "azure-virtual-desktop"
  deployment_type = "personal-desktop"
  cost_center     = "IT-AVD"
  owner           = "ops-team"
  criticality     = "high"
  monitoring      = "enabled"
  scaling         = "disabled"
  dashboards      = "enabled"
  created_by      = "terraform"
  compliance      = "in-scope"
}