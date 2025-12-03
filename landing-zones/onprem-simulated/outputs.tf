# =============================================================================
# SIMULATED ON-PREMISES - OUTPUTS
# =============================================================================

output "vnet_id" {
  description = "On-Prem VNet ID"
  value       = module.onprem_vnet.id
}

output "vnet_name" {
  description = "On-Prem VNet name"
  value       = module.onprem_vnet.name
}

output "gateway_subnet_id" {
  description = "Gateway subnet ID"
  value       = module.onprem_gateway_subnet.id
}

output "servers_subnet_id" {
  description = "Servers subnet ID"
  value       = module.onprem_servers_subnet.id
}

output "vpn_gateway_id" {
  description = "On-Prem VPN Gateway ID"
  value       = module.onprem_vpn_gateway.id
}

output "vpn_gateway_public_ip" {
  description = "On-Prem VPN Gateway public IP"
  value       = module.onprem_vpn_gateway.public_ip_address
}

output "mgmt_vm_public_ip" {
  description = "On-Prem Management VM public IP (RDP access)"
  value       = azurerm_public_ip.onprem_mgmt.ip_address
}

output "mgmt_vm_private_ip" {
  description = "On-Prem Management VM private IP"
  value       = azurerm_network_interface.onprem_mgmt.private_ip_address
}

# Local Network Gateway (hub as seen from on-prem)
output "lng_to_hub_id" {
  description = "Local Network Gateway ID pointing to the hub"
  value       = var.deploy_vpn_connection ? module.lng_to_hub[0].id : null
}

# VPN connection from on-prem to hub
output "vpn_connection_to_hub_id" {
  description = "Site-to-site VPN connection ID from on-prem to hub"
  value       = var.deploy_vpn_connection ? module.vpn_connection_onprem_to_hub[0].id : null
}
