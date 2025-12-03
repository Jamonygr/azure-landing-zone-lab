# Alerts Module Outputs

output "vm_cpu_alert_id" {
  description = "ID of the VM CPU alert"
  value       = length(azurerm_monitor_metric_alert.vm_cpu) > 0 ? azurerm_monitor_metric_alert.vm_cpu[0].id : null
}

output "vm_memory_alert_id" {
  description = "ID of the VM memory alert"
  value       = length(azurerm_monitor_metric_alert.vm_memory) > 0 ? azurerm_monitor_metric_alert.vm_memory[0].id : null
}

output "vm_disk_alert_id" {
  description = "ID of the VM disk alert"
  value       = length(azurerm_monitor_metric_alert.vm_disk_read) > 0 ? azurerm_monitor_metric_alert.vm_disk_read[0].id : null
}

output "vm_network_alert_id" {
  description = "ID of the VM network alert"
  value       = length(azurerm_monitor_metric_alert.vm_network) > 0 ? azurerm_monitor_metric_alert.vm_network[0].id : null
}

output "aks_cpu_alert_id" {
  description = "ID of the AKS CPU alert"
  value       = length(azurerm_monitor_metric_alert.aks_cpu) > 0 ? azurerm_monitor_metric_alert.aks_cpu[0].id : null
}

output "aks_memory_alert_id" {
  description = "ID of the AKS memory alert"
  value       = length(azurerm_monitor_metric_alert.aks_memory) > 0 ? azurerm_monitor_metric_alert.aks_memory[0].id : null
}

output "aks_node_count_alert_id" {
  description = "ID of the AKS node count alert"
  value       = length(azurerm_monitor_metric_alert.aks_node_count) > 0 ? azurerm_monitor_metric_alert.aks_node_count[0].id : null
}

output "aks_pods_alert_id" {
  description = "ID of the AKS pods alert"
  value       = length(azurerm_monitor_metric_alert.aks_pods) > 0 ? azurerm_monitor_metric_alert.aks_pods[0].id : null
}

output "sql_dtu_alert_id" {
  description = "ID of the SQL DTU alert"
  value       = length(azurerm_monitor_metric_alert.sql_dtu) > 0 ? azurerm_monitor_metric_alert.sql_dtu[0].id : null
}

output "sql_storage_alert_id" {
  description = "ID of the SQL storage alert"
  value       = length(azurerm_monitor_metric_alert.sql_storage) > 0 ? azurerm_monitor_metric_alert.sql_storage[0].id : null
}

output "sql_connection_alert_id" {
  description = "ID of the SQL connection alert"
  value       = length(azurerm_monitor_metric_alert.sql_connection_failed) > 0 ? azurerm_monitor_metric_alert.sql_connection_failed[0].id : null
}

output "firewall_health_alert_id" {
  description = "ID of the Firewall health alert"
  value       = length(azurerm_monitor_metric_alert.firewall_health) > 0 ? azurerm_monitor_metric_alert.firewall_health[0].id : null
}

output "firewall_throughput_alert_id" {
  description = "ID of the Firewall throughput alert"
  value       = length(azurerm_monitor_metric_alert.firewall_throughput) > 0 ? azurerm_monitor_metric_alert.firewall_throughput[0].id : null
}

output "vpn_tunnel_alert_id" {
  description = "ID of the VPN tunnel alert"
  value       = length(azurerm_monitor_metric_alert.vpn_tunnel_status) > 0 ? azurerm_monitor_metric_alert.vpn_tunnel_status[0].id : null
}

output "vpn_bandwidth_alert_id" {
  description = "ID of the VPN bandwidth alert"
  value       = length(azurerm_monitor_metric_alert.vpn_bandwidth) > 0 ? azurerm_monitor_metric_alert.vpn_bandwidth[0].id : null
}

output "all_alert_ids" {
  description = "List of all created alert IDs"
  value = compact([
    length(azurerm_monitor_metric_alert.vm_cpu) > 0 ? azurerm_monitor_metric_alert.vm_cpu[0].id : "",
    length(azurerm_monitor_metric_alert.vm_memory) > 0 ? azurerm_monitor_metric_alert.vm_memory[0].id : "",
    length(azurerm_monitor_metric_alert.vm_disk_read) > 0 ? azurerm_monitor_metric_alert.vm_disk_read[0].id : "",
    length(azurerm_monitor_metric_alert.vm_network) > 0 ? azurerm_monitor_metric_alert.vm_network[0].id : "",
    length(azurerm_monitor_metric_alert.aks_cpu) > 0 ? azurerm_monitor_metric_alert.aks_cpu[0].id : "",
    length(azurerm_monitor_metric_alert.aks_memory) > 0 ? azurerm_monitor_metric_alert.aks_memory[0].id : "",
    length(azurerm_monitor_metric_alert.aks_node_count) > 0 ? azurerm_monitor_metric_alert.aks_node_count[0].id : "",
    length(azurerm_monitor_metric_alert.aks_pods) > 0 ? azurerm_monitor_metric_alert.aks_pods[0].id : "",
    length(azurerm_monitor_metric_alert.sql_dtu) > 0 ? azurerm_monitor_metric_alert.sql_dtu[0].id : "",
    length(azurerm_monitor_metric_alert.sql_storage) > 0 ? azurerm_monitor_metric_alert.sql_storage[0].id : "",
    length(azurerm_monitor_metric_alert.sql_connection_failed) > 0 ? azurerm_monitor_metric_alert.sql_connection_failed[0].id : "",
    length(azurerm_monitor_metric_alert.firewall_health) > 0 ? azurerm_monitor_metric_alert.firewall_health[0].id : "",
    length(azurerm_monitor_metric_alert.firewall_throughput) > 0 ? azurerm_monitor_metric_alert.firewall_throughput[0].id : "",
    length(azurerm_monitor_metric_alert.vpn_tunnel_status) > 0 ? azurerm_monitor_metric_alert.vpn_tunnel_status[0].id : "",
    length(azurerm_monitor_metric_alert.vpn_bandwidth) > 0 ? azurerm_monitor_metric_alert.vpn_bandwidth[0].id : "",
  ])
}
