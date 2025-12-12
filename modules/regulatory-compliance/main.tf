# =============================================================================
# REGULATORY COMPLIANCE MODULE - MAIN
# HIPAA HITRUST 9.2 and PCI-DSS 4.0 Policy Initiatives
# =============================================================================
#
# This module assigns built-in regulatory compliance policy initiatives
# to resource groups for workload-level compliance.
#
# Built-in Policy Initiative IDs:
# - HIPAA HITRUST 9.2: a169a624-5599-4385-a696-c8d643089fab
# - PCI-DSS 4.0: c676748e-3af9-4e22-bc28-50fed0f511fd (v4)
# - PCI-DSS 3.2.1: 496eeda9-8f2f-4d5e-8dfd-204f0a92ed41 (legacy)
#
# =============================================================================

# -----------------------------------------------------------------------------
# HIPAA HITRUST 9.2 Policy Initiative
# -----------------------------------------------------------------------------
resource "azurerm_resource_group_policy_assignment" "hipaa" {
  count = var.enable_hipaa ? 1 : 0

  name                 = "${var.hipaa_assignment_name}-${var.environment}"
  display_name         = "HIPAA HITRUST 9.2 - ${var.environment}"
  description          = "Assigns HIPAA HITRUST 9.2 policy initiative for healthcare data protection compliance"
  resource_group_id    = var.scope
  policy_definition_id = "/providers/Microsoft.Authorization/policySetDefinitions/a169a624-5599-4385-a696-c8d643089fab"
  location             = var.location
  enforce              = var.hipaa_enforcement_mode == "Default" ? true : false

  identity {
    type = "SystemAssigned"
  }

  non_compliance_message {
    content = "This resource is not compliant with HIPAA HITRUST 9.2 requirements."
  }

  # Parameters for common policy requirements
  parameters = jsonencode({
    # Allowed locations for data residency
    "listOfAllowedLocations" = {
      value = var.hipaa_allowed_locations
    }
    # Log Analytics workspace for diagnostic settings
    "logAnalyticsWorkspaceIdforVMReporting" = {
      value = var.log_analytics_workspace_id != null ? var.log_analytics_workspace_id : ""
    }
  })
}

# Role assignments for HIPAA remediation tasks
resource "azurerm_role_assignment" "hipaa_contributor" {
  count = var.enable_hipaa ? 1 : 0

  scope                = var.scope
  role_definition_name = "Contributor"
  principal_id         = azurerm_resource_group_policy_assignment.hipaa[0].identity[0].principal_id
}

resource "azurerm_role_assignment" "hipaa_security_admin" {
  count = var.enable_hipaa ? 1 : 0

  scope                = var.scope
  role_definition_name = "Security Admin"
  principal_id         = azurerm_resource_group_policy_assignment.hipaa[0].identity[0].principal_id
}

# -----------------------------------------------------------------------------
# PCI-DSS 4.0 Policy Initiative
# -----------------------------------------------------------------------------
resource "azurerm_resource_group_policy_assignment" "pci_dss" {
  count = var.enable_pci_dss ? 1 : 0

  name                 = "${var.pci_dss_assignment_name}-${var.environment}"
  display_name         = "PCI-DSS 4.0 - ${var.environment}"
  description          = "Assigns PCI-DSS 4.0 policy initiative for payment card industry data security"
  resource_group_id    = var.scope
  policy_definition_id = "/providers/Microsoft.Authorization/policySetDefinitions/c676748e-3af9-4e22-bc28-50fed0f511fd"
  location             = var.location
  enforce              = var.pci_dss_enforcement_mode == "Default" ? true : false

  identity {
    type = "SystemAssigned"
  }

  non_compliance_message {
    content = "This resource is not compliant with PCI-DSS 4.0 requirements."
  }

  # Parameters for common policy requirements
  parameters = jsonencode({
    # Allowed locations for data residency
    "listOfAllowedLocations" = {
      value = var.pci_dss_allowed_locations
    }
    # Log Analytics workspace for monitoring
    "logAnalyticsWorkspaceIdforVMReporting" = {
      value = var.log_analytics_workspace_id != null ? var.log_analytics_workspace_id : ""
    }
  })
}

# Role assignments for PCI-DSS remediation tasks
resource "azurerm_role_assignment" "pci_dss_contributor" {
  count = var.enable_pci_dss ? 1 : 0

  scope                = var.scope
  role_definition_name = "Contributor"
  principal_id         = azurerm_resource_group_policy_assignment.pci_dss[0].identity[0].principal_id
}

resource "azurerm_role_assignment" "pci_dss_security_admin" {
  count = var.enable_pci_dss ? 1 : 0

  scope                = var.scope
  role_definition_name = "Security Admin"
  principal_id         = azurerm_resource_group_policy_assignment.pci_dss[0].identity[0].principal_id
}

# -----------------------------------------------------------------------------
# Policy Exemptions
# -----------------------------------------------------------------------------
resource "azurerm_resource_group_policy_exemption" "this" {
  for_each = { for e in var.exemptions : e.name => e }

  name                            = each.value.name
  display_name                    = each.value.display_name
  description                     = each.value.description
  resource_group_id               = var.scope
  policy_assignment_id            = each.value.policy_assignment_id
  exemption_category              = each.value.exemption_category
  expires_on                      = each.value.expires_on
  policy_definition_reference_ids = each.value.policy_definition_reference_ids
}
