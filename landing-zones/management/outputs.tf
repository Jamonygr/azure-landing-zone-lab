# =============================================================================
# MANAGEMENT PILLAR - OUTPUTS
# Exposes core network/Log Analytics outputs plus monitoring IDs
# =============================================================================

output "vnet_id" {
  description = "Management VNet ID"
  value       = module.management.vnet_id
}

output "vnet_name" {
  description = "Management VNet name"
  value       = module.management.vnet_name
}

output "jumpbox_subnet_id" {
  description = "Jumpbox subnet ID"
  value       = module.management.jumpbox_subnet_id
}

output "jumpbox_private_ip" {
  description = "Jumpbox private IP"
  value       = module.management.jumpbox_private_ip
}

output "jumpbox_public_ip" {
  description = "Jumpbox public IP (if deployed)"
  value       = module.management.jumpbox_public_ip
}

output "jumpbox_id" {
  description = "Jumpbox VM resource ID"
  value       = module.management.jumpbox_id
}

output "jumpbox_nsg_id" {
  description = "Jumpbox NSG ID"
  value       = module.management.jumpbox_nsg_id
}

output "log_analytics_workspace_id" {
  description = "Log Analytics workspace ID"
  value       = module.management.log_analytics_workspace_id
}

output "log_analytics_workspace_guid" {
  description = "Log Analytics workspace GUID"
  value       = module.management.log_analytics_workspace_guid
}

output "action_group_id" {
  description = "Monitoring action group ID"
  value       = var.deploy_monitoring && length(module.action_group) > 0 ? module.action_group[0].action_group_id : null
}

output "alert_ids" {
  description = "All monitoring alert IDs"
  value       = var.deploy_monitoring && length(module.alerts) > 0 ? module.alerts[0].all_alert_ids : []
}

# -----------------------------------------------------------------------------
# Backup
# -----------------------------------------------------------------------------

output "recovery_services_vault_id" {
  description = "Recovery Services Vault ID"
  value       = var.deploy_backup && length(module.backup) > 0 ? module.backup[0].vault_id : null
}

output "recovery_services_vault_name" {
  description = "Recovery Services Vault name"
  value       = var.deploy_backup && length(module.backup) > 0 ? module.backup[0].vault_name : null
}

# -----------------------------------------------------------------------------
# Automation
# -----------------------------------------------------------------------------

output "automation_account_name" {
  description = "Automation Account name (start/stop)"
  value       = var.enable_scheduled_startstop && length(module.automation) > 0 ? module.automation[0].automation_account_name : null
}
