variable "prefix" {
  description = "Naming prefix."
  type        = string
}

variable "environment" {
  description = "Environment name."
  type        = string
}

variable "location" {
  description = "Azure region."
  type        = string
}

variable "resource_group_name" {
  description = "Resource group to host dashboard, action group, and budget."
  type        = string
}

variable "resource_group_id" {
  description = "Resource group ID for budget scope."
  type        = string
}

# =============================================================================
# FEATURE TOGGLES
# =============================================================================

variable "enable_cost_alerts" {
  description = "Enable consumption budget + action group + alerts."
  type        = bool
  default     = false
}

variable "enable_dashboards" {
  description = "Enable AVD insights portal dashboard."
  type        = bool
  default     = false
}

# =============================================================================
# COST
# =============================================================================

variable "cost_alert_threshold" {
  description = "Monthly cost alert threshold."
  type        = number
  default     = 100
}

variable "cost_alert_email" {
  description = "Email address for cost alert notifications."
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$", var.cost_alert_email))
    error_message = "cost_alert_email must be a valid email format."
  }
}

# =============================================================================
# DASHBOARD
# =============================================================================\

variable "deployment_type" {
  description = "AVD deployment type for dashboard context."
  type        = string
}

variable "dashboard_refresh_interval" {
  description = "Dashboard refresh interval (e.g., 5m, 1h)."
  type        = string
  default     = "5m"
}

# =============================================================================
# REFERENCES
# =============================================================================

variable "host_pool_id" {
  description = "AVD Host Pool ID."
  type        = string
}

variable "log_analytics_workspace_id" {
  description = "Log Analytics workspace ID (empty string if monitoring disabled)."
  type        = string
  default     = ""
}

# =============================================================================
# TAGS
# =============================================================================

variable "tags" {
  description = "Common resource tags."
  type        = map(string)
  default     = {}
}