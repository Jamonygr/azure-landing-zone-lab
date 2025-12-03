# =============================================================================
# LOCAL NETWORK GATEWAY MODULE - OUTPUTS
# =============================================================================

output "id" {
  description = "Local Network Gateway ID"
  value       = azurerm_local_network_gateway.this.id
}

output "name" {
  description = "Local Network Gateway name"
  value       = azurerm_local_network_gateway.this.name
}
