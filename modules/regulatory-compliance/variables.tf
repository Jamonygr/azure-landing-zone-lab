# =============================================================================
# REGULATORY COMPLIANCE MODULE - VARIABLES
# HIPAA and PCI-DSS policy initiatives
# =============================================================================

variable "scope" {
  description = "The scope for policy assignments (resource group ID or management group ID)"
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
# HIPAA Configuration
# -----------------------------------------------------------------------------

variable "enable_hipaa" {
  description = "Enable HIPAA HITRUST 9.2 policy initiative"
  type        = bool
  default     = false
}

variable "hipaa_assignment_name" {
  description = "Name of the HIPAA policy assignment"
  type        = string
  default     = "hipaa-hitrust"
}

variable "hipaa_enforcement_mode" {
  description = "Enforcement mode for HIPAA policies (Default or DoNotEnforce)"
  type        = string
  default     = "Default"

  validation {
    condition     = contains(["Default", "DoNotEnforce"], var.hipaa_enforcement_mode)
    error_message = "Enforcement mode must be Default or DoNotEnforce."
  }
}

# -----------------------------------------------------------------------------
# PCI-DSS Configuration
# -----------------------------------------------------------------------------

variable "enable_pci_dss" {
  description = "Enable PCI DSS 4.0.1 policy initiative"
  type        = bool
  default     = false
}

variable "pci_dss_assignment_name" {
  description = "Name of the PCI-DSS policy assignment"
  type        = string
  default     = "pci-dss"
}

variable "pci_dss_enforcement_mode" {
  description = "Enforcement mode for PCI-DSS policies (Default or DoNotEnforce)"
  type        = string
  default     = "Default"

  validation {
    condition     = contains(["Default", "DoNotEnforce"], var.pci_dss_enforcement_mode)
    error_message = "Enforcement mode must be Default or DoNotEnforce."
  }
}

# -----------------------------------------------------------------------------
# Common Configuration
# -----------------------------------------------------------------------------

variable "remediation_role_definition_ids" {
  description = "Full Azure role definition resource IDs assigned to compliance policy identities for remediation; empty keeps the initiatives audit-only"
  type        = set(string)
  default     = []

  validation {
    condition = alltrue([
      for id in var.remediation_role_definition_ids : can(regex("^/subscriptions/[0-9a-fA-F-]+/providers/Microsoft.Authorization/roleDefinitions/[0-9a-fA-F-]+$", id)) || can(regex("^/providers/Microsoft.Authorization/roleDefinitions/[0-9a-fA-F-]+$", id))
    ])
    error_message = "remediation_role_definition_ids must contain full Azure role definition resource IDs."
  }
}

variable "exemptions" {
  description = "List of policy exemptions"
  type = list(object({
    name                            = string
    display_name                    = string
    description                     = string
    policy_assignment_id            = string
    exemption_category              = string # Waiver or Mitigated
    expires_on                      = optional(string)
    policy_definition_reference_ids = optional(list(string))
  }))
  default = []
}
