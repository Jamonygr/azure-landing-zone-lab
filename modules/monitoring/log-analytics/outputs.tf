# =============================================================================
# LOG ANALYTICS WORKSPACE MODULE - OUTPUTS
# =============================================================================

output "id" {
  description = "The ID of the Log Analytics Workspace"
  value       = azurerm_log_analytics_workspace.this.id
}

output "name" {
  description = "The name of the Log Analytics Workspace"
  value       = azurerm_log_analytics_workspace.this.name
}

output "workspace_id" {
  description = "The Workspace ID"
  value       = azurerm_log_analytics_workspace.this.workspace_id
}
