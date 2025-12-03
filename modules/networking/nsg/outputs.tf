# =============================================================================
# NETWORK SECURITY GROUP MODULE - OUTPUTS
# =============================================================================

output "id" {
  description = "The ID of the NSG"
  value       = azurerm_network_security_group.this.id
}

output "name" {
  description = "The name of the NSG"
  value       = azurerm_network_security_group.this.name
}
