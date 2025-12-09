# =============================================================================
# AZURE APP SERVICE MODULE - Outputs
# =============================================================================

output "service_plan_id" {
  description = "ID of the App Service Plan"
  value       = azurerm_service_plan.this.id
}

output "service_plan_name" {
  description = "Name of the App Service Plan"
  value       = azurerm_service_plan.this.name
}

output "web_app_id" {
  description = "ID of the Web App"
  value       = var.os_type == "Linux" ? azurerm_linux_web_app.this[0].id : azurerm_windows_web_app.this[0].id
}

output "web_app_name" {
  description = "Name of the Web App"
  value       = var.os_type == "Linux" ? azurerm_linux_web_app.this[0].name : azurerm_windows_web_app.this[0].name
}

output "web_app_default_hostname" {
  description = "Default hostname of the Web App"
  value       = var.os_type == "Linux" ? azurerm_linux_web_app.this[0].default_hostname : azurerm_windows_web_app.this[0].default_hostname
}

output "web_app_identity_principal_id" {
  description = "Principal ID of the Web App managed identity"
  value       = var.os_type == "Linux" ? azurerm_linux_web_app.this[0].identity[0].principal_id : azurerm_windows_web_app.this[0].identity[0].principal_id
}

output "application_insights_id" {
  description = "ID of Application Insights"
  value       = var.enable_app_insights ? azurerm_application_insights.this[0].id : null
}

output "application_insights_instrumentation_key" {
  description = "Instrumentation key for Application Insights"
  value       = var.enable_app_insights ? azurerm_application_insights.this[0].instrumentation_key : null
  sensitive   = true
}

output "application_insights_connection_string" {
  description = "Connection string for Application Insights"
  value       = var.enable_app_insights ? azurerm_application_insights.this[0].connection_string : null
  sensitive   = true
}
