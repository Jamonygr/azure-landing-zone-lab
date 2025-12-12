# =============================================================================
# AZURE POLICY MODULE - VARIABLES
# =============================================================================

variable "scope" {
  description = "The scope at which policies are assigned (subscription, management group, or resource group ID)"
  type        = string
}

variable "location" {
  description = "Azure region for policy assignment identity"
  type        = string
}

variable "environment" {
  description = "Environment name for naming conventions"
  type        = string
}

# -----------------------------------------------------------------------------
# Policy Assignment Toggles
# -----------------------------------------------------------------------------

variable "enable_allowed_locations_policy" {
  description = "Enable policy to restrict resource deployment to allowed locations"
  type        = bool
  default     = true
}

variable "allowed_locations" {
  description = "List of allowed Azure locations for resource deployment"
  type        = list(string)
  default     = ["westeurope", "northeurope", "eastus", "eastus2", "westus2"]
}

variable "enable_require_tag_policy" {
  description = "Enable policy to require specific tags on resources"
  type        = bool
  default     = true
}

variable "required_tags" {
  description = "Map of required tag names and their default values"
  type        = map(string)
  default = {
    "Environment" = ""
    "Owner"       = ""
    "Project"     = ""
  }
}

variable "enable_inherit_tag_policy" {
  description = "Enable policy to inherit tags from resource group if missing"
  type        = bool
  default     = true
}

variable "inherit_tag_names" {
  description = "List of tag names to inherit from resource group"
  type        = list(string)
  default     = ["Environment", "Owner", "Project"]
}

variable "enable_audit_public_network_access" {
  description = "Enable policy to audit resources with public network access"
  type        = bool
  default     = true
}

variable "enable_require_https_storage" {
  description = "Enable policy to require HTTPS traffic for storage accounts"
  type        = bool
  default     = true
}

variable "enable_audit_unattached_disks" {
  description = "Enable policy to audit unattached managed disks"
  type        = bool
  default     = true
}

variable "enable_require_nsg_on_subnet" {
  description = "Enable policy to require NSG on subnets"
  type        = bool
  default     = true
}

variable "enable_allowed_vm_skus" {
  description = "Enable policy to restrict VM SKUs"
  type        = bool
  default     = false
}

variable "allowed_vm_skus" {
  description = "List of allowed VM SKUs"
  type        = list(string)
  default = [
    "Standard_B1s",
    "Standard_B1ms",
    "Standard_B2s",
    "Standard_B2ms",
    "Standard_D2s_v3",
    "Standard_D4s_v3",
    "Standard_DS1_v2",
    "Standard_DS2_v2"
  ]
}

# -----------------------------------------------------------------------------
# Custom Policy Definitions
# -----------------------------------------------------------------------------

variable "custom_policy_definitions" {
  description = "List of custom policy definitions to create"
  type = list(object({
    name         = string
    display_name = string
    description  = string
    mode         = string
    policy_rule  = string
    parameters   = optional(string, "{}")
    metadata     = optional(string, "{}")
  }))
  default = []
}
