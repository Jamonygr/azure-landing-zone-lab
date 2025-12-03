# =============================================================================
# ROUTE TABLE MODULE - OUTPUTS
# =============================================================================

output "id" {
  description = "The ID of the route table"
  value       = azurerm_route_table.this.id
}

output "name" {
  description = "The name of the route table"
  value       = azurerm_route_table.this.name
}
