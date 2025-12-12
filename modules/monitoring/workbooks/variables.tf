# =============================================================================
# AZURE WORKBOOKS MODULE - VARIABLES
# =============================================================================

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "location" {
  description = "Azure region"
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

variable "log_analytics_workspace_id" {
  description = "Log Analytics Workspace ID for queries"
  type        = string
}

variable "deploy_vm_workbook" {
  description = "Deploy VM Performance workbook"
  type        = bool
  default     = true
}

variable "deploy_network_workbook" {
  description = "Deploy Network Traffic workbook"
  type        = bool
  default     = true
}

variable "deploy_firewall_workbook" {
  description = "Deploy Firewall Analytics workbook"
  type        = bool
  default     = true
}
