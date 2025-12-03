# =============================================================================
# AZURE FIREWALL RULES MODULE - VARIABLES
# =============================================================================

variable "name" {
  description = "Rule collection group name"
  type        = string
}

variable "firewall_policy_id" {
  description = "Firewall Policy ID"
  type        = string
}

variable "priority" {
  description = "Rule collection group priority"
  type        = number
}

variable "network_rule_collections" {
  description = "Network rule collections"
  type = list(object({
    name     = string
    priority = number
    action   = string
    rules = list(object({
      name                  = string
      protocols             = list(string)
      source_addresses      = optional(list(string))
      source_ip_groups      = optional(list(string))
      destination_addresses = optional(list(string))
      destination_ip_groups = optional(list(string))
      destination_fqdns     = optional(list(string))
      destination_ports     = list(string)
    }))
  }))
  default = []
}

variable "application_rule_collections" {
  description = "Application rule collections"
  type = list(object({
    name     = string
    priority = number
    action   = string
    rules = list(object({
      name              = string
      source_addresses  = optional(list(string))
      source_ip_groups  = optional(list(string))
      destination_fqdns = optional(list(string))
      protocols = list(object({
        type = string
        port = number
      }))
    }))
  }))
  default = []
}

variable "nat_rule_collections" {
  description = "NAT rule collections (DNAT)"
  type = list(object({
    name     = string
    priority = number
    action   = string
    rules = list(object({
      name                = string
      protocols           = list(string)
      source_addresses    = optional(list(string))
      source_ip_groups    = optional(list(string))
      destination_address = string
      destination_ports   = list(string)
      translated_address  = string
      translated_port     = string
    }))
  }))
  default = []
}
