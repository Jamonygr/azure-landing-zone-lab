# =============================================================================
# NETWORKING PILLAR - VARIABLES
# Wraps the hub landing zone (VNet, Firewall, VPN, App Gateway) and firewall rules
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
  description = "Short code for the Azure region"
  type        = string
}

variable "resource_group_name" {
  description = "Resource group to host hub networking resources"
  type        = string
}

variable "tags" {
  description = "Common tags"
  type        = map(string)
}

# -----------------------------------------------------------------------------
# Hub address spaces and subnets
# -----------------------------------------------------------------------------

variable "hub_address_space" {
  description = "Hub VNet address space"
  type        = list(string)
}

variable "gateway_subnet_prefix" {
  description = "Hub Gateway subnet prefix"
  type        = string
}

variable "firewall_subnet_prefix" {
  description = "Hub Firewall subnet prefix"
  type        = string
}

variable "hub_mgmt_subnet_prefix" {
  description = "Hub management subnet prefix"
  type        = string
}

variable "hub_appgw_subnet_prefix" {
  description = "Hub Application Gateway subnet prefix"
  type        = string
}

# -----------------------------------------------------------------------------
# Deployment toggles and SKUs
# -----------------------------------------------------------------------------

variable "deploy_firewall" {
  description = "Deploy Azure Firewall"
  type        = bool
}

variable "firewall_sku_tier" {
  description = "Azure Firewall SKU tier"
  type        = string
}

variable "deploy_vpn_gateway" {
  description = "Deploy VPN gateway"
  type        = bool
}

variable "vpn_gateway_sku" {
  description = "VPN gateway SKU"
  type        = string
}

variable "enable_bgp" {
  description = "Enable BGP on VPN gateway"
  type        = bool
}

variable "hub_bgp_asn" {
  description = "Hub BGP ASN"
  type        = number
}

variable "deploy_application_gateway" {
  description = "Deploy Application Gateway"
  type        = bool
}

variable "appgw_waf_mode" {
  description = "Application Gateway WAF mode"
  type        = string
}

# -----------------------------------------------------------------------------
# Connectivity inputs for firewall rules
# -----------------------------------------------------------------------------

variable "vpn_client_address_pool" {
  description = "Point-to-site VPN client address pool"
  type        = string
}

variable "identity_address_space" {
  description = "Identity VNet address space (for gateway routes)"
  type        = list(string)
}

variable "management_address_space" {
  description = "Management VNet address space (for gateway routes)"
  type        = list(string)
}

variable "shared_address_space" {
  description = "Shared services VNet address space (for gateway routes)"
  type        = list(string)
}

variable "workload_address_space" {
  description = "Workload VNet address space (for gateway routes)"
  type        = list(string)
}

variable "dc01_ip_address" {
  description = "DC01 static IP (for firewall rules)"
  type        = string
}

variable "dc02_ip_address" {
  description = "DC02 static IP (for firewall rules, optional)"
  type        = string
}

# -----------------------------------------------------------------------------
# Optional backend IPs for App Gateway (kept empty initially)
# -----------------------------------------------------------------------------

variable "lb_backend_ips" {
  description = "Backend IPs for Application Gateway pool (populated later)"
  type        = list(string)
  default     = []
}
