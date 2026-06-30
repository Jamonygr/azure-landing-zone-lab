# =============================================================================
# AZURE CONTAINER APPS MODULE - OUTPUTS
# =============================================================================

output "environment_id" {
  description = "Container Apps managed environment ID."
  value       = azurerm_container_app_environment.this.id
}

output "environment_name" {
  description = "Container Apps managed environment name."
  value       = azurerm_container_app_environment.this.name
}

output "container_app_id" {
  description = "Container App ID."
  value       = azurerm_container_app.this.id
}

output "container_app_name" {
  description = "Container App name."
  value       = azurerm_container_app.this.name
}

output "container_app_fqdn" {
  description = "Container App ingress FQDN."
  value       = azurerm_container_app.this.ingress[0].fqdn
}

output "latest_revision_fqdn" {
  description = "Latest revision FQDN."
  value       = azurerm_container_app.this.latest_revision_fqdn
}

output "identity_principal_id" {
  description = "System-assigned identity principal ID."
  value       = azurerm_container_app.this.identity[0].principal_id
}
