# =============================================================================
# AZURE SERVICE BUS MODULE - Outputs
# =============================================================================

output "namespace_id" {
  description = "ID of the Service Bus Namespace"
  value       = azurerm_servicebus_namespace.this.id
}

output "namespace_name" {
  description = "Name of the Service Bus Namespace"
  value       = azurerm_servicebus_namespace.this.name
}

output "namespace_endpoint" {
  description = "Endpoint of the Service Bus Namespace"
  value       = azurerm_servicebus_namespace.this.endpoint
}

output "identity_principal_id" {
  description = "Principal ID of the managed identity"
  value       = azurerm_servicebus_namespace.this.identity[0].principal_id
}

output "queue_ids" {
  description = "Map of queue names to their IDs"
  value       = { for k, v in azurerm_servicebus_queue.this : k => v.id }
}

output "topic_ids" {
  description = "Map of topic names to their IDs"
  value       = { for k, v in azurerm_servicebus_topic.this : k => v.id }
}

output "subscription_ids" {
  description = "Map of subscription names to their IDs"
  value       = { for k, v in azurerm_servicebus_subscription.this : k => v.id }
}
