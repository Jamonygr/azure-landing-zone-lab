# =============================================================================
# AZURE FIREWALL MODULE - OUTPUTS
# =============================================================================

output "id" {
  description = "The ID of the Azure Firewall"
  value       = azurerm_firewall.this.id
}

output "name" {
  description = "The name of the Azure Firewall"
  value       = azurerm_firewall.this.name
}

output "private_ip_address" {
  description = "The private IP address of the Azure Firewall"
  value       = azurerm_firewall.this.ip_configuration[0].private_ip_address
}

output "public_ip_address" {
  description = "The public IP address of the Azure Firewall"
  value       = azurerm_public_ip.this.ip_address
}

output "policy_id" {
  description = "The ID of the Firewall Policy"
  value       = azurerm_firewall_policy.this.id
}

output "policy_name" {
  description = "The name of the Firewall Policy"
  value       = azurerm_firewall_policy.this.name
}
