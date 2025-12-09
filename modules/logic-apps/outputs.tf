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

output "http_trigger_callback_url" {
  description = "Callback URL for the HTTP trigger"
  value       = var.enable_http_trigger ? azurerm_logic_app_trigger_http_request.this[0].callback_url : null
  sensitive   = true
}

output "workflow_id" {
  description = "ID of the Logic App Workflow"
  value       = azurerm_logic_app_workflow.this.id
}
