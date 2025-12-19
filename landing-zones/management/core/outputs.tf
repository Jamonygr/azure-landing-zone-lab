# =============================================================================
# MANAGEMENT LANDING ZONE - OUTPUTS
# =============================================================================

output "vnet_id" {
  description = "Management VNet ID"
  value       = module.mgmt_vnet.id
}

output "vnet_name" {
  description = "Management VNet name"
  value       = module.mgmt_vnet.name
}

output "jumpbox_subnet_id" {
  description = "Jump box subnet ID"
  value       = module.jumpbox_subnet.id
}

output "jumpbox_private_ip" {
  description = "Jump box private IP"
  value       = module.jumpbox.private_ip_address
}

output "jumpbox_public_ip" {
  description = "Jump box public IP"
  value       = module.jumpbox.public_ip_address
}

output "jumpbox_id" {
  description = "Jump box VM ID"
  value       = module.jumpbox.id
}

output "jumpbox_nsg_id" {
  description = "Jump box NSG ID"
  value       = module.jumpbox_nsg.id
}

output "log_analytics_workspace_id" {
  description = "Log Analytics workspace ID"
  value       = var.deploy_log_analytics ? module.log_analytics[0].id : null
}

output "log_analytics_workspace_guid" {
  description = "Log Analytics workspace GUID"
  value       = var.deploy_log_analytics ? module.log_analytics[0].workspace_id : null
}

# =============================================================================
# MONITORING OUTPUTS
# =============================================================================

output "action_group_id" {
  description = "Action Group ID"
  value       = var.deploy_monitoring ? module.action_group[0].action_group_id : null
}

output "alert_ids" {
  description = "List of all alert IDs"
  value       = var.deploy_monitoring ? module.alerts[0].all_alert_ids : []
}
