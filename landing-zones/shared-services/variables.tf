# =============================================================================
# SHARED SERVICES LANDING ZONE - VARIABLES
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

variable "project" {
  description = "Project name"
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

variable "tenant_id" {
  description = "Azure AD Tenant ID"
  type        = string
}

variable "shared_address_space" {
  description = "Shared Services VNet address space"
  type        = list(string)
  default     = ["10.3.0.0/16"]
}

variable "app_subnet_prefix" {
  description = "Application subnet prefix"
  type        = string
  default     = "10.3.1.0/24"
}

variable "pe_subnet_prefix" {
  description = "Private Endpoint subnet prefix"
  type        = string
  default     = "10.3.2.0/24"
}

variable "dns_servers" {
  description = "Custom DNS servers"
  type        = list(string)
  default     = []
}

variable "hub_address_prefix" {
  description = "Hub VNet address prefix"
  type        = string
  default     = "10.0.0.0/16"
}

variable "admin_password" {
  description = "Admin password for Key Vault secret"
  type        = string
  sensitive   = true
}

variable "deploy_keyvault" {
  description = "Deploy Key Vault"
  type        = bool
  default     = true
}

variable "deploy_storage" {
  description = "Deploy Storage Account"
  type        = bool
  default     = true
}

variable "storage_account_name" {
  description = "Storage account name"
  type        = string
}

variable "deploy_sql" {
  description = "Deploy Azure SQL"
  type        = bool
  default     = true
}

variable "sql_admin_login" {
  description = "SQL admin login"
  type        = string
  default     = "sqladmin"
}

variable "sql_admin_password" {
  description = "SQL admin password"
  type        = string
  sensitive   = true
}

variable "firewall_private_ip" {
  description = "Azure Firewall private IP"
  type        = string
  default     = null
}

variable "deploy_route_table" {
  description = "Deploy route table via firewall"
  type        = bool
  default     = false
}

variable "random_suffix" {
  description = "Random suffix for globally unique names"
  type        = string
  default     = ""
}

# -----------------------------------------------------------------------------
# Private Endpoints Configuration
# -----------------------------------------------------------------------------

variable "deploy_private_endpoints" {
  description = "Deploy Private Endpoints for Key Vault, Storage, and SQL"
  type        = bool
  default     = false
}

variable "private_dns_zone_blob_id" {
  description = "Private DNS Zone ID for Azure Blob Storage"
  type        = string
  default     = null
}

variable "private_dns_zone_keyvault_id" {
  description = "Private DNS Zone ID for Azure Key Vault"
  type        = string
  default     = null
}

variable "private_dns_zone_sql_id" {
  description = "Private DNS Zone ID for Azure SQL"
  type        = string
  default     = null
}
