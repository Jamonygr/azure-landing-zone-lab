# =============================================================================
# HUB LANDING ZONE - OUTPUTS
# =============================================================================

output "vnet_id" {
  description = "Hub VNet ID"
  value       = module.hub_vnet.id
}

output "vnet_name" {
  description = "Hub VNet name"
  value       = module.hub_vnet.name
}

output "vnet_address_space" {
  description = "Hub VNet address space"
  value       = module.hub_vnet.address_space
}

output "gateway_subnet_id" {
  description = "Gateway subnet ID"
  value       = module.gateway_subnet.id
}

output "firewall_subnet_id" {
  description = "Firewall subnet ID"
  value       = module.firewall_subnet.id
}

output "mgmt_subnet_id" {
  description = "Management subnet ID"
  value       = module.hub_mgmt_subnet.id
}

output "firewall_private_ip" {
  description = "Azure Firewall private IP"
  value       = var.deploy_firewall ? module.firewall[0].private_ip_address : null
}

output "firewall_id" {
  description = "Azure Firewall ID"
  value       = var.deploy_firewall ? module.firewall[0].id : null
}

output "firewall_public_ip" {
  description = "Azure Firewall public IP"
  value       = var.deploy_firewall ? module.firewall[0].public_ip_address : null
}

output "firewall_policy_id" {
  description = "Azure Firewall policy ID"
  value       = var.deploy_firewall ? module.firewall[0].policy_id : null
}

output "vpn_gateway_id" {
  description = "VPN Gateway ID"
  value       = var.deploy_vpn_gateway ? module.vpn_gateway[0].id : null
}

output "vpn_gateway_public_ip" {
  description = "VPN Gateway public IP"
  value       = var.deploy_vpn_gateway ? module.vpn_gateway[0].public_ip_address : null
}

output "vpn_gateway_bgp_peering_address" {
  description = "VPN Gateway BGP peering address"
  value       = var.deploy_vpn_gateway && var.enable_bgp ? module.vpn_gateway[0].bgp_peering_address : null
}

output "vpn_gateway_bgp_asn" {
  description = "VPN Gateway BGP ASN"
  value       = var.deploy_vpn_gateway && var.enable_bgp ? var.hub_bgp_asn : null
}

# =============================================================================
# APPLICATION GATEWAY OUTPUTS
# =============================================================================

output "appgw_subnet_id" {
  description = "Application Gateway subnet ID"
  value       = var.deploy_application_gateway ? module.appgw_subnet[0].id : null
}

output "application_gateway_id" {
  description = "Application Gateway ID"
  value       = var.deploy_application_gateway ? module.application_gateway[0].application_gateway_id : null
}

output "application_gateway_name" {
  description = "Application Gateway name"
  value       = var.deploy_application_gateway ? module.application_gateway[0].application_gateway_name : null
}

output "application_gateway_public_ip" {
  description = "Application Gateway public IP address"
  value       = var.deploy_application_gateway ? module.application_gateway[0].public_ip_address : null
}
