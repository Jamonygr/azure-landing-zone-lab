# =============================================================================
# AZURE FUNCTIONS MODULE - Variables
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

variable "os_type" {
  description = "Operating system type for the Function App"
  type        = string
  default     = "Linux"
  validation {
    condition     = contains(["Linux", "Windows"], var.os_type)
    error_message = "OS type must be either 'Linux' or 'Windows'."
  }
}

variable "runtime" {
  description = "Runtime for the Function App (dotnet, node, python)"
  type        = string
  default     = "dotnet"
  validation {
    condition     = contains(["dotnet", "node", "python"], var.runtime)
    error_message = "Runtime must be 'dotnet', 'node', or 'python'."
  }
}

variable "runtime_version" {
  description = "Version of the runtime"
  type        = string
  default     = "8.0"
}

variable "sku_name" {
  description = "SKU for the Function App service plan (e.g., Y1 for Consumption, EP1 for Elastic Premium)"
  type        = string
  default     = "Y1"
}

variable "enable_app_insights" {
  description = "Enable Application Insights for monitoring"
  type        = bool
  default     = true
}

variable "log_analytics_workspace_id" {
  description = "Log Analytics Workspace ID for Application Insights"
  type        = string
  default     = null
}

variable "cors_allowed_origins" {
  description = "List of allowed origins for CORS"
  type        = list(string)
  default     = ["https://portal.azure.com"]
}

variable "app_settings" {
  description = "Additional app settings for the Function App"
  type        = map(string)
  default     = {}
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
