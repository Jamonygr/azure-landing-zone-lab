# =============================================================================
# APPLICATION SECURITY GROUP MODULE - OUTPUTS
# =============================================================================

output "id" {
  description = "The ID of the Application Security Group"
  value       = azurerm_application_security_group.this.id
}

output "name" {
  description = "The name of the Application Security Group"
  value       = azurerm_application_security_group.this.name
}
