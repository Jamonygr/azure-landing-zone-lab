# =============================================================================
# AZURE STATIC WEB APP MODULE - Outputs
# =============================================================================

output "static_web_app_id" {
  description = "ID of the Static Web App"
  value       = azurerm_static_web_app.this.id
}

output "static_web_app_name" {
  description = "Name of the Static Web App"
  value       = azurerm_static_web_app.this.name
}

output "static_web_app_default_hostname" {
  description = "Default hostname of the Static Web App"
  value       = azurerm_static_web_app.this.default_host_name
}

output "static_web_app_api_key" {
  description = "API key for deploying content to the Static Web App"
  value       = azurerm_static_web_app.this.api_key
  sensitive   = true
}

output "static_web_app_identity_principal_id" {
  description = "Principal ID of the Static Web App managed identity (only available for Standard tier)"
  value       = length(azurerm_static_web_app.this.identity) > 0 ? azurerm_static_web_app.this.identity[0].principal_id : null
}
