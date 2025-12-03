# =============================================================================
# VPN GATEWAY MODULE - OUTPUTS
# =============================================================================

output "id" {
  description = "The ID of the VPN Gateway"
  value       = azurerm_virtual_network_gateway.this.id
}

output "name" {
  description = "The name of the VPN Gateway"
  value       = azurerm_virtual_network_gateway.this.name
}

output "public_ip_address" {
  description = "The public IP address of the VPN Gateway"
  value       = azurerm_public_ip.this.ip_address
}

output "public_ip_id" {
  description = "The ID of the public IP"
  value       = azurerm_public_ip.this.id
}

output "bgp_peering_address" {
  description = "The BGP peering address"
  value       = var.enable_bgp ? azurerm_virtual_network_gateway.this.bgp_settings[0].peering_addresses[0].default_addresses[0] : null
}
