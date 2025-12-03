# =============================================================================
# KEY VAULT MODULE - VARIABLES
# =============================================================================

variable "name" {
  description = "Key Vault name (3-24 chars)"
  type        = string
}

variable "resource_group_name" {
  description = "Resource group name"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "tags" {
  description = "Tags to apply"
  type        = map(string)
  default     = {}
}

variable "tenant_id" {
  description = "Azure AD Tenant ID"
  type        = string
}

variable "sku_name" {
  description = "Key Vault SKU (standard or premium)"
  type        = string
  default     = "standard"
}

variable "soft_delete_retention_days" {
  description = "Soft delete retention days"
  type        = number
  default     = 7 # Minimum for lab
}

variable "purge_protection_enabled" {
  description = "Enable purge protection"
  type        = bool
  default     = false # Disabled for lab flexibility
}

variable "enable_rbac_authorization" {
  description = "Use RBAC instead of access policies"
  type        = bool
  default     = true
}

variable "enabled_for_deployment" {
  description = "Allow VMs to retrieve certificates"
  type        = bool
  default     = true
}

variable "enabled_for_disk_encryption" {
  description = "Allow disk encryption to retrieve secrets"
  type        = bool
  default     = true
}

variable "enabled_for_template_deployment" {
  description = "Allow ARM templates to retrieve secrets"
  type        = bool
  default     = true
}

variable "network_acls" {
  description = "Network ACLs"
  type = object({
    bypass                     = string
    default_action             = string
    ip_rules                   = optional(list(string), [])
    virtual_network_subnet_ids = optional(list(string), [])
  })
  default = {
    bypass         = "AzureServices"
    default_action = "Allow" # Allow for lab
  }
}

variable "secrets" {
  description = "Secrets to create"
  type = map(object({
    value        = string
    content_type = optional(string)
  }))
  default   = {}
  sensitive = true
}
