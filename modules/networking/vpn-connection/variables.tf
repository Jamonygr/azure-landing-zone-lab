# =============================================================================
# VPN CONNECTION MODULE - VARIABLES
# =============================================================================

variable "name" {
  description = "Connection name"
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

variable "type" {
  description = "Connection type (Vnet2Vnet, IPsec, ExpressRoute)"
  type        = string
  default     = "Vnet2Vnet"
}

variable "virtual_network_gateway_id" {
  description = "First VPN Gateway ID"
  type        = string
}

variable "peer_virtual_network_gateway_id" {
  description = "Second VPN Gateway ID (for Vnet2Vnet)"
  type        = string
  default     = null
}

variable "local_network_gateway_id" {
  description = "Local Network Gateway ID (for IPsec)"
  type        = string
  default     = null
}

variable "shared_key" {
  description = "Shared key for the VPN connection"
  type        = string
  sensitive   = true
}

variable "enable_bgp" {
  description = "Enable BGP for the connection"
  type        = bool
  default     = false
}
