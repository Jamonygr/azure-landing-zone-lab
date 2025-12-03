# =============================================================================
# SUBNET MODULE - VARIABLES
# =============================================================================

variable "name" {
  description = "Subnet name"
  type        = string
}

variable "resource_group_name" {
  description = "Resource group name"
  type        = string
}

variable "virtual_network_name" {
  description = "VNet name"
  type        = string
}

variable "address_prefixes" {
  description = "Subnet address prefixes"
  type        = list(string)
}

variable "service_endpoints" {
  description = "Service endpoints to enable"
  type        = list(string)
  default     = []
}

variable "private_endpoint_network_policies_enabled" {
  description = "Enable network policies for private endpoints"
  type        = bool
  default     = true
}

variable "delegation" {
  description = "Subnet delegation configuration"
  type = object({
    name = string
    service_delegation = object({
      name    = string
      actions = list(string)
    })
  })
  default = null
}
