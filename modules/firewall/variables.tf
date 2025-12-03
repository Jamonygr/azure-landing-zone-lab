# =============================================================================
# AZURE FIREWALL MODULE - VARIABLES
# =============================================================================

variable "name" {
  description = "Azure Firewall name"
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

variable "subnet_id" {
  description = "AzureFirewallSubnet ID"
  type        = string
}

variable "sku_name" {
  description = "Firewall SKU name"
  type        = string
  default     = "AZFW_VNet"
}

variable "sku_tier" {
  description = "Firewall SKU tier (Standard or Premium)"
  type        = string
  default     = "Standard"
}

variable "threat_intel_mode" {
  description = "Threat intelligence mode"
  type        = string
  default     = "Alert"
}

variable "policy_name" {
  description = "Firewall policy name"
  type        = string
  default     = null
}

variable "dns_servers" {
  description = "Custom DNS servers for the firewall policy"
  type        = list(string)
  default     = []
}

variable "dns_proxy_enabled" {
  description = "Enable DNS proxy on the firewall"
  type        = bool
  default     = true
}
