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
  description = "Time to start VMs in 24-hour HH:MM format"
  type        = string
  default     = "08:00"

  validation {
    condition     = can(regex("^(?:[01][0-9]|2[0-3]):[0-5][0-9]$", var.start_time))
    error_message = "start_time must use 24-hour HH:MM format."
  }
}

variable "stop_time" {
  description = "Time to stop VMs in 24-hour HH:MM format"
  type        = string
  default     = "19:00"

  validation {
    condition     = can(regex("^(?:[01][0-9]|2[0-3]):[0-5][0-9]$", var.stop_time))
    error_message = "stop_time must use 24-hour HH:MM format."
  }
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
