# =============================================================================
# NAT GATEWAY MODULE - VARIABLES
# =============================================================================

variable "name" {
  description = "Name of the NAT Gateway"
  type        = string
}

variable "resource_group_name" {
  description = "Resource group name"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID to associate with the NAT Gateway"
  type        = string
}

variable "idle_timeout_in_minutes" {
  description = "Idle timeout in minutes (4-120)"
  type        = number
  default     = 10
}

variable "zones" {
  description = "Availability zones for the NAT Gateway"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
