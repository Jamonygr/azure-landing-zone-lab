# =============================================================================
# WINDOWS VIRTUAL MACHINE MODULE - VARIABLES
# =============================================================================

variable "name" {
  description = "VM name (max 15 characters for Windows)"
  type        = string

  validation {
    condition     = length(var.name) <= 15
    error_message = "Windows VM name must be 15 characters or less."
  }
}

variable "resource_group_name" {
  description = "Resource group name"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID for the VM"
  type        = string
}

variable "size" {
  description = "VM size - B2s recommended for lab"
  type        = string
  default     = "Standard_B2s" # 2 vCPU, 4 GB RAM - ~$30/month
}

variable "admin_username" {
  description = "Admin username"
  type        = string
  default     = "azureadmin"
}

variable "admin_password" {
  description = "Admin password"
  type        = string
  sensitive   = true
}

variable "windows_sku" {
  description = "Windows Server SKU"
  type        = string
  default     = "2022-datacenter-azure-edition-smalldisk"
}

variable "enable_public_ip" {
  description = "Enable public IP"
  type        = bool
  default     = false
}

variable "private_ip_address" {
  description = "Static private IP address (optional)"
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags to apply"
  type        = map(string)
  default     = {}
}

variable "zone" {
  description = "Availability zone"
  type        = string
  default     = null
}

variable "data_disks" {
  description = "Additional data disks"
  type = list(object({
    name         = string
    disk_size_gb = number
    lun          = number
  }))
  default = []
}

variable "enable_auto_shutdown" {
  description = "Enable auto-shutdown to save costs"
  type        = bool
  default     = true
}

variable "auto_shutdown_time" {
  description = "Auto-shutdown time in HH:MM format (24-hour)"
  type        = string
  default     = "1900" # 7 PM
}

variable "auto_shutdown_timezone" {
  description = "Timezone for auto-shutdown"
  type        = string
  default     = "W. Europe Standard Time"
}
