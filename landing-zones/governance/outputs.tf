# =============================================================================
# GOVERNANCE PILLAR - OUTPUTS
# =============================================================================

output "management_groups_root_id" {
  description = "Root management group ID"
  value       = var.deploy_management_groups ? var.management_group_root_id : null
}
