# =============================================================================
# AZURE POLICY MODULE - MAIN
# Assigns built-in and custom Azure policies for governance
# =============================================================================

# -----------------------------------------------------------------------------
# Built-in Policy: Allowed Locations
# -----------------------------------------------------------------------------
resource "azurerm_subscription_policy_assignment" "allowed_locations" {
  count                = var.enable_allowed_locations_policy ? 1 : 0
  name                 = "allowed-locations-${var.environment}"
  display_name         = "Allowed Locations"
  description          = "Restricts resource deployment to specified Azure regions"
  subscription_id      = var.scope
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/e56962a6-4747-49cd-b67b-bf8b01975c4c"

  parameters = jsonencode({
    listOfAllowedLocations = {
      value = var.allowed_locations
    }
  })
}

# -----------------------------------------------------------------------------
# Built-in Policy: Require Tag on Resources (one per required tag)
# -----------------------------------------------------------------------------
resource "azurerm_subscription_policy_assignment" "require_tag" {
  for_each = var.enable_require_tag_policy ? var.required_tags : {}

  name                 = "require-tag-${lower(replace(each.key, " ", "-"))}-${var.environment}"
  display_name         = "Require tag: ${each.key}"
  description          = "Requires the ${each.key} tag on resources"
  subscription_id      = var.scope
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/871b6d14-10aa-478d-b590-94f262ecfa99"

  parameters = jsonencode({
    tagName = {
      value = each.key
    }
  })

  non_compliance_message {
    content = "Resource must have the '${each.key}' tag."
  }
}

# -----------------------------------------------------------------------------
# Built-in Policy: Inherit Tag from Resource Group
# -----------------------------------------------------------------------------
resource "azurerm_subscription_policy_assignment" "inherit_tag" {
  for_each = var.enable_inherit_tag_policy ? toset(var.inherit_tag_names) : toset([])

  name                 = "inherit-tag-${lower(replace(each.value, " ", "-"))}-${var.environment}"
  display_name         = "Inherit tag ${each.value} from resource group"
  description          = "Adds or replaces the specified tag and value from the parent resource group when any resource is created or updated"
  subscription_id      = var.scope
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/ea3f2387-9b95-492a-a190-fcbfef9b60fd"
  location             = var.location

  identity {
    type = "SystemAssigned"
  }

  parameters = jsonencode({
    tagName = {
      value = each.value
    }
  })
}

# Role assignment for inherit tag policy (needs Contributor to modify resources)
resource "azurerm_role_assignment" "inherit_tag_contributor" {
  for_each = var.enable_inherit_tag_policy ? toset(var.inherit_tag_names) : toset([])

  scope                = var.scope
  role_definition_name = "Tag Contributor"
  principal_id         = azurerm_subscription_policy_assignment.inherit_tag[each.value].identity[0].principal_id
}

# -----------------------------------------------------------------------------
# Built-in Policy: Audit Public Network Access
# Audits Azure SQL, Storage, and Key Vault for public network access
# -----------------------------------------------------------------------------

# Audit Azure SQL Database public network access
resource "azurerm_subscription_policy_assignment" "audit_sql_public_access" {
  count                = var.enable_audit_public_network_access ? 1 : 0
  name                 = "audit-sql-public-${var.environment}"
  display_name         = "Audit Azure SQL public network access"
  description          = "Audits Azure SQL servers that have public network access enabled"
  subscription_id      = var.scope
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/1b8ca024-1d5c-4dec-8995-b1a932b41780"
}

# Audit Storage Account public network access
resource "azurerm_subscription_policy_assignment" "audit_storage_public_access" {
  count                = var.enable_audit_public_network_access ? 1 : 0
  name                 = "audit-storage-public-${var.environment}"
  display_name         = "Audit Storage Account public network access"
  description          = "Audits storage accounts that allow public network access"
  subscription_id      = var.scope
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/b2982f36-99f2-4db5-8eff-283140c09693"
}

# Audit Key Vault public network access
resource "azurerm_subscription_policy_assignment" "audit_keyvault_public_access" {
  count                = var.enable_audit_public_network_access ? 1 : 0
  name                 = "audit-kv-public-${var.environment}"
  display_name         = "Audit Key Vault public network access"
  description          = "Audits Key Vaults that allow public network access"
  subscription_id      = var.scope
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/405c5871-3e91-4644-8a63-58e19d68ff5b"
}

# -----------------------------------------------------------------------------
# Built-in Policy: Require HTTPS for Storage
# -----------------------------------------------------------------------------
resource "azurerm_subscription_policy_assignment" "require_https_storage" {
  count                = var.enable_require_https_storage ? 1 : 0
  name                 = "require-https-storage-${var.environment}"
  display_name         = "Secure transfer to storage accounts should be enabled"
  description          = "Audit requirement of Secure transfer in your storage account"
  subscription_id      = var.scope
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/404c3081-a854-4457-ae30-26a93ef643f9"
}

# -----------------------------------------------------------------------------
# Built-in Policy: Audit Unattached Managed Disks
# -----------------------------------------------------------------------------
resource "azurerm_subscription_policy_assignment" "audit_unattached_disks" {
  count                = var.enable_audit_unattached_disks ? 1 : 0
  name                 = "audit-unattached-disks-${var.environment}"
  display_name         = "Audit unattached managed disks"
  description          = "Audits managed disks that are not attached to any VM"
  subscription_id      = var.scope
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/c0e75c24-ba9e-4c7b-b7d1-f2f0e3b7bc99"
}

# -----------------------------------------------------------------------------
# Built-in Policy: Require NSG on Subnets
# -----------------------------------------------------------------------------
resource "azurerm_subscription_policy_assignment" "require_nsg_on_subnet" {
  count                = var.enable_require_nsg_on_subnet ? 1 : 0
  name                 = "require-nsg-subnet-${var.environment}"
  display_name         = "Subnets should have a Network Security Group"
  description          = "Protect your subnet from potential threats by restricting access with NSG"
  subscription_id      = var.scope
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/e71308d3-144b-4262-b144-efdc3cc90517"
}

# -----------------------------------------------------------------------------
# Built-in Policy: Allowed VM SKUs
# -----------------------------------------------------------------------------
resource "azurerm_subscription_policy_assignment" "allowed_vm_skus" {
  count                = var.enable_allowed_vm_skus ? 1 : 0
  name                 = "allowed-vm-skus-${var.environment}"
  display_name         = "Allowed virtual machine size SKUs"
  description          = "Restricts VM deployment to specified SKUs to control costs"
  subscription_id      = var.scope
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/cccc23c7-8427-4f53-ad12-b6a63eb452b3"

  parameters = jsonencode({
    listOfAllowedSKUs = {
      value = var.allowed_vm_skus
    }
  })
}

# -----------------------------------------------------------------------------
# Custom Policy Definitions
# -----------------------------------------------------------------------------
resource "azurerm_policy_definition" "custom" {
  for_each = { for p in var.custom_policy_definitions : p.name => p }

  name         = each.value.name
  display_name = each.value.display_name
  description  = each.value.description
  mode         = each.value.mode
  policy_type  = "Custom"

  policy_rule = each.value.policy_rule
  parameters  = each.value.parameters
  metadata    = each.value.metadata
}
