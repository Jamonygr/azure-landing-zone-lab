# =============================================================================
# AZURE AUTOMATION MODULE - VARIABLES
# =============================================================================

variable "automation_account_name" {
  description = "Name of the Automation Account"
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

variable "subscription_id" {
  description = "Subscription ID for role assignment scope"
  type        = string
}

variable "tags" {
  description = "Tags to apply"
  type        = map(string)
  default     = {}
}

# -----------------------------------------------------------------------------
# Resource Groups to Manage
# -----------------------------------------------------------------------------

variable "resource_group_names" {
  description = "Resource groups containing VMs to start/stop"
  type        = list(string)
  default     = []
}

variable "exclude_vms_from_stop" {
  description = "VMs to exclude from scheduled stop (e.g., domain controllers)"
  type        = list(string)
  default     = []
}

# -----------------------------------------------------------------------------
# Schedule Configuration
# -----------------------------------------------------------------------------

variable "timezone" {
  description = "Timezone for schedules"
  type        = string
  default     = "UTC"
}

variable "enable_start_schedule" {
  description = "Enable morning start schedule"
  type        = bool
  default     = true
}

variable "enable_stop_schedule" {
  description = "Enable evening stop schedule"
  type        = bool
  default     = true
}

variable "start_time" {
  description = "Time to start VMs (RFC3339 format, e.g., 2024-01-01T08:00:00Z)"
  type        = string
  default     = "2025-01-01T08:00:00Z"
}

variable "stop_time" {
  description = "Time to stop VMs (RFC3339 format, e.g., 2024-01-01T19:00:00Z)"
  type        = string
  default     = "2025-01-01T19:00:00Z"
}

variable "start_days" {
  description = "Days to run start schedule"
  type        = list(string)
  default     = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"]
}

variable "stop_days" {
  description = "Days to run stop schedule"
  type        = list(string)
  default     = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"]
}
