# =============================================================================
# HUB LANDING ZONE - VARIABLES
# =============================================================================

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "location_short" {
  description = "Short location code"
  type        = string
}

variable "resource_group_name" {
  description = "Resource group name"
  type        = string
}

variable "tags" {
  description = "Tags to apply"
  type        = map(string)
  default     = {}
}

variable "hub_address_space" {
  description = "Hub VNet address space"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "gateway_subnet_prefix" {
  description = "Gateway subnet prefix"
  type        = string
  default     = "10.0.0.0/24"
}

variable "firewall_subnet_prefix" {
  description = "Firewall subnet prefix"
  type        = string
  default     = "10.0.1.0/24"
}

variable "hub_mgmt_subnet_prefix" {
  description = "Hub management subnet prefix"
  type        = string
  default     = "10.0.2.0/24"
}

variable "dns_servers" {
  description = "Custom DNS servers"
  type        = list(string)
  default     = []
}

variable "deploy_firewall" {
  description = "Deploy Azure Firewall"
  type        = bool
  default     = true
}

variable "firewall_sku_tier" {
  description = "Firewall SKU tier"
  type        = string
  default     = "Standard"
}

variable "deploy_vpn_gateway" {
  description = "Deploy VPN Gateway"
  type        = bool
  default     = true
}

variable "vpn_gateway_sku" {
  description = "VPN Gateway SKU"
  type        = string
  default     = "VpnGw1"
}

variable "enable_bgp" {
  description = "Enable BGP on VPN Gateway"
  type        = bool
  default     = false
}

variable "hub_bgp_asn" {
  description = "BGP ASN for hub"
  type        = number
  default     = 65515
}

variable "vpn_client_address_pool" {
  description = "VPN client address pool"
  type        = string
  default     = "172.16.0.0/24"
}

variable "identity_address_space" {
  description = "Identity spoke address space for gateway routing"
  type        = string
  default     = "10.1.0.0/16"
}

variable "management_address_space" {
  description = "Management spoke address space for gateway routing"
  type        = string
  default     = "10.2.0.0/16"
}

variable "shared_services_address_space" {
  description = "Shared services spoke address space for gateway routing"
  type        = string
  default     = "10.3.0.0/16"
}

variable "workload_address_space" {
  description = "Workload spoke address space for gateway routing"
  type        = string
  default     = "10.10.0.0/16"
}
