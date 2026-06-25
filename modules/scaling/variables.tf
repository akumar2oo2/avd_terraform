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
  description = "Resource group to host the scaling plan."
  type        = string
}

variable "host_pool_id" {
  description = "AVD Host Pool ID to associate with scaling plan."
  type        = string
}

variable "scaling_plan_schedules" {
  description = "Custom schedules. Empty list = use environment defaults."
  type        = list(any)
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