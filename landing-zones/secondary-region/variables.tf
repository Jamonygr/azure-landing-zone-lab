# =============================================================================
# SECONDARY REGION LANDING ZONE - VARIABLES
# =============================================================================

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "location" {
  description = "Azure region for secondary hub"
  type        = string
  default     = "westeurope"
}

variable "location_short" {
  description = "Short location code"
  type        = string
  default     = "weu"
}

variable "tags" {
  description = "Tags to apply"
  type        = map(string)
  default     = {}
}

# -----------------------------------------------------------------------------
# Network Configuration
# -----------------------------------------------------------------------------

variable "address_space" {
  description = "Secondary hub VNet address space"
  type        = list(string)
  default     = ["10.50.0.0/16"]
}

variable "mgmt_subnet_prefix" {
  description = "Management subnet prefix"
  type        = string
  default     = "10.50.1.0/24"
}

# -----------------------------------------------------------------------------
# Primary Hub Connection
# -----------------------------------------------------------------------------

variable "primary_hub_vnet_id" {
  description = "Primary hub VNet ID for peering"
  type        = string
}

variable "primary_hub_vnet_name" {
  description = "Primary hub VNet name"
  type        = string
}

variable "primary_hub_resource_group" {
  description = "Primary hub resource group name"
  type        = string
}

variable "primary_hub_address_space" {
  description = "Primary hub address space for NSG rules"
  type        = string
  default     = "10.0.0.0/16"
}

variable "primary_has_gateway" {
  description = "Whether primary hub has a VPN/ExpressRoute gateway"
  type        = bool
  default     = false
}

variable "use_remote_gateways" {
  description = "Use remote gateways from primary hub (requires gateway)"
  type        = bool
  default     = false
}

# -----------------------------------------------------------------------------
# VM Configuration
# -----------------------------------------------------------------------------

variable "deploy_vm" {
  description = "Deploy Windows Server 2025 VM in secondary region"
  type        = bool
  default     = true
}

variable "vm_name" {
  description = "VM name"
  type        = string
  default     = "vm-secondary-01"
}

variable "vm_size" {
  description = "VM size (smallest Windows-capable)"
  type        = string
  default     = "Standard_B1s"
}

variable "windows_sku" {
  description = "Windows Server SKU"
  type        = string
  default     = "2025-datacenter-core-smalldisk-g2"
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
  description = "Enable auto-shutdown for cost savings"
  type        = bool
  default     = true
}
