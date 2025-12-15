# =============================================================================
# VIRTUAL NETWORK FLOW LOGS MODULE - VARIABLES
# =============================================================================

variable "name" {
  description = "Name of the VNet Flow Log"
  type        = string
}

variable "location" {
  description = "Azure region for the flow log"
  type        = string
}

variable "virtual_network_id" {
  description = "Resource ID of the Virtual Network to monitor"
  type        = string
}

variable "storage_account_id" {
  description = "Resource ID of the storage account for flow log storage"
  type        = string
}

variable "network_watcher_name" {
  description = "Name of the Network Watcher"
  type        = string
  default     = "NetworkWatcher_eastus"
}

variable "network_watcher_resource_group_name" {
  description = "Resource group name of the Network Watcher"
  type        = string
  default     = "NetworkWatcherRG"
}

variable "create_network_watcher" {
  description = "Create the Network Watcher (and RG) if it does not already exist"
  type        = bool
  default     = false
}

variable "resource_group_name" {
  description = "Resource group name to create the Network Watcher in (when create_network_watcher = true)"
  type        = string
  default     = null
}

variable "enabled" {
  description = "Enable or disable flow logging"
  type        = bool
  default     = true
}

variable "retention_enabled" {
  description = "Enable retention policy"
  type        = bool
  default     = true
}

variable "retention_days" {
  description = "Number of days to retain flow logs"
  type        = number
  default     = 30

  validation {
    condition     = var.retention_days >= 1 && var.retention_days <= 365
    error_message = "Retention days must be between 1 and 365."
  }
}

variable "flow_log_version" {
  description = "Flow log format version (1 or 2)"
  type        = number
  default     = 2

  validation {
    condition     = var.flow_log_version == 1 || var.flow_log_version == 2
    error_message = "Flow log version must be 1 or 2."
  }
}

variable "enable_traffic_analytics" {
  description = "Enable Traffic Analytics for deeper insights"
  type        = bool
  default     = false
}

variable "log_analytics_workspace_guid" {
  description = "GUID (workspace_id) of Log Analytics workspace for Traffic Analytics"
  type        = string
  default     = null
}

variable "log_analytics_workspace_resource_id" {
  description = "Full resource ID of Log Analytics workspace for Traffic Analytics"
  type        = string
  default     = null
}

variable "traffic_analytics_interval" {
  description = "Interval in minutes for Traffic Analytics processing (10 or 60)"
  type        = number
  default     = 60

  validation {
    condition     = var.traffic_analytics_interval == 10 || var.traffic_analytics_interval == 60
    error_message = "Traffic Analytics interval must be 10 or 60 minutes."
  }
}

variable "tags" {
  description = "Tags to apply to the flow log"
  type        = map(string)
  default     = {}
}
