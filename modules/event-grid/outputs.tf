# =============================================================================
# AZURE EVENT GRID MODULE - Outputs
# =============================================================================

output "custom_topic_id" {
  description = "ID of the custom Event Grid topic"
  value       = var.create_custom_topic ? azurerm_eventgrid_topic.this[0].id : null
}

output "custom_topic_name" {
  description = "Name of the custom Event Grid topic"
  value       = var.create_custom_topic ? azurerm_eventgrid_topic.this[0].name : null
}

output "custom_topic_endpoint" {
  description = "Endpoint of the custom Event Grid topic"
  value       = var.create_custom_topic ? azurerm_eventgrid_topic.this[0].endpoint : null
}

output "custom_topic_primary_access_key" {
  description = "Primary access key for the custom topic"
  value       = var.create_custom_topic ? azurerm_eventgrid_topic.this[0].primary_access_key : null
  sensitive   = true
}

output "custom_topic_secondary_access_key" {
  description = "Secondary access key for the custom topic"
  value       = var.create_custom_topic ? azurerm_eventgrid_topic.this[0].secondary_access_key : null
  sensitive   = true
}

output "custom_topic_identity_principal_id" {
  description = "Principal ID of the custom topic managed identity"
  value       = var.create_custom_topic ? azurerm_eventgrid_topic.this[0].identity[0].principal_id : null
}

output "system_topic_id" {
  description = "ID of the system Event Grid topic"
  value       = var.create_system_topic ? azurerm_eventgrid_system_topic.this[0].id : null
}

output "system_topic_name" {
  description = "Name of the system Event Grid topic"
  value       = var.create_system_topic ? azurerm_eventgrid_system_topic.this[0].name : null
}

output "system_topic_identity_principal_id" {
  description = "Principal ID of the system topic managed identity"
  value       = var.create_system_topic ? azurerm_eventgrid_system_topic.this[0].identity[0].principal_id : null
}
