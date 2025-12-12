# =============================================================================
# REGULATORY COMPLIANCE MODULE - OUTPUTS
# =============================================================================

# -----------------------------------------------------------------------------
# HIPAA Outputs
# -----------------------------------------------------------------------------
output "hipaa_assignment_id" {
  description = "The ID of the HIPAA HITRUST 9.2 policy assignment"
  value       = var.enable_hipaa ? azurerm_resource_group_policy_assignment.hipaa[0].id : null
}

output "hipaa_assignment_name" {
  description = "The name of the HIPAA policy assignment"
  value       = var.enable_hipaa ? azurerm_resource_group_policy_assignment.hipaa[0].name : null
}

output "hipaa_principal_id" {
  description = "The principal ID of the HIPAA policy managed identity"
  value       = var.enable_hipaa ? azurerm_resource_group_policy_assignment.hipaa[0].identity[0].principal_id : null
}

# -----------------------------------------------------------------------------
# PCI-DSS Outputs
# -----------------------------------------------------------------------------
output "pci_dss_assignment_id" {
  description = "The ID of the PCI-DSS 4.0 policy assignment"
  value       = var.enable_pci_dss ? azurerm_resource_group_policy_assignment.pci_dss[0].id : null
}

output "pci_dss_assignment_name" {
  description = "The name of the PCI-DSS policy assignment"
  value       = var.enable_pci_dss ? azurerm_resource_group_policy_assignment.pci_dss[0].name : null
}

output "pci_dss_principal_id" {
  description = "The principal ID of the PCI-DSS policy managed identity"
  value       = var.enable_pci_dss ? azurerm_resource_group_policy_assignment.pci_dss[0].identity[0].principal_id : null
}

# -----------------------------------------------------------------------------
# Exemption Outputs
# -----------------------------------------------------------------------------
output "exemption_ids" {
  description = "Map of exemption names to their IDs"
  value       = { for k, v in azurerm_resource_group_policy_exemption.this : k => v.id }
}

# -----------------------------------------------------------------------------
# Summary
# -----------------------------------------------------------------------------
output "compliance_summary" {
  description = "Summary of enabled compliance frameworks"
  value = {
    hipaa_enabled   = var.enable_hipaa
    pci_dss_enabled = var.enable_pci_dss
    scope           = var.scope
    environment     = var.environment
  }
}
