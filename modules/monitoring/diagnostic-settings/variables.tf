# Diagnostic Settings Module Variables

variable "diagnostic_name_prefix" {
  description = "Prefix for diagnostic setting names"
  type        = string
  default     = "diag"
}

variable "log_analytics_workspace_id" {
  description = "The ID of the Log Analytics Workspace to send diagnostics to"
  type        = string
}

# Resource IDs
variable "firewall_id" {
  description = "Azure Firewall resource ID"
  type        = string
  default     = ""
}

variable "enable_firewall_diagnostics" {
  description = "Whether to create Firewall diagnostic settings"
  type        = bool
  default     = false
}

variable "vpn_gateway_id" {
  description = "VPN Gateway resource ID"
  type        = string
  default     = ""
}

variable "enable_vpn_diagnostics" {
  description = "Whether to create VPN Gateway diagnostic settings"
  type        = bool
  default     = false
}

variable "aks_cluster_id" {
  description = "AKS cluster resource ID"
  type        = string
  default     = ""
}

variable "enable_aks_diagnostics" {
  description = "Whether to create AKS diagnostic settings"
  type        = bool
  default     = false
}

variable "sql_server_id" {
  description = "SQL Server resource ID"
  type        = string
  default     = ""
}

variable "sql_database_id" {
  description = "SQL Database resource ID"
  type        = string
  default     = ""
}

variable "enable_sql_diagnostics" {
  description = "Whether to create SQL diagnostic settings"
  type        = bool
  default     = false
}

variable "keyvault_id" {
  description = "Key Vault resource ID"
  type        = string
  default     = ""
}

variable "enable_keyvault_diagnostics" {
  description = "Whether to create Key Vault diagnostic settings"
  type        = bool
  default     = false
}

variable "storage_account_id" {
  description = "Storage Account resource ID"
  type        = string
  default     = ""
}

variable "enable_storage_diagnostics" {
  description = "Whether to create Storage diagnostic settings"
  type        = bool
  default     = false
}

variable "nsg_ids" {
  description = "List of Network Security Group resource IDs"
  type        = list(string)
  default     = []
}

variable "enable_nsg_diagnostics" {
  description = "Whether to create NSG diagnostic settings"
  type        = bool
  default     = false
}
