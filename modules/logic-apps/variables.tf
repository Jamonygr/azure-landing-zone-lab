# =============================================================================
# AZURE LOGIC APPS MODULE - Variables
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

variable "workflow_parameters" {
  description = "Workflow parameters as a map of JSON strings"
  type        = map(string)
  default     = {}
}

variable "parameters" {
  description = "Parameters for the Logic App workflow"
  type        = map(string)
  default     = {}
}

variable "enable_http_trigger" {
  description = "Enable HTTP request trigger"
  type        = bool
  default     = false
}

variable "http_trigger_schema" {
  description = "JSON schema for the HTTP trigger request body"
  type        = string
  default     = <<SCHEMA
{
    "type": "object",
    "properties": {
        "message": {
            "type": "string"
        }
    }
}
SCHEMA
}

variable "enable_http_action" {
  description = "Enable HTTP action"
  type        = bool
  default     = false
}

variable "http_action_method" {
  description = "HTTP method for the action"
  type        = string
  default     = "POST"
}

variable "http_action_uri" {
  description = "URI for the HTTP action"
  type        = string
  default     = ""
}

variable "http_action_headers" {
  description = "Headers for the HTTP action"
  type        = map(string)
  default     = {}
}

variable "http_action_body" {
  description = "Body for the HTTP action"
  type        = string
  default     = ""
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
