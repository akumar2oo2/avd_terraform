variable "prefix" {
  description = "Short identifier used in resource naming (e.g., avd)."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9]{2,10}$", var.prefix))
    error_message = "Prefix must be 2-10 lowercase alphanumeric characters."
  }
}

variable "environment" {
  description = "Environment name (e.g., dev, uat, prod)."
  type        = string

  validation {
    condition     = contains(["dev", "uat", "prod"], var.environment)
    error_message = "Environment must be one of: dev, uat, prod."
  }
}

variable "location" {
  description = "Azure region for all resources."
  type        = string
  default     = "centralindia"
}

variable "tags" {
  description = "Additional tags to apply to all resources."
  type        = map(string)
  default     = {}
}

# =============================================================================
# NETWORK
# =============================================================================

variable "vnet_address_space" {
  description = "CIDR block(s) for the virtual network."
  type        = list(string)
  default     = ["10.10.0.0/16"]
}

variable "subnet_address_prefix" {
  description = "CIDR block(s) for the AVD subnet."
  type        = list(string)
  default     = ["10.10.1.0/24"]
}

variable "delete_network_watcher_rg" {
  description = "If true, deletes auto-created NetworkWatcherRG when network module is destroyed."
  type        = bool
  default     = true
}

# =============================================================================
# AVD DEPLOYMENT
# =============================================================================

variable "deployment_type" {
  description = "AVD deployment type."
  type        = string

  validation {
    condition     = contains(["pooled_desktop", "personal_desktop", "pooled_remoteapp", "personal_remoteapp"], var.deployment_type)
    error_message = "deployment_type must be: pooled_desktop, personal_desktop, pooled_remoteapp, or personal_remoteapp."
  }
}

variable "load_balancer_type" {
  description = "Load balancing algorithm for pooled host pools."
  type        = string
  default     = "BreadthFirst"

  validation {
    condition     = contains(["BreadthFirst", "DepthFirst", "Persistent"], var.load_balancer_type)
    error_message = "load_balancer_type must be BreadthFirst, DepthFirst, or Persistent."
  }
}

variable "max_session_limit" {
  description = "Maximum concurrent sessions per session host (pooled only)."
  type        = number
  default     = 10
}

variable "personal_desktop_assignment_type" {
  description = "Assignment type for Personal host pools (Automatic or Direct)."
  type        = string
  default     = "Automatic"
}

variable "registration_token_expiration_hours" {
  description = "Number of hours the AVD host pool registration token is valid."
  type        = number
  default     = 24
}

variable "published_applications" {
  description = "List of published applications for RemoteApp deployments."
  type = list(object({
    name                   = string
    display_name           = string
    description            = string
    path                   = string
    command_line_arguments = string
    command_line_setting   = string
    show_in_portal         = bool
    icon_path              = string
    icon_index             = number
  }))
  default = []
}

variable "security_principal_object_ids" {
  description = "Object IDs of AAD users/groups for AVD access."
  type        = list(string)
  default     = []
}

# =============================================================================
# SESSION HOSTS
# =============================================================================

variable "session_host_count" {
  description = "Number of session host VMs to deploy."
  type        = number
  default     = 1
}

variable "vm_size" {
  description = "VM SKU for session hosts."
  type        = string
  default     = "Standard_D4ds_v4"
}

variable "admin_username" {
  description = "Local admin username for session hosts."
  type        = string
  sensitive   = true
}

variable "admin_password" {
  description = "Local admin password for session hosts."
  type        = string
  sensitive   = true
}

variable "marketplace_gallery_image_sku" {
  description = "Image SKU for session host VMs."
  type        = string
  default     = "win11-22h2-avd-m365"
}

variable "configuration_zip_file" {
  description = "URL of AVD DSC configuration zip file."
  type        = string
  default     = "https://wvdportalstorageblob.blob.core.windows.net/galleryartifacts/Configuration_1.0.02990.697.zip"
}

# =============================================================================
# MONITORING
# =============================================================================

variable "enable_monitoring" {
  description = "Enable Log Analytics + DCR + diagnostic settings."
  type        = bool
  default     = false
}

variable "monitoring_retention_days" {
  description = "Retention in days for Log Analytics workspace."
  type        = number
  default     = 30
}

# =============================================================================
# SCALING PLAN
# =============================================================================

variable "enable_scaling_plans" {
  description = "Enable AVD scaling plan."
  type        = bool
  default     = false
}

variable "scaling_plan_schedules" {
  description = "Optional custom schedules for scaling plan. Empty list = use environment defaults."
  type        = list(any)
  default     = []
}

# =============================================================================
# COST ALERTS / DASHBOARD
# =============================================================================

variable "enable_cost_alerts" {
  description = "Enable cost alerts + budget."
  type        = bool
  default     = false
}

variable "cost_alert_threshold" {
  description = "Monthly cost alert threshold (currency unit)."
  type        = number
  default     = 100
}

variable "cost_alert_email" {
  description = "Email address for cost alert notifications."
  type        = string
  default     = "admin@example.com"
}

variable "enable_dashboards" {
  description = "Enable AVD insights dashboard creation."
  type        = bool
  default     = false
}

variable "dashboard_refresh_interval" {
  description = "Dashboard refresh interval (e.g., 5m, 1h)."
  type        = string
  default     = "5m"
}