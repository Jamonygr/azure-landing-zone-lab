# =============================================================================
# PRIVATE ENDPOINT MODULE - OUTPUTS
# =============================================================================

output "id" {
  description = "The ID of the private endpoint"
  value       = azurerm_private_endpoint.this.id
}

output "name" {
  description = "The name of the private endpoint"
  value       = azurerm_private_endpoint.this.name
}

output "private_ip_address" {
  description = "The private IP address of the endpoint"
  value       = azurerm_private_endpoint.this.private_service_connection[0].private_ip_address
}

output "network_interface_id" {
  description = "The ID of the network interface"
  value       = azurerm_private_endpoint.this.network_interface[0].id
}
