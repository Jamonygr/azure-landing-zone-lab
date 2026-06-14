# =============================================================================
# STORAGE ACCOUNT MODULE - VARIABLES
# =============================================================================

variable "name" {
  description = "Storage account name (3-24 chars, lowercase, no hyphens)"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9]{3,24}$", var.name))
    error_message = "Storage account name must be 3-24 lowercase alphanumeric characters."
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

variable "tags" {
  description = "Tags to apply"
  type        = map(string)
  default     = {}
}

variable "account_tier" {
  description = "Account tier (Standard or Premium)"
  type        = string
  default     = "Standard"
}

variable "account_replication_type" {
  description = "Replication type (LRS, GRS, RAGRS, ZRS)"
  type        = string
  default     = "LRS" # Cheapest for lab
}

variable "account_kind" {
  description = "Account kind"
  type        = string
  default     = "StorageV2"
}

variable "access_tier" {
  description = "Access tier (Hot or Cool)"
  type        = string
  default     = "Hot"
}

variable "enable_https_traffic_only" {
  description = "Force HTTPS"
  type        = bool
  default     = true
}

variable "min_tls_version" {
  description = "Minimum TLS version"
  type        = string
  default     = "TLS1_2"
}

variable "allow_nested_items_to_be_public" {
  description = "Allow public access to blobs"
  type        = bool
  default     = false
}

variable "local_user_enabled" {
  description = "Enable storage local users for SFTP scenarios"
  type        = bool
  default     = false
}

variable "shared_access_key_enabled" {
  description = "Enable shared access keys. Kept true by default because Terraform-managed containers, file shares, and Function Apps may require shared key data-plane access in this lab."
  type        = bool
  default     = true
}

variable "sas_expiration_period" {
  description = "Maximum SAS token lifetime in DD.HH:MM:SS format. Set null to omit a SAS policy."
  type        = string
  default     = "1.00:00:00"
}

variable "public_network_access_enabled" {
  description = "Allow public network access to the storage account data plane"
  type        = bool
  default     = true
}

variable "containers" {
  description = "Blob containers to create"
  type = list(object({
    name                  = string
    container_access_type = optional(string, "private")
  }))
  default = []
}

variable "file_shares" {
  description = "File shares to create"
  type = list(object({
    name  = string
    quota = number
  }))
  default = []
}

variable "network_rules" {
  description = "Network rules for the storage account"
  type = object({
    default_action             = string
    bypass                     = optional(list(string), ["AzureServices"])
    ip_rules                   = optional(list(string), [])
    virtual_network_subnet_ids = optional(list(string), [])
  })
  default = null
}
