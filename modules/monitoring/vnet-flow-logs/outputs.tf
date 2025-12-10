# =============================================================================
# VIRTUAL NETWORK FLOW LOGS MODULE - OUTPUTS
# =============================================================================

output "flow_log_id" {
  description = "Resource ID of the VNet Flow Log"
  value       = azapi_resource.vnet_flow_log.id
}

output "flow_log_name" {
  description = "Name of the VNet Flow Log"
  value       = azapi_resource.vnet_flow_log.name
}

output "target_vnet_id" {
  description = "ID of the monitored Virtual Network"
  value       = var.virtual_network_id
}

output "storage_account_id" {
  description = "ID of the storage account used for flow logs"
  value       = var.storage_account_id
}

output "traffic_analytics_enabled" {
  description = "Whether Traffic Analytics is enabled"
  value       = var.enable_traffic_analytics
}
