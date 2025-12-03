# =============================================================================
# VPN CONNECTION MODULE - OUTPUTS
# =============================================================================

output "id" {
  description = "The ID of the VPN connection"
  value       = azurerm_virtual_network_gateway_connection.this.id
}

output "name" {
  description = "The name of the VPN connection"
  value       = azurerm_virtual_network_gateway_connection.this.name
}
