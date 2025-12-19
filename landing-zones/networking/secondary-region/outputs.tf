# =============================================================================
# SECONDARY REGION LANDING ZONE - OUTPUTS
# =============================================================================

output "resource_group_name" {
  description = "Secondary region resource group name"
  value       = azurerm_resource_group.secondary.name
}

output "resource_group_id" {
  description = "Secondary region resource group ID"
  value       = azurerm_resource_group.secondary.id
}

output "vnet_id" {
  description = "Secondary hub VNet ID"
  value       = azurerm_virtual_network.secondary_hub.id
}

output "vnet_name" {
  description = "Secondary hub VNet name"
  value       = azurerm_virtual_network.secondary_hub.name
}

output "mgmt_subnet_id" {
  description = "Management subnet ID"
  value       = azurerm_subnet.mgmt.id
}

output "vm_id" {
  description = "Windows Server 2025 VM ID"
  value       = var.deploy_vm ? azurerm_windows_virtual_machine.vm[0].id : null
}

output "vm_name" {
  description = "Windows Server 2025 VM name"
  value       = var.deploy_vm ? azurerm_windows_virtual_machine.vm[0].name : null
}

output "vm_private_ip" {
  description = "Windows Server 2025 VM private IP"
  value       = var.deploy_vm ? azurerm_network_interface.vm[0].private_ip_address : null
}

output "peering_id_secondary_to_primary" {
  description = "Peering ID from secondary to primary"
  value       = azurerm_virtual_network_peering.secondary_to_primary.id
}

output "peering_id_primary_to_secondary" {
  description = "Peering ID from primary to secondary"
  value       = azurerm_virtual_network_peering.primary_to_secondary.id
}
