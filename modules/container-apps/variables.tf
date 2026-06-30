# =============================================================================
# AZURE CONTAINER APPS MODULE - VARIABLES
# =============================================================================

variable "name_suffix" {
  description = "Suffix for naming resources, typically workload-environment-region."
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group."
  type        = string
}

variable "location" {
  description = "Azure region for resources."
  type        = string
}

variable "infrastructure_subnet_id" {
  description = "Delegated subnet ID for the Container Apps managed environment."
  type        = string
}

variable "internal_load_balancer_enabled" {
  description = "Use an internal-only managed environment."
  type        = bool
  default     = false
}

variable "zone_redundancy_enabled" {
  description = "Enable zone redundancy for the managed environment when the selected region and subnet support it."
  type        = bool
  default     = false
}

variable "container_image" {
  description = "Container image to run in the sample app."
  type        = string
  default     = "mcr.microsoft.com/azuredocs/containerapps-helloworld:latest"
}

variable "target_port" {
  description = "Container port exposed by ingress."
  type        = number
  default     = 80
}

variable "min_replicas" {
  description = "Minimum replicas for the app."
  type        = number
  default     = 0
}

variable "max_replicas" {
  description = "Maximum replicas for the app."
  type        = number
  default     = 1
}

variable "cpu" {
  description = "CPU cores allocated to the container."
  type        = number
  default     = 0.25
}

variable "memory" {
  description = "Memory allocated to the container."
  type        = string
  default     = "0.5Gi"
}

variable "env_vars" {
  description = "Environment variables to set on the container."
  type        = map(string)
  default     = {}
}

variable "log_analytics_workspace_id" {
  description = "Log Analytics workspace ID for the managed environment."
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags to apply to resources."
  type        = map(string)
  default     = {}
}
