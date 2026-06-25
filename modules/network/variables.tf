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
  description = "If true, delete auto-created NetworkWatcherRG on destroy."
  type        = bool
  default     = true
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