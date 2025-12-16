# =============================================================================
# CONNECTION MONITOR MODULE - VARIABLES
# =============================================================================

variable "monitor_name" {
  description = "Name of the Connection Monitor"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "resource_group_name" {
  description = "Resource group name (for Network Watcher if creating)"
  type        = string
}

variable "tags" {
  description = "Tags to apply"
  type        = map(string)
  default     = {}
}

variable "create_network_watcher" {
  description = "Create Network Watcher (false = use existing)"
  type        = bool
  default     = false
}

variable "network_watcher_name" {
  description = "Name of the Network Watcher (used when create_network_watcher = false, or for creating with a specific name)"
  type        = string
  default     = null
}

variable "log_analytics_workspace_id" {
  description = "Log Analytics Workspace ID for test results"
  type        = string
  default     = null
}

# -----------------------------------------------------------------------------
# Source Endpoints (VMs to test from)
# -----------------------------------------------------------------------------

variable "source_endpoints" {
  description = "Source endpoints (VMs) for connectivity tests"
  type = list(object({
    name        = string
    resource_id = string
  }))
  default = []
}

# -----------------------------------------------------------------------------
# Destination Endpoints (targets to test connectivity to)
# -----------------------------------------------------------------------------

variable "destination_endpoints" {
  description = "Destination endpoints for connectivity tests"
  type = list(object({
    name        = string
    type        = string # AzureVM, ExternalAddress, AzureSubnet, etc.
    address     = optional(string)
    resource_id = optional(string)
  }))
  default = []
}

# -----------------------------------------------------------------------------
# Test Configurations
# -----------------------------------------------------------------------------

variable "test_configurations" {
  description = "Test configurations for different protocols"
  type = list(object({
    name               = string
    protocol           = string # Tcp, Icmp, Http
    frequency_seconds  = optional(number, 60)
    port               = optional(number)
    trace_route        = optional(bool, true)
    method             = optional(string, "Get")
    prefer_https       = optional(bool, false)
    valid_status_codes = optional(list(string), ["200"])
  }))
  default = [
    {
      name              = "tcp-443"
      protocol          = "Tcp"
      frequency_seconds = 60
      port              = 443
      trace_route       = true
    },
    {
      name              = "icmp-ping"
      protocol          = "Icmp"
      frequency_seconds = 60
      trace_route       = true
    }
  ]
}

# -----------------------------------------------------------------------------
# Test Groups
# -----------------------------------------------------------------------------

variable "test_groups" {
  description = "Test groups combining sources, destinations, and test configs"
  type = list(object({
    name                     = string
    source_endpoints         = list(string)
    destination_endpoints    = list(string)
    test_configuration_names = list(string)
    enabled                  = optional(bool, true)
  }))
  default = null
}

locals {
  # If test_groups not provided, auto-generate based on source/dest endpoints
  auto_test_groups = var.test_groups != null ? var.test_groups : (
    length(var.source_endpoints) > 0 && length(var.destination_endpoints) > 0 && length(var.test_configurations) > 0 ? [
      {
        name                     = "default-test-group"
        source_endpoints         = [for ep in var.source_endpoints : ep.name]
        destination_endpoints    = [for ep in var.destination_endpoints : ep.name]
        test_configuration_names = [for tc in var.test_configurations : tc.name]
        enabled                  = true
      }
    ] : []
  )
}
