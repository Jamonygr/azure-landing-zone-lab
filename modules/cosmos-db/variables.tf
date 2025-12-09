# =============================================================================
# AZURE COSMOS DB MODULE - Variables
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

variable "kind" {
  description = "Kind of Cosmos DB account (GlobalDocumentDB or MongoDB)"
  type        = string
  default     = "GlobalDocumentDB"
  validation {
    condition     = contains(["GlobalDocumentDB", "MongoDB"], var.kind)
    error_message = "Kind must be 'GlobalDocumentDB' or 'MongoDB'."
  }
}

variable "enable_serverless" {
  description = "Enable serverless capacity mode"
  type        = bool
  default     = true
}

variable "capabilities" {
  description = "List of additional capabilities to enable"
  type        = list(string)
  default     = []
}

variable "consistency_level" {
  description = "Default consistency level for the Cosmos DB account"
  type        = string
  default     = "Session"
  validation {
    condition     = contains(["Strong", "BoundedStaleness", "Session", "ConsistentPrefix", "Eventual"], var.consistency_level)
    error_message = "Invalid consistency level."
  }
}

variable "max_interval_in_seconds" {
  description = "Max interval in seconds for BoundedStaleness consistency"
  type        = number
  default     = 5
}

variable "max_staleness_prefix" {
  description = "Max staleness prefix for BoundedStaleness consistency"
  type        = number
  default     = 100
}

variable "public_network_access_enabled" {
  description = "Enable public network access"
  type        = bool
  default     = true
}

variable "is_virtual_network_filter_enabled" {
  description = "Enable virtual network filtering"
  type        = bool
  default     = false
}

variable "virtual_network_rules" {
  description = "List of virtual network rules"
  type = list(object({
    subnet_id                            = string
    ignore_missing_vnet_service_endpoint = optional(bool, false)
  }))
  default = []
}

variable "sql_databases" {
  description = "List of SQL databases to create"
  type = list(object({
    name = string
  }))
  default = [
    { name = "default-db" }
  ]
}

variable "sql_containers" {
  description = "List of SQL containers to create"
  type = list(object({
    name                = string
    database_name       = string
    partition_key_paths = list(string)
  }))
  default = [
    {
      name                = "default-container"
      database_name       = "default-db"
      partition_key_paths = ["/id"]
    }
  ]
}

variable "mongo_databases" {
  description = "List of MongoDB databases to create"
  type = list(object({
    name = string
  }))
  default = []
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

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
