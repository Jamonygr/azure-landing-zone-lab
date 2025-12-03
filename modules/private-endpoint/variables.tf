# =============================================================================
# PRIVATE ENDPOINT MODULE - VARIABLES
# =============================================================================

variable "name" {
  description = "Private Endpoint name"
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

variable "tags" {
  description = "Tags to apply"
  type        = map(string)
  default     = {}
}

variable "subnet_id" {
  description = "Subnet ID for the private endpoint"
  type        = string
}

variable "private_connection_resource_id" {
  description = "Resource ID to connect to"
  type        = string
}

variable "subresource_names" {
  description = "Subresource names (e.g., 'blob', 'sqlServer', 'vault')"
  type        = list(string)
}

variable "is_manual_connection" {
  description = "Is manual approval required"
  type        = bool
  default     = false
}

variable "private_dns_zone_id" {
  description = "Private DNS Zone ID (optional)"
  type        = string
  default     = null
}

variable "private_dns_zone_group_name" {
  description = "Private DNS Zone group name"
  type        = string
  default     = "default"
}
