# =============================================================================
# AZURE LOGIC APPS MODULE - Outputs
# =============================================================================

output "logic_app_id" {
  description = "ID of the Logic App Workflow"
  value       = azurerm_logic_app_workflow.this.id
}

output "logic_app_name" {
  description = "Name of the Logic App Workflow"
  value       = azurerm_logic_app_workflow.this.name
}

output "logic_app_access_endpoint" {
  description = "Access endpoint of the Logic App"
  value       = azurerm_logic_app_workflow.this.access_endpoint
}

output "logic_app_identity_principal_id" {
  description = "Principal ID of the Logic App managed identity"
  value       = azurerm_logic_app_workflow.this.identity[0].principal_id
}

output "workflow_id" {
  description = "ID of the Logic App Workflow"
  value       = azurerm_logic_app_workflow.this.id
}
