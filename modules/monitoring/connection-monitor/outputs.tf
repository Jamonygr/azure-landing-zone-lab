# =============================================================================
# CONNECTION MONITOR MODULE - OUTPUTS
# =============================================================================

output "connection_monitor_id" {
  description = "Connection Monitor ID"
  value       = azurerm_network_connection_monitor.monitor.id
}

output "connection_monitor_name" {
  description = "Connection Monitor name"
  value       = azurerm_network_connection_monitor.monitor.name
}

output "network_watcher_id" {
  description = "Network Watcher ID used"
  value       = local.network_watcher_id
}
