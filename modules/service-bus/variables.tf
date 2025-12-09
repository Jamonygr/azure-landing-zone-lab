# =============================================================================
# AZURE SERVICE BUS MODULE - Variables
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

variable "sku" {
  description = "SKU for the Service Bus Namespace"
  type        = string
  default     = "Basic"
  validation {
    condition     = contains(["Basic", "Standard", "Premium"], var.sku)
    error_message = "SKU must be 'Basic', 'Standard', or 'Premium'."
  }
}

variable "local_auth_enabled" {
  description = "Enable local authentication"
  type        = bool
  default     = true
}

variable "public_network_access_enabled" {
  description = "Enable public network access"
  type        = bool
  default     = true
}

variable "queues" {
  description = "Map of queue configurations"
  type = map(object({
    max_delivery_count                   = optional(number, 10)
    max_size_in_megabytes                = optional(number, 1024)
    default_message_ttl                  = optional(string)
    lock_duration                        = optional(string, "PT1M")
    dead_lettering_on_message_expiration = optional(bool, false)
    enable_partitioning                  = optional(bool, false)
  }))
  default = {
    "default-queue" = {}
  }
}

variable "topics" {
  description = "Map of topic configurations (Standard/Premium only)"
  type = map(object({
    max_size_in_megabytes         = optional(number, 1024)
    default_message_ttl           = optional(string)
    enable_partitioning           = optional(bool, false)
    support_ordering              = optional(bool, false)
    max_message_size_in_kilobytes = optional(number, 1024)
  }))
  default = {}
}

variable "subscriptions" {
  description = "Map of subscription configurations"
  type = map(object({
    name                                 = string
    topic_name                           = string
    max_delivery_count                   = optional(number, 10)
    default_message_ttl                  = optional(string)
    lock_duration                        = optional(string, "PT1M")
    dead_lettering_on_message_expiration = optional(bool, false)
  }))
  default = {}
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
