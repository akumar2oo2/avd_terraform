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
}

variable "max_session_limit" {
  description = "Max concurrent sessions per session host."
  type        = number
  default     = 10
}

variable "personal_desktop_assignment_type" {
  description = "Assignment type for personal host pools."
  type        = string
  default     = "Automatic"
}

variable "registration_token_expiration_hours" {
  description = "Validity of host pool registration token (in hours)."
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

  validation {
    condition     = !(contains(["pooled_remoteapp", "personal_remoteapp"], var.deployment_type) && length(var.published_applications) == 0)
    error_message = "published_applications must contain at least one app for RemoteApp deployments."
  }
}

variable "security_principal_object_ids" {
  description = "AAD object IDs of users/groups to assign 'Desktop Virtualization User' role."
  type        = list(string)
  default     = []
}

# =============================================================================
# TAGS
# =============================================================================

variable "tags" {
  description = "Common resource tags."
  type        = map(string)
  default     = {}
}

variable "enhanced_tags" {
  description = "Enhanced tags applied at RG level."
  type        = map(string)
  default     = {}
}