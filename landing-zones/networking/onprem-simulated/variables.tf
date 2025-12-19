# =============================================================================
# SIMULATED ON-PREMISES - VARIABLES
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

variable "onprem_address_space" {
  description = "On-Premises VNet address space"
  type        = list(string)
  default     = ["10.100.0.0/16"]
}

variable "gateway_subnet_prefix" {
  description = "Gateway subnet prefix"
  type        = string
  default     = "10.100.0.0/24"
}

variable "servers_subnet_prefix" {
  description = "Servers subnet prefix"
  type        = string
  default     = "10.100.1.0/24"
}

variable "vpn_gateway_sku" {
  description = "VPN Gateway SKU"
  type        = string
  default     = "VpnGw1"
}

variable "enable_bgp" {
  description = "Enable BGP"
  type        = bool
  default     = false
}

variable "onprem_bgp_asn" {
  description = "On-Prem BGP ASN"
  type        = number
  default     = 65050
}

variable "hub_vpn_gateway_id" {
  description = "Hub VPN Gateway ID (not used for IPsec, kept for compatibility)"
  type        = string
  default     = null
}

variable "hub_vpn_gateway_public_ip" {
  description = "Hub VPN Gateway Public IP address"
  type        = string
  default     = null
}

variable "hub_address_spaces" {
  description = "All address spaces reachable via the Hub (for Local Network Gateway)"
  type        = list(string)
  default     = []
}

variable "hub_bgp_asn" {
  description = "Hub BGP ASN"
  type        = number
  default     = 65515
}

variable "hub_bgp_peering_address" {
  description = "Hub VPN Gateway BGP peering address"
  type        = string
  default     = null
}

variable "deploy_vpn_connection" {
  description = "Deploy VPN connection to hub"
  type        = bool
  default     = false
}

variable "vpn_shared_key" {
  description = "VPN shared key"
  type        = string
  sensitive   = true
}

variable "vm_size" {
  description = "VM size"
  type        = string
  default     = "Standard_B2s"
}

variable "admin_username" {
  description = "Admin username"
  type        = string
  default     = "azureadmin"
}

variable "admin_password" {
  description = "Admin password"
  type        = string
  sensitive   = true
}

variable "enable_auto_shutdown" {
  description = "Enable auto-shutdown"
  type        = bool
  default     = true
}

variable "allowed_rdp_source_ips" {
  description = "List of IP addresses/CIDR ranges allowed to RDP to management VM. Use your public IP for security."
  type        = list(string)
  default     = [] # Empty means no RDP from internet - must be explicitly set
}

variable "deploy_vpn_gateway" {
  description = "Deploy the on-prem VPN gateway"
  type        = bool
  default     = true
}
