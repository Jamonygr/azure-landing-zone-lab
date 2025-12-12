# =============================================================================
# RBAC CUSTOM ROLES MODULE - OUTPUTS
# =============================================================================

output "network_operator_role_id" {
  description = "Network Operator Role Definition ID"
  value       = var.deploy_network_operator_role ? azurerm_role_definition.network_operator[0].role_definition_resource_id : null
}

output "network_operator_role_name" {
  description = "Network Operator Role name"
  value       = var.deploy_network_operator_role ? azurerm_role_definition.network_operator[0].name : null
}

output "backup_operator_role_id" {
  description = "Backup Operator Role Definition ID"
  value       = var.deploy_backup_operator_role ? azurerm_role_definition.backup_operator[0].role_definition_resource_id : null
}

output "backup_operator_role_name" {
  description = "Backup Operator Role name"
  value       = var.deploy_backup_operator_role ? azurerm_role_definition.backup_operator[0].name : null
}

output "monitoring_reader_role_id" {
  description = "Monitoring Reader Role Definition ID"
  value       = var.deploy_monitoring_reader_role ? azurerm_role_definition.monitoring_reader[0].role_definition_resource_id : null
}

output "monitoring_reader_role_name" {
  description = "Monitoring Reader Role name"
  value       = var.deploy_monitoring_reader_role ? azurerm_role_definition.monitoring_reader[0].name : null
}
