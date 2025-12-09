# =============================================================================
# AZURE APPLICATION GATEWAY MODULE - Outputs
# =============================================================================

output "application_gateway_id" {
  description = "ID of the Application Gateway"
  value       = azurerm_application_gateway.this.id
}

output "application_gateway_name" {
  description = "Name of the Application Gateway"
  value       = azurerm_application_gateway.this.name
}

output "public_ip_id" {
  description = "ID of the public IP"
  value       = azurerm_public_ip.this.id
}

output "public_ip_address" {
  description = "Public IP address"
  value       = azurerm_public_ip.this.ip_address
}

output "public_ip_fqdn" {
  description = "FQDN of the public IP"
  value       = azurerm_public_ip.this.fqdn
}

output "frontend_ip_configuration" {
  description = "Frontend IP configuration details"
  value = {
    public_id  = azurerm_application_gateway.this.frontend_ip_configuration[0].id
    private_id = var.private_ip_address != null ? azurerm_application_gateway.this.frontend_ip_configuration[1].id : null
  }
}

output "backend_address_pool_ids" {
  description = "Map of backend address pool names to their IDs"
  value       = { for pool in azurerm_application_gateway.this.backend_address_pool : pool.name => pool.id }
}

output "user_assigned_identity_id" {
  description = "ID of the user-assigned managed identity"
  value       = var.enable_key_vault_integration ? azurerm_user_assigned_identity.this[0].id : null
}

output "user_assigned_identity_principal_id" {
  description = "Principal ID of the user-assigned managed identity"
  value       = var.enable_key_vault_integration ? azurerm_user_assigned_identity.this[0].principal_id : null
}
