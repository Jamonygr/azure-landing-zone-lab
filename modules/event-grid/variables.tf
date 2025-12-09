# =============================================================================
# AZURE EVENT GRID MODULE - Variables
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

variable "create_custom_topic" {
  description = "Create a custom Event Grid topic"
  type        = bool
  default     = true
}

variable "create_system_topic" {
  description = "Create a system Event Grid topic"
  type        = bool
  default     = false
}

variable "input_schema" {
  description = "Input schema for the custom topic"
  type        = string
  default     = "EventGridSchema"
  validation {
    condition     = contains(["EventGridSchema", "CloudEventSchemaV1_0", "CustomEventSchema"], var.input_schema)
    error_message = "Input schema must be 'EventGridSchema', 'CloudEventSchemaV1_0', or 'CustomEventSchema'."
  }
}

variable "public_network_access_enabled" {
  description = "Enable public network access"
  type        = bool
  default     = true
}

variable "source_arm_resource_id" {
  description = "ARM resource ID for the system topic source (required for system topics)"
  type        = string
  default     = null
}

variable "topic_type" {
  description = "Topic type for system topics (e.g., Microsoft.Storage.StorageAccounts)"
  type        = string
  default     = null
}

variable "webhook_endpoint_url" {
  description = "Webhook URL for event subscription"
  type        = string
  default     = null
}

variable "storage_queue_endpoint" {
  description = "Storage queue endpoint configuration"
  type = object({
    storage_account_id = string
    queue_name         = string
  })
  default = null
}

variable "included_event_types" {
  description = "List of event types to include in subscription"
  type        = list(string)
  default     = []
}

variable "max_delivery_attempts" {
  description = "Maximum number of delivery attempts"
  type        = number
  default     = 30
}

variable "event_time_to_live" {
  description = "Event time to live in minutes"
  type        = number
  default     = 1440
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
