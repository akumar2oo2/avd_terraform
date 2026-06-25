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
  description = "Resource group to host the Log Analytics workspace and DCR."
  type        = string
}

variable "monitoring_retention_days" {
  description = "Retention in days for Log Analytics workspace."
  type        = number
  default     = 30

  validation {
    condition     = var.monitoring_retention_days >= 30 && var.monitoring_retention_days <= 730
    error_message = "monitoring_retention_days must be between 30 and 730."
  }
}

# =============================================================================
# AVD INTEGRATION (from services module)
# =============================================================================

variable "host_pool_id" {
  description = "AVD Host Pool ID for diagnostic settings."
  type        = string
}

variable "host_pool_name" {
  description = "AVD Host Pool name."
  type        = string
}

variable "workspace_id" {
  description = "AVD Workspace ID for diagnostic settings."
  type        = string
}

variable "workspace_name" {
  description = "AVD Workspace name."
  type        = string
}

variable "application_group_id" {
  description = "AVD App Group ID for diagnostic settings."
  type        = string
}

variable "application_group_name" {
  description = "AVD App Group name."
  type        = string
}

# =============================================================================
# TAGS
# =============================================================================

variable "tags" {
  description = "Common resource tags."
  type        = map(string)
  default     = {}
}