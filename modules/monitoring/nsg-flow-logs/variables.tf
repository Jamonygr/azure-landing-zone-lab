# =============================================================================
# NSG FLOW LOGS MODULE - VARIABLES
# =============================================================================

variable "name" {
  description = "Name of the NSG Flow Log"
  type        = string
}

variable "resource_group_name" {
  description = "Resource group name for the Network Watcher (if creating)"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "network_security_group_id" {
  description = "The ID of the NSG to enable flow logs for"
  type        = string
}

variable "storage_account_id" {
  description = "The ID of the Storage Account for flow logs"
  type        = string
}

variable "network_watcher_name" {
  description = "Name of the Network Watcher"
  type        = string
  default     = "NetworkWatcher"
}

variable "network_watcher_resource_group_name" {
  description = "Resource group of existing Network Watcher (e.g., NetworkWatcherRG)"
  type        = string
  default     = "NetworkWatcherRG"
}

variable "create_network_watcher" {
  description = "Whether to create a new Network Watcher or use existing"
  type        = bool
  default     = false
}

variable "enabled" {
  description = "Enable or disable flow logs"
  type        = bool
  default     = true
}

variable "flow_log_version" {
  description = "Flow log version (1 or 2). Version 2 includes bytes and packets per flow"
  type        = number
  default     = 2
}

variable "retention_enabled" {
  description = "Enable retention policy"
  type        = bool
  default     = true
}

variable "retention_days" {
  description = "Number of days to retain flow logs"
  type        = number
  default     = 7
}

# Traffic Analytics settings
variable "enable_traffic_analytics" {
  description = "Enable Traffic Analytics for visualization"
  type        = bool
  default     = false
}

variable "log_analytics_workspace_id" {
  description = "Log Analytics Workspace GUID (workspace_id) for Traffic Analytics"
  type        = string
  default     = null
}

variable "log_analytics_workspace_resource_id" {
  description = "Log Analytics Workspace resource ID for Traffic Analytics"
  type        = string
  default     = null
}

variable "traffic_analytics_interval" {
  description = "Traffic Analytics processing interval in minutes (10 or 60)"
  type        = number
  default     = 60
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
