# =============================================================================
# COST MANAGEMENT MODULE - VARIABLES
# =============================================================================

variable "scope" {
  description = "The scope for cost management resources (subscription ID or resource group ID)"
  type        = string
}

variable "environment" {
  description = "Environment name for naming conventions"
  type        = string
}

variable "location" {
  description = "Azure region (used only for action group location)"
  type        = string
  default     = "global"
}

variable "resource_group_name" {
  description = "Resource group name for the action group (required for subscription-level scope)"
  type        = string
}

# -----------------------------------------------------------------------------
# Budget Configuration
# -----------------------------------------------------------------------------

variable "enable_budget" {
  description = "Enable cost budget with alerts"
  type        = bool
  default     = true
}

variable "budget_name" {
  description = "Name of the budget"
  type        = string
  default     = "monthly-budget"
}

variable "budget_amount" {
  description = "Monthly budget amount in USD"
  type        = number
  default     = 1000
}

variable "budget_time_grain" {
  description = "Budget time grain (Monthly, Quarterly, Annually)"
  type        = string
  default     = "Monthly"

  validation {
    condition     = contains(["Monthly", "Quarterly", "Annually"], var.budget_time_grain)
    error_message = "Budget time grain must be Monthly, Quarterly, or Annually."
  }
}

variable "budget_start_date" {
  description = "Budget start date in YYYY-MM-DD format (first of month)"
  type        = string
  default     = null # Will be calculated if not provided
}

variable "budget_end_date" {
  description = "Budget end date in YYYY-MM-DD format (optional, defaults to 5 years)"
  type        = string
  default     = null
}

# -----------------------------------------------------------------------------
# Alert Thresholds
# -----------------------------------------------------------------------------

variable "alert_thresholds" {
  description = "List of budget alert thresholds and their configuration"
  type = list(object({
    threshold         = number
    threshold_type    = optional(string, "Actual") # Actual or Forecasted
    operator          = optional(string, "GreaterThanOrEqualTo")
    contact_emails    = optional(list(string), [])
    contact_roles     = optional(list(string), ["Owner"])
    contact_groups    = optional(list(string), [])
  }))
  default = [
    {
      threshold      = 50
      threshold_type = "Actual"
      contact_roles  = ["Owner"]
    },
    {
      threshold      = 75
      threshold_type = "Actual"
      contact_roles  = ["Owner", "Contributor"]
    },
    {
      threshold      = 90
      threshold_type = "Actual"
      contact_roles  = ["Owner", "Contributor"]
    },
    {
      threshold      = 100
      threshold_type = "Forecasted"
      contact_roles  = ["Owner"]
    }
  ]
}

# -----------------------------------------------------------------------------
# Action Group Configuration
# -----------------------------------------------------------------------------

variable "enable_action_group" {
  description = "Create an action group for cost alerts"
  type        = bool
  default     = true
}

variable "action_group_name" {
  description = "Name of the action group for cost alerts"
  type        = string
  default     = "cost-alerts"
}

variable "action_group_short_name" {
  description = "Short name for the action group (max 12 chars)"
  type        = string
  default     = "cost-alerts"
}

variable "action_group_email_receivers" {
  description = "List of email receivers for cost alerts"
  type = list(object({
    name          = string
    email_address = string
  }))
  default = []
}

variable "action_group_webhook_receivers" {
  description = "List of webhook receivers for cost alerts"
  type = list(object({
    name        = string
    service_uri = string
  }))
  default = []
}

# -----------------------------------------------------------------------------
# Cost Anomaly Alert Configuration
# -----------------------------------------------------------------------------

variable "enable_anomaly_alert" {
  description = "Enable cost anomaly detection alert"
  type        = bool
  default     = true
}

variable "anomaly_alert_name" {
  description = "Name of the cost anomaly alert"
  type        = string
  default     = "cost-anomaly-alert"
}

variable "anomaly_alert_email_receivers" {
  description = "Email addresses to receive anomaly alerts"
  type        = list(string)
  default     = []
}

# -----------------------------------------------------------------------------
# Resource Group Filter (optional)
# -----------------------------------------------------------------------------

variable "filter_resource_groups" {
  description = "Filter budget to specific resource groups"
  type        = list(string)
  default     = []
}

variable "filter_tags" {
  description = "Filter budget to resources with specific tags"
  type        = map(list(string))
  default     = {}
}

# -----------------------------------------------------------------------------
# Tags
# -----------------------------------------------------------------------------

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
