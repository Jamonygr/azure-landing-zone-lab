# =============================================================================
# AZURE FIREWALL RULES MODULE - OUTPUTS
# =============================================================================

output "id" {
  description = "The ID of the rule collection group"
  value       = azurerm_firewall_policy_rule_collection_group.this.id
}

output "name" {
  description = "The name of the rule collection group"
  value       = azurerm_firewall_policy_rule_collection_group.this.name
}
