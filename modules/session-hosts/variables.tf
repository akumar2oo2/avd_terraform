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

variable "subnet_id" {
  description = "Subnet ID where NICs will be attached."
  type        = string
}

variable "session_host_count" {
  description = "Number of session host VMs to deploy."
  type        = number
  default     = 1
}

variable "vm_size" {
  description = "VM SKU."
  type        = string
  default     = "Standard_D2s_v5"
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
  description = "Marketplace image SKU."
  type        = string
  default     = "win11-22h2-avd-m365"
}

variable "configuration_zip_file" {
  description = "URL of AVD DSC configuration zip."
  type        = string
}

# =============================================================================
# AVD INTEGRATION (from services module)
# =============================================================================

variable "host_pool_id" {
  description = "AVD Host Pool ID."
  type        = string
}

variable "host_pool_name" {
  description = "AVD Host Pool name."
  type        = string
}

variable "registration_token" {
  description = "Registration token for session host enrolment."
  type        = string
  sensitive   = true
}

# =============================================================================
# RBAC
# =============================================================================

variable "security_principal_object_ids" {
  description = "AAD object IDs to grant 'Virtual Machine User Login' on RG."
  type        = list(string)
  default     = []
}

# =============================================================================
# MONITORING (from monitoring module)
# =============================================================================

variable "enable_monitoring" {
  description = "Enable Azure Monitor Agent + DCR association on session hosts."
  type        = bool
  default     = false
}

variable "avd_session_hosts_dcr_id" {
  description = "Data Collection Rule ID for session host monitoring."
  type        = string
  default     = null
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