# =============================================================================
# MANAGEMENT GROUPS MODULE - VARIABLES
# Follows Cloud Adoption Framework (CAF) hierarchy
# =============================================================================

variable "root_management_group_name" {
  description = "Display name for the root management group"
  type        = string
  default     = "Organization"
}

variable "root_management_group_id" {
  description = "ID for the root management group (must be unique in tenant)"
  type        = string
  default     = "org-root"
}

variable "parent_management_group_id" {
  description = "Parent management group ID (typically tenant root group). Leave empty to use tenant root."
  type        = string
  default     = null
}

variable "create_platform_mg" {
  description = "Create Platform management group hierarchy (Identity, Management, Connectivity)"
  type        = bool
  default     = true
}

variable "create_landing_zones_mg" {
  description = "Create Landing Zones management group hierarchy (Corp, Online)"
  type        = bool
  default     = true
}

variable "create_sandbox_mg" {
  description = "Create Sandbox management group for experimentation"
  type        = bool
  default     = true
}

variable "create_decommissioned_mg" {
  description = "Create Decommissioned management group for resources pending deletion"
  type        = bool
  default     = true
}

variable "subscription_ids_platform_identity" {
  description = "List of subscription IDs to place under Platform > Identity"
  type        = list(string)
  default     = []
}

variable "subscription_ids_platform_management" {
  description = "List of subscription IDs to place under Platform > Management"
  type        = list(string)
  default     = []
}

variable "subscription_ids_platform_connectivity" {
  description = "List of subscription IDs to place under Platform > Connectivity"
  type        = list(string)
  default     = []
}

variable "subscription_ids_landing_zones_corp" {
  description = "List of subscription IDs to place under Landing Zones > Corp"
  type        = list(string)
  default     = []
}

variable "subscription_ids_landing_zones_online" {
  description = "List of subscription IDs to place under Landing Zones > Online"
  type        = list(string)
  default     = []
}

variable "subscription_ids_sandbox" {
  description = "List of subscription IDs to place under Sandbox"
  type        = list(string)
  default     = []
}

variable "subscription_ids_decommissioned" {
  description = "List of subscription IDs to place under Decommissioned"
  type        = list(string)
  default     = []
}

variable "additional_management_groups" {
  description = "Additional custom management groups to create under root"
  type = list(object({
    name             = string
    display_name     = string
    subscription_ids = optional(list(string), [])
  }))
  default = []
}
