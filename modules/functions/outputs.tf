# =============================================================================
# AZURE FUNCTIONS MODULE - Outputs
# =============================================================================

output "function_app_id" {
  description = "ID of the Function App"
  value       = var.os_type == "Linux" ? azurerm_linux_function_app.this[0].id : azurerm_windows_function_app.this[0].id
}

output "function_app_name" {
  description = "Name of the Function App"
  value       = var.os_type == "Linux" ? azurerm_linux_function_app.this[0].name : azurerm_windows_function_app.this[0].name
}

output "function_app_default_hostname" {
  description = "Default hostname of the Function App"
  value       = var.os_type == "Linux" ? azurerm_linux_function_app.this[0].default_hostname : azurerm_windows_function_app.this[0].default_hostname
}

output "function_app_identity_principal_id" {
  description = "Principal ID of the Function App managed identity"
  value       = var.os_type == "Linux" ? azurerm_linux_function_app.this[0].identity[0].principal_id : azurerm_windows_function_app.this[0].identity[0].principal_id
}

output "storage_account_id" {
  description = "ID of the storage account"
  value       = azurerm_storage_account.function.id
}

output "storage_account_name" {
  description = "Name of the storage account"
  value       = azurerm_storage_account.function.name
}

output "service_plan_id" {
  description = "ID of the App Service Plan"
  value       = azurerm_service_plan.function.id
}

output "application_insights_id" {
  description = "ID of Application Insights"
  value       = var.enable_app_insights ? azurerm_application_insights.function[0].id : null
}

output "application_insights_instrumentation_key" {
  description = "Instrumentation key for Application Insights"
  value       = var.enable_app_insights ? azurerm_application_insights.function[0].instrumentation_key : null
  sensitive   = true
}

output "application_insights_connection_string" {
  description = "Connection string for Application Insights"
  value       = var.enable_app_insights ? azurerm_application_insights.function[0].connection_string : null
  sensitive   = true
}
