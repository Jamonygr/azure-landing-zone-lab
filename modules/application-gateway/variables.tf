# =============================================================================
# AZURE APPLICATION GATEWAY MODULE - Variables
# =============================================================================

variable "name_suffix" {
  description = "Suffix for naming resources (typically includes environment and region)"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region for resources"
  type        = string
}

variable "subnet_id" {
  description = "ID of the subnet for the Application Gateway"
  type        = string
}

variable "zones" {
  description = "Availability zones for the Application Gateway"
  type        = list(string)
  default     = ["1", "2", "3"]
}

variable "sku_name" {
  description = "SKU name for the Application Gateway"
  type        = string
  default     = "WAF_v2"
  validation {
    condition     = contains(["Standard_v2", "WAF_v2"], var.sku_name)
    error_message = "SKU name must be 'Standard_v2' or 'WAF_v2'."
  }
}

variable "sku_tier" {
  description = "SKU tier for the Application Gateway"
  type        = string
  default     = "WAF_v2"
  validation {
    condition     = contains(["Standard_v2", "WAF_v2"], var.sku_tier)
    error_message = "SKU tier must be 'Standard_v2' or 'WAF_v2'."
  }
}

variable "capacity" {
  description = "Instance count for the Application Gateway (used when autoscale is not configured)"
  type        = number
  default     = 2
}

variable "autoscale_configuration" {
  description = "Autoscale configuration for the Application Gateway"
  type = object({
    min_capacity = number
    max_capacity = number
  })
  default = null
}

variable "private_ip_address" {
  description = "Private IP address for the Application Gateway"
  type        = string
  default     = null
}

variable "enable_key_vault_integration" {
  description = "Enable Key Vault integration with user-assigned managed identity"
  type        = bool
  default     = false
}

variable "backend_pools" {
  description = "Map of backend address pools"
  type = map(object({
    fqdns        = optional(list(string))
    ip_addresses = optional(list(string))
  }))
  default = {}
}

variable "backend_http_settings" {
  description = "Map of backend HTTP settings"
  type = map(object({
    port                                = number
    protocol                            = string
    cookie_based_affinity               = optional(string, "Disabled")
    request_timeout                     = optional(number, 30)
    probe_name                          = optional(string)
    pick_host_name_from_backend_address = optional(bool, false)
  }))
  default = {}
}

variable "http_listeners" {
  description = "Map of HTTP listeners"
  type = map(object({
    frontend_ip_configuration_name = optional(string, "frontend-ip-public")
    frontend_port_name             = string
    protocol                       = string
    host_name                      = optional(string)
    ssl_certificate_name           = optional(string)
  }))
  default = {}
}

variable "routing_rules" {
  description = "Map of request routing rules"
  type = map(object({
    priority                    = number
    rule_type                   = string
    http_listener_name          = string
    backend_address_pool_name   = optional(string)
    backend_http_settings_name  = optional(string)
    url_path_map_name           = optional(string)
    redirect_configuration_name = optional(string)
  }))
  default = {}
}

variable "health_probes" {
  description = "Map of health probes"
  type = map(object({
    protocol                                  = string
    path                                      = string
    host                                      = optional(string)
    interval                                  = optional(number, 30)
    timeout                                   = optional(number, 30)
    unhealthy_threshold                       = optional(number, 3)
    pick_host_name_from_backend_http_settings = optional(bool, false)
  }))
  default = {}
}

variable "waf_configuration" {
  description = "WAF configuration for WAF_v2 SKU"
  type = object({
    enabled                  = bool
    firewall_mode            = string
    rule_set_type            = string
    rule_set_version         = string
    file_upload_limit_mb     = optional(number, 100)
    max_request_body_size_kb = optional(number, 128)
  })
  default = {
    enabled          = true
    firewall_mode    = "Detection"
    rule_set_type    = "OWASP"
    rule_set_version = "3.2"
  }
}

variable "log_analytics_workspace_id" {
  description = "Log Analytics Workspace ID for diagnostic settings"
  type        = string
  default     = null
}

variable "enable_diagnostics" {
  description = "Enable diagnostic settings (set to true when log_analytics_workspace_id will be provided)"
  type        = bool
  default     = false
}

variable "default_backend_pool_name" {
  description = "Name of the backend pool to use in the default routing rule"
  type        = string
  default     = "default-backend-pool"
}

variable "default_backend_http_settings_name" {
  description = "Name of the backend HTTP settings to use in the default routing rule"
  type        = string
  default     = "default-http-settings"
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
