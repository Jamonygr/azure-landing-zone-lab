# =============================================================================
# LOCAL NETWORK GATEWAY MODULE - VARIABLES
# =============================================================================

variable "name" {
  description = "Local Network Gateway name"
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

variable "gateway_address" {
  description = "Public IP address of the remote VPN gateway"
  type        = string
}

variable "address_space" {
  description = "Address space of the remote network (on-premises)"
  type        = list(string)
}

variable "tags" {
  description = "Tags to apply"
  type        = map(string)
  default     = {}
}

variable "enable_bgp" {
  description = "Enable BGP"
  type        = bool
  default     = false
}

variable "bgp_asn" {
  description = "BGP ASN"
  type        = number
  default     = 65000
}

variable "bgp_peering_address" {
  description = "BGP peering address"
  type        = string
  default     = null
}
