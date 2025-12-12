# =============================================================================
# AZURE POLICY MODULE - OUTPUTS
# =============================================================================

output "allowed_locations_assignment_id" {
  description = "The ID of the allowed locations policy assignment"
  value       = var.enable_allowed_locations_policy ? azurerm_subscription_policy_assignment.allowed_locations[0].id : null
}

output "require_tag_assignment_ids" {
  description = "Map of tag names to their policy assignment IDs"
  value       = { for k, v in azurerm_subscription_policy_assignment.require_tag : k => v.id }
}

output "inherit_tag_assignment_ids" {
  description = "Map of tag names to their inherit tag policy assignment IDs"
  value       = { for k, v in azurerm_subscription_policy_assignment.inherit_tag : k => v.id }
}

output "audit_sql_public_access_assignment_id" {
  description = "The ID of the SQL public access audit policy assignment"
  value       = var.enable_audit_public_network_access ? azurerm_subscription_policy_assignment.audit_sql_public_access[0].id : null
}

output "audit_storage_public_access_assignment_id" {
  description = "The ID of the Storage public access audit policy assignment"
  value       = var.enable_audit_public_network_access ? azurerm_subscription_policy_assignment.audit_storage_public_access[0].id : null
}

output "audit_keyvault_public_access_assignment_id" {
  description = "The ID of the Key Vault public access audit policy assignment"
  value       = var.enable_audit_public_network_access ? azurerm_subscription_policy_assignment.audit_keyvault_public_access[0].id : null
}

output "require_https_storage_assignment_id" {
  description = "The ID of the require HTTPS storage policy assignment"
  value       = var.enable_require_https_storage ? azurerm_subscription_policy_assignment.require_https_storage[0].id : null
}

output "audit_unattached_disks_assignment_id" {
  description = "The ID of the audit unattached disks policy assignment"
  value       = var.enable_audit_unattached_disks ? azurerm_subscription_policy_assignment.audit_unattached_disks[0].id : null
}

output "require_nsg_on_subnet_assignment_id" {
  description = "The ID of the require NSG on subnet policy assignment"
  value       = var.enable_require_nsg_on_subnet ? azurerm_subscription_policy_assignment.require_nsg_on_subnet[0].id : null
}

output "allowed_vm_skus_assignment_id" {
  description = "The ID of the allowed VM SKUs policy assignment"
  value       = var.enable_allowed_vm_skus ? azurerm_subscription_policy_assignment.allowed_vm_skus[0].id : null
}

output "custom_policy_definition_ids" {
  description = "Map of custom policy names to their definition IDs"
  value       = { for k, v in azurerm_policy_definition.custom : k => v.id }
}
