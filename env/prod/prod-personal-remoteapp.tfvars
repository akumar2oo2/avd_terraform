# Deployment Configuration
deployment_type = "personal_remoteapp"
environment     = "prod"
prefix          = "avd"
location        = "centralindia"

# Network configuration
vnet_address_space    = ["10.50.0.0/16"]
subnet_address_prefix = ["10.50.1.0/24"]

# Personal RemoteApp Configuration
# One dedicated VM per user (1:1 assignment) running published apps only.
session_host_count               = 5
load_balancer_type               = "Persistent"
personal_desktop_assignment_type = "Automatic"
vm_size                          = "Standard_D8ds_v4"

# Image configuration
marketplace_gallery_image_sku = "win11-24h2-avd-m365"

# Security principals for production user access
# REQUIRED: Replace with actual Azure AD object IDs (groups, not individual users)
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
# PUBLISHED APPLICATIONS (RemoteApp)
# =============================================================================
# REQUIRED: Apps published to end users via the AVD client. Each app has its
# path, optional arguments, and icon configuration.
published_applications = [
  {
    name                   = "word"
    display_name           = "Microsoft Word"
    description            = "Microsoft Word for document editing"
    path                   = "C:\\Program Files\\Microsoft Office\\root\\Office16\\WINWORD.EXE"
    command_line_arguments = ""
    command_line_setting   = "DoNotAllow"
    show_in_portal         = true
    icon_path              = "C:\\Program Files\\Microsoft Office\\root\\Office16\\WINWORD.EXE"
    icon_index             = 0
  },
  {
    name                   = "excel"
    display_name           = "Microsoft Excel"
    description            = "Microsoft Excel for spreadsheets"
    path                   = "C:\\Program Files\\Microsoft Office\\root\\Office16\\EXCEL.EXE"
    command_line_arguments = ""
    command_line_setting   = "DoNotAllow"
    show_in_portal         = true
    icon_path              = "C:\\Program Files\\Microsoft Office\\root\\Office16\\EXCEL.EXE"
    icon_index             = 0
  },
  {
    name                   = "outlook"
    display_name           = "Microsoft Outlook"
    description            = "Microsoft Outlook for email and calendar"
    path                   = "C:\\Program Files\\Microsoft Office\\root\\Office16\\OUTLOOK.EXE"
    command_line_arguments = ""
    command_line_setting   = "DoNotAllow"
    show_in_portal         = true
    icon_path              = "C:\\Program Files\\Microsoft Office\\root\\Office16\\OUTLOOK.EXE"
    icon_index             = 0
  }
]

# =============================================================================
# ENHANCED MONITORING AND SCALING CONFIGURATION
# =============================================================================

# Enable comprehensive monitoring with longer retention for compliance
enable_monitoring         = true
monitoring_retention_days = 90 # 3 months retention for production

# Scaling plans not supported for Personal host pools (1:1 assignment).
# Personal RemoteApp VMs must remain available for assigned users.
enable_scaling_plans   = false
scaling_plan_schedules = []

# Enable cost monitoring alerts - higher threshold since personal RemoteApp
# tends to incur more cost (always-on per user).
enable_cost_alerts   = true
cost_alert_threshold = 1500 # Production personal RemoteApp threshold

# Enable custom dashboards for insights
enable_dashboards          = true
dashboard_refresh_interval = 5

# Enhanced tags with personal production RemoteApp indicators
tags = {
  environment     = "production"
  workload        = "azure-virtual-desktop"
  deployment_type = "personal-remoteapp"
  cost_center     = "IT-AVD"
  owner           = "ops-team"
  criticality     = "high"
  monitoring      = "enabled"
  scaling         = "disabled"
  dashboards      = "enabled"
  created_by      = "terraform"
  compliance      = "in-scope"
}