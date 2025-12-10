# =============================================================================
# NSG FLOW LOGS MODULE - OUTPUTS
# =============================================================================

output "id" {
  description = "The ID of the NSG Flow Log"
  value       = azurerm_network_watcher_flow_log.this.id
}

output "name" {
  description = "The name of the NSG Flow Log"
  value       = azurerm_network_watcher_flow_log.this.name
}

output "network_watcher_id" {
  description = "The ID of the Network Watcher"
  value       = local.network_watcher_id
}
