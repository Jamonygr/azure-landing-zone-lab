# =============================================================================
# VPN GATEWAY MODULE - VARIABLES
# =============================================================================

variable "name" {
  description = "VPN Gateway name"
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

variable "subnet_id" {
  description = "Gateway Subnet ID (must be named GatewaySubnet)"
  type        = string
}

variable "sku" {
  description = "VPN Gateway SKU"
  type        = string
  default     = "VpnGw1" # Cheapest production SKU
}

variable "type" {
  description = "VPN type (RouteBased or PolicyBased)"
  type        = string
  default     = "RouteBased"
}

variable "vpn_type" {
  description = "VPN generation"
  type        = string
  default     = "Generation1"
}

variable "active_active" {
  description = "Enable active-active mode"
  type        = bool
  default     = false
}

variable "enable_bgp" {
  description = "Enable BGP"
  type        = bool
  default     = false
}

variable "bgp_asn" {
  description = "BGP ASN"
  type        = number
  default     = 65515
}

variable "pip_name" {
  description = "Public IP name"
  type        = string
  default     = null
}
