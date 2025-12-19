# =============================================================================
# IDENTITY MANAGEMENT PILLAR - VARIABLES
# Wraps the identity landing zone (AD DS, DCs)
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
  description = "Resource group for identity resources"
  type        = string
}

variable "tags" {
  description = "Common tags"
  type        = map(string)
}

variable "identity_address_space" {
  description = "Identity VNet address space"
  type        = list(string)
}

variable "dc_subnet_prefix" {
  description = "DC subnet prefix"
  type        = string
}

variable "dns_servers" {
  description = "DNS servers for the VNet (optional)"
  type        = list(string)
  default     = []
}

variable "hub_address_prefix" {
  description = "Hub address prefix for NSG rules"
  type        = string
}

variable "onprem_address_prefix" {
  description = "On-premises address prefix (simulated)"
  type        = string
}

variable "vm_size" {
  description = "VM size for domain controllers"
  type        = string
}

variable "admin_username" {
  description = "Admin username"
  type        = string
}

variable "admin_password" {
  description = "Admin password"
  type        = string
  sensitive   = true
}

variable "dc01_ip_address" {
  description = "DC01 static IP"
  type        = string
}

variable "dc02_ip_address" {
  description = "DC02 static IP"
  type        = string
}

variable "deploy_secondary_dc" {
  description = "Deploy secondary domain controller"
  type        = bool
}

variable "enable_auto_shutdown" {
  description = "Enable VM auto-shutdown"
  type        = bool
}

variable "firewall_private_ip" {
  description = "Hub firewall private IP (for route table)"
  type        = string
  default     = null
}

variable "deploy_route_table" {
  description = "Deploy route table for identity subnet"
  type        = bool
}
