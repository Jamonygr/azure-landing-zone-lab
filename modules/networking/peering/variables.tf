# =============================================================================
# VNET PEERING MODULE - VARIABLES
# =============================================================================

variable "name_prefix" {
  description = "Prefix for peering names"
  type        = string
  default     = "peer"
}

variable "resource_group_name" {
  description = "Resource group name"
  type        = string
}

variable "vnet_1_id" {
  description = "First VNet ID"
  type        = string
}

variable "vnet_1_name" {
  description = "First VNet name"
  type        = string
}

variable "vnet_2_id" {
  description = "Second VNet ID"
  type        = string
}

variable "vnet_2_name" {
  description = "Second VNet name"
  type        = string
}

variable "vnet_2_resource_group_name" {
  description = "Resource group name for second VNet (if different)"
  type        = string
  default     = null
}

variable "allow_virtual_network_access" {
  description = "Allow access from remote VNet"
  type        = bool
  default     = true
}

variable "allow_forwarded_traffic" {
  description = "Allow forwarded traffic"
  type        = bool
  default     = true
}

variable "allow_gateway_transit_vnet1" {
  description = "Allow gateway transit from VNet 1"
  type        = bool
  default     = false
}

variable "use_remote_gateways_vnet2" {
  description = "Use remote gateways for VNet 2"
  type        = bool
  default     = false
}
