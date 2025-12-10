# =============================================================================
# PRIVATE DNS ZONE MODULE - VARIABLES
# =============================================================================

variable "zone_name" {
  description = "The name of the Private DNS Zone (e.g., privatelink.blob.core.windows.net)"
  type        = string
}

variable "resource_group_name" {
  description = "Resource group name"
  type        = string
}

variable "virtual_network_links" {
  description = "Map of VNet links to create. Key is the link name, value contains vnet_id and registration_enabled"
  type = map(object({
    vnet_id              = string
    registration_enabled = optional(bool, false)
  }))
  default = {}
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
