# =============================================================================
# SECURITY PILLAR - VARIABLES
# Wraps shared services (Key Vault, Storage, SQL) and Private DNS zones
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
  description = "Resource group for shared services"
  type        = string
}

variable "project" {
  description = "Project name prefix"
  type        = string
}

variable "tags" {
  description = "Common tags"
  type        = map(string)
}

variable "tenant_id" {
  description = "Tenant ID (for Key Vault)"
  type        = string
}

# -----------------------------------------------------------------------------
# Networking
# -----------------------------------------------------------------------------

variable "shared_address_space" {
  description = "Shared services VNet address space"
  type        = list(string)
}

variable "app_subnet_prefix" {
  description = "Application subnet prefix"
  type        = string
}

variable "pe_subnet_prefix" {
  description = "Private endpoint subnet prefix"
  type        = string
}

variable "dns_servers" {
  description = "Custom DNS servers"
  type        = list(string)
  default     = []
}

variable "hub_address_prefix" {
  description = "Hub address prefix for NSG rules"
  type        = string
}

variable "firewall_private_ip" {
  description = "Firewall private IP for route table next hop"
  type        = string
  default     = null
}

variable "deploy_route_table" {
  description = "Deploy route table for shared subnets"
  type        = bool
}

# -----------------------------------------------------------------------------
# Deploy toggles
# -----------------------------------------------------------------------------

variable "deploy_keyvault" {
  description = "Deploy Key Vault"
  type        = bool
}

variable "deploy_storage" {
  description = "Deploy Storage Account"
  type        = bool
}

variable "deploy_sql" {
  description = "Deploy SQL Database"
  type        = bool
}

variable "deploy_private_endpoints" {
  description = "Deploy private endpoints"
  type        = bool
}

variable "deploy_private_dns_zones" {
  description = "Deploy private DNS zones for Private Link"
  type        = bool
}

# -----------------------------------------------------------------------------
# Credentials and naming
# -----------------------------------------------------------------------------

variable "admin_password" {
  description = "Admin password (stored in Key Vault)"
  type        = string
  sensitive   = true
}

variable "sql_admin_login" {
  description = "SQL admin login"
  type        = string
}

variable "sql_admin_password" {
  description = "SQL admin password"
  type        = string
  sensitive   = true
}

variable "storage_account_name" {
  description = "Storage account name (must be globally unique)"
  type        = string
}

variable "random_suffix" {
  description = "Random suffix for unique resource names"
  type        = string
}

# -----------------------------------------------------------------------------
# VNet links for Private DNS
# -----------------------------------------------------------------------------

variable "hub_vnet_id" {
  description = "Hub VNet ID for Private DNS linking"
  type        = string
}

variable "identity_vnet_id" {
  description = "Identity VNet ID for Private DNS linking"
  type        = string
}

variable "management_vnet_id" {
  description = "Management VNet ID for Private DNS linking"
  type        = string
}

variable "workload_prod_vnet_id" {
  description = "Workload prod VNet ID for Private DNS linking"
  type        = string
  default     = null
}

variable "workload_dev_vnet_id" {
  description = "Workload dev VNet ID for Private DNS linking"
  type        = string
  default     = null
}

variable "deploy_workload_prod" {
  description = "Whether workload prod is deployed (for static for_each keys)"
  type        = bool
  default     = false
}

variable "deploy_workload_dev" {
  description = "Whether workload dev is deployed (for static for_each keys)"
  type        = bool
  default     = false
}
