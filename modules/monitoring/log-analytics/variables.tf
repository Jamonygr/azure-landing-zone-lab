# =============================================================================
# LOG ANALYTICS WORKSPACE MODULE - VARIABLES
# =============================================================================

variable "name" {
  description = "Log Analytics Workspace name"
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

variable "sku" {
  description = "SKU (PerGB2018 is pay-as-you-go)"
  type        = string
  default     = "PerGB2018"
}

variable "retention_in_days" {
  description = "Data retention in days (30 is free)"
  type        = number
  default     = 30 # Free tier
}

variable "daily_quota_gb" {
  description = "Daily ingestion quota in GB (-1 for unlimited)"
  type        = number
  default     = 1 # Limit for lab cost control
}
