# =============================================================================
# AZURE WORKBOOKS MODULE - OUTPUTS
# =============================================================================

output "vm_workbook_id" {
  description = "VM Performance Workbook ID"
  value       = var.deploy_vm_workbook ? azurerm_application_insights_workbook.vm_performance[0].id : null
}

output "network_workbook_id" {
  description = "Network Traffic Workbook ID"
  value       = var.deploy_network_workbook ? azurerm_application_insights_workbook.network_traffic[0].id : null
}

output "firewall_workbook_id" {
  description = "Firewall Analytics Workbook ID"
  value       = var.deploy_firewall_workbook ? azurerm_application_insights_workbook.firewall[0].id : null
}
