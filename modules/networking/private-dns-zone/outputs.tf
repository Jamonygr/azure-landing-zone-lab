# =============================================================================
# PRIVATE DNS ZONE MODULE - OUTPUTS
# =============================================================================

output "id" {
  description = "The ID of the Private DNS Zone"
  value       = azurerm_private_dns_zone.this.id
}

output "name" {
  description = "The name of the Private DNS Zone"
  value       = azurerm_private_dns_zone.this.name
}

output "number_of_record_sets" {
  description = "The current number of record sets in this Private DNS Zone"
  value       = azurerm_private_dns_zone.this.number_of_record_sets
}

output "virtual_network_link_ids" {
  description = "Map of VNet link names to their IDs"
  value       = { for k, v in azurerm_private_dns_zone_virtual_network_link.this : k => v.id }
}
