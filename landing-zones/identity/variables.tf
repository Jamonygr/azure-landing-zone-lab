# =============================================================================
# IDENTITY LANDING ZONE - VARIABLES
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

variable "identity_address_space" {
  description = "Identity VNet address space"
  type        = list(string)
  default     = ["10.1.0.0/16"]
}

variable "dc_subnet_prefix" {
  description = "Domain Controllers subnet prefix"
  type        = string
  default     = "10.1.1.0/24"
}

variable "dns_servers" {
  description = "Custom DNS servers"
  type        = list(string)
  default     = []
}

variable "hub_address_prefix" {
  description = "Hub VNet address prefix for NSG rules"
  type        = string
  default     = "10.0.0.0/16"
}

variable "vm_size" {
  description = "VM size for domain controllers"
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

variable "dc01_ip_address" {
  description = "Static IP for DC01"
  type        = string
  default     = "10.1.1.4"
}

variable "dc02_ip_address" {
  description = "Static IP for DC02"
  type        = string
  default     = "10.1.1.5"
}

variable "deploy_secondary_dc" {
  description = "Deploy secondary domain controller"
  type        = bool
  default     = false
}

variable "enable_auto_shutdown" {
  description = "Enable auto-shutdown"
  type        = bool
  default     = true
}

variable "firewall_private_ip" {
  description = "Azure Firewall private IP for routing"
  type        = string
  default     = null
}

variable "deploy_route_table" {
  description = "Deploy route table via firewall"
  type        = bool
  default     = false
}

variable "onprem_address_prefix" {
  description = "On-premises address prefix for NSG rules"
  type        = string
  default     = "10.100.0.0/16"
}
