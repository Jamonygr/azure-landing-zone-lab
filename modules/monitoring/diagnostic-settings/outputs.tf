# Diagnostic Settings Module Outputs

output "firewall_diagnostic_id" {
  description = "ID of the Firewall diagnostic setting"
  value       = length(azurerm_monitor_diagnostic_setting.firewall) > 0 ? azurerm_monitor_diagnostic_setting.firewall[0].id : null
}

output "vpn_gateway_diagnostic_id" {
  description = "ID of the VPN Gateway diagnostic setting"
  value       = length(azurerm_monitor_diagnostic_setting.vpn_gateway) > 0 ? azurerm_monitor_diagnostic_setting.vpn_gateway[0].id : null
}

output "aks_diagnostic_id" {
  description = "ID of the AKS diagnostic setting"
  value       = length(azurerm_monitor_diagnostic_setting.aks) > 0 ? azurerm_monitor_diagnostic_setting.aks[0].id : null
}

output "sql_server_diagnostic_id" {
  description = "ID of the SQL Server diagnostic setting"
  value       = length(azurerm_monitor_diagnostic_setting.sql_server) > 0 ? azurerm_monitor_diagnostic_setting.sql_server[0].id : null
}

output "sql_database_diagnostic_id" {
  description = "ID of the SQL Database diagnostic setting"
  value       = length(azurerm_monitor_diagnostic_setting.sql_database) > 0 ? azurerm_monitor_diagnostic_setting.sql_database[0].id : null
}

output "keyvault_diagnostic_id" {
  description = "ID of the Key Vault diagnostic setting"
  value       = length(azurerm_monitor_diagnostic_setting.keyvault) > 0 ? azurerm_monitor_diagnostic_setting.keyvault[0].id : null
}

output "storage_diagnostic_id" {
  description = "ID of the Storage Account diagnostic setting"
  value       = length(azurerm_monitor_diagnostic_setting.storage) > 0 ? azurerm_monitor_diagnostic_setting.storage[0].id : null
}

output "nsg_diagnostic_ids" {
  description = "Map of NSG diagnostic setting IDs"
  value       = { for k, v in azurerm_monitor_diagnostic_setting.nsg : k => v.id }
}
