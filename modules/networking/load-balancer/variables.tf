# =============================================================================
# LOAD BALANCER MODULE - Variables
# =============================================================================

variable "name" {
  description = "Name of the load balancer"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "sku" {
  description = "SKU of the load balancer (Basic or Standard)"
  type        = string
  default     = "Standard"
}

variable "type" {
  description = "Type of load balancer: 'public' or 'internal'"
  type        = string
  default     = "public"

  validation {
    condition     = contains(["public", "internal"], var.type)
    error_message = "Type must be 'public' or 'internal'."
  }
}

variable "subnet_id" {
  description = "Subnet ID for internal load balancer (required if type = 'internal')"
  type        = string
  default     = null
}

variable "private_ip_address" {
  description = "Private IP address for internal load balancer"
  type        = string
  default     = null
}

variable "backend_pool_name" {
  description = "Name of the backend address pool"
  type        = string
  default     = "backend-pool"
}

variable "health_probes" {
  description = "Map of health probes to create"
  type = map(object({
    protocol     = string
    port         = number
    request_path = optional(string, "/")
  }))
  default = {
    http = {
      protocol     = "Http"
      port         = 80
      request_path = "/"
    }
  }
}

variable "lb_rules" {
  description = "Map of load balancing rules"
  type = map(object({
    protocol                = string
    frontend_port           = number
    backend_port            = number
    probe_name              = string
    load_distribution       = optional(string, "Default")
    idle_timeout_in_minutes = optional(number, 4)
  }))
  default = {}
}

variable "nat_rules" {
  description = "Map of NAT rules for direct VM access"
  type = map(object({
    protocol      = string
    frontend_port = number
    backend_port  = number
  }))
  default = {}
}

variable "enable_outbound_rule" {
  description = "Enable outbound SNAT rule"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
