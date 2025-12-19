# =============================================================================
# GOVERNANCE PILLAR - OUTPUTS
# =============================================================================

output "management_groups_root_id" {
  description = "Root management group ID"
  value       = var.deploy_management_groups ? var.management_group_root_id : null
}

# -----------------------------------------------------------------------------
# Monitoring Outputs
# -----------------------------------------------------------------------------

output "log_analytics_workspace_id" {
  description = "Log Analytics Workspace ID"
  value       = var.deploy_monitoring && length(module.log_analytics) > 0 ? module.log_analytics[0].id : null
}

output "log_analytics_workspace_name" {
  description = "Log Analytics Workspace name"
  value       = var.deploy_monitoring && length(module.log_analytics) > 0 ? module.log_analytics[0].name : null
}

output "log_analytics_workspace_key" {
  description = "Log Analytics Workspace primary shared key"
  value       = var.deploy_monitoring && length(module.log_analytics) > 0 ? module.log_analytics[0].primary_shared_key : null
  sensitive   = true
}

output "monitoring_action_group_id" {
  description = "Monitoring Action Group ID"
  value       = var.deploy_monitoring && length(module.monitoring_action_group) > 0 ? module.monitoring_action_group[0].action_group_id : null
}
