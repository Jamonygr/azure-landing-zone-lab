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

variable "hipaa_allowed_locations" {
  description = "Allowed locations for HIPAA compliance"
  type        = list(string)
  default     = ["eastus", "eastus2", "westus2", "centralus"]
}

# -----------------------------------------------------------------------------
# PCI-DSS Configuration  
# -----------------------------------------------------------------------------

variable "enable_pci_dss" {
  description = "Enable PCI-DSS 4.0 policy initiative"
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

variable "pci_dss_allowed_locations" {
  description = "Allowed locations for PCI-DSS compliance"
  type        = list(string)
  default     = ["eastus", "eastus2", "westus2", "centralus"]
}

# -----------------------------------------------------------------------------
# Common Configuration
# -----------------------------------------------------------------------------

variable "log_analytics_workspace_id" {
  description = "Log Analytics Workspace ID for compliance logging (required for some policies)"
  type        = string
  default     = null
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
