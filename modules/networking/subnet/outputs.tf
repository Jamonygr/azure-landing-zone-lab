# =============================================================================
# SUBNET MODULE - OUTPUTS
# =============================================================================

output "id" {
  description = "The ID of the subnet"
  value       = azurerm_subnet.this.id
}

output "name" {
  description = "The name of the subnet"
  value       = azurerm_subnet.this.name
}

output "address_prefixes" {
  description = "The address prefixes of the subnet"
  value       = azurerm_subnet.this.address_prefixes
}
