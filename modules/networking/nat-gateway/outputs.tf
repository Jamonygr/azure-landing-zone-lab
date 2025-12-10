# =============================================================================
# NAT GATEWAY MODULE - OUTPUTS
# =============================================================================

output "id" {
  description = "The ID of the NAT Gateway"
  value       = azurerm_nat_gateway.this.id
}

output "name" {
  description = "The name of the NAT Gateway"
  value       = azurerm_nat_gateway.this.name
}

output "public_ip_id" {
  description = "The ID of the NAT Gateway Public IP"
  value       = azurerm_public_ip.nat.id
}

output "public_ip_address" {
  description = "The public IP address for outbound traffic"
  value       = azurerm_public_ip.nat.ip_address
}

output "resource_guid" {
  description = "The resource GUID of the NAT Gateway"
  value       = azurerm_nat_gateway.this.resource_guid
}
