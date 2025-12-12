# =============================================================================
# AZURE BACKUP MODULE - OUTPUTS
# =============================================================================

output "vault_id" {
  description = "Recovery Services Vault ID"
  value       = azurerm_recovery_services_vault.vault.id
}

output "vault_name" {
  description = "Recovery Services Vault name"
  value       = azurerm_recovery_services_vault.vault.name
}

output "daily_policy_id" {
  description = "Daily backup policy ID"
  value       = azurerm_backup_policy_vm.daily.id
}

output "critical_policy_id" {
  description = "Critical backup policy ID"
  value       = azurerm_backup_policy_vm.critical.id
}
