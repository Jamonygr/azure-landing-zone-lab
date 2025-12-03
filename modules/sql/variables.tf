# =============================================================================
# AZURE SQL DATABASE MODULE - VARIABLES
# =============================================================================

variable "server_name" {
  description = "SQL Server name"
  type        = string
}

variable "database_name" {
  description = "SQL Database name"
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

variable "admin_login" {
  description = "SQL admin login"
  type        = string
  default     = "sqladmin"
}

variable "admin_password" {
  description = "SQL admin password"
  type        = string
  sensitive   = true
}

variable "sku_name" {
  description = "Database SKU name"
  type        = string
  default     = "Basic" # Cheapest: ~$5/month
}

variable "max_size_gb" {
  description = "Maximum database size in GB"
  type        = number
  default     = 2 # Basic tier limit
}

variable "min_tls_version" {
  description = "Minimum TLS version"
  type        = string
  default     = "1.2"
}

variable "public_network_access_enabled" {
  description = "Enable public network access"
  type        = bool
  default     = true # For lab simplicity
}

variable "allowed_ip_addresses" {
  description = "IP addresses allowed to access SQL Server"
  type = list(object({
    name             = string
    start_ip_address = string
    end_ip_address   = string
  }))
  default = []
}

variable "allow_azure_services" {
  description = "Allow Azure services to access"
  type        = bool
  default     = true
}

variable "azuread_admin" {
  description = "Azure AD admin configuration"
  type = object({
    login_username = string
    object_id      = string
  })
  default = null
}
