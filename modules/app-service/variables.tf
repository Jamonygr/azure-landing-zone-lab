# =============================================================================
# AZURE APP SERVICE MODULE - Variables
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
  description = "Operating system type for the App Service"
  type        = string
  default     = "Linux"
  validation {
    condition     = contains(["Linux", "Windows"], var.os_type)
    error_message = "OS type must be either 'Linux' or 'Windows'."
  }
}

variable "sku_name" {
  description = "SKU name for the App Service Plan"
  type        = string
  default     = "S1"
  validation {
    condition     = contains(["F1", "D1", "B1", "B2", "B3", "S1", "S2", "S3", "P1v2", "P2v2", "P3v2", "P1v3", "P2v3", "P3v3"], var.sku_name)
    error_message = "Invalid SKU name."
  }
}

variable "runtime" {
  description = "Runtime for the App Service (dotnet, node, python, java)"
  type        = string
  default     = "dotnet"
  validation {
    condition     = contains(["dotnet", "node", "python", "java"], var.runtime)
    error_message = "Runtime must be 'dotnet', 'node', 'python', or 'java'."
  }
}

variable "runtime_version" {
  description = "Version of the runtime"
  type        = string
  default     = "8.0"
}

variable "enable_app_insights" {
  description = "Enable Application Insights for monitoring"
  type        = bool
  default     = true
}

variable "log_analytics_workspace_id" {
  description = "Log Analytics Workspace ID for Application Insights and diagnostics"
  type        = string
  default     = null
}

variable "enable_diagnostics" {
  description = "Enable diagnostic settings (set to true when log_analytics_workspace_id will be provided)"
  type        = bool
  default     = false
}

variable "cors_allowed_origins" {
  description = "List of allowed origins for CORS"
  type        = list(string)
  default     = ["https://portal.azure.com"]
}

variable "app_settings" {
  description = "Additional app settings for the App Service"
  type        = map(string)
  default     = {}
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
