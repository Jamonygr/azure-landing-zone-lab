# =============================================================================
# NETWORKING PILLAR - OUTPUTS
# =============================================================================

output "vnet_id" {
  description = "Hub VNet ID"
  value       = module.hub.vnet_id
}

output "vnet_name" {
  description = "Hub VNet name"
  value       = module.hub.vnet_name
}

output "vnet_address_space" {
  description = "Hub VNet address space"
  value       = module.hub.vnet_address_space
}

output "gateway_subnet_id" {
  description = "Gateway subnet ID"
  value       = module.hub.gateway_subnet_id
}

output "firewall_subnet_id" {
  description = "Firewall subnet ID"
  value       = module.hub.firewall_subnet_id
}

output "mgmt_subnet_id" {
  description = "Hub management subnet ID"
  value       = module.hub.mgmt_subnet_id
}

output "firewall_private_ip" {
  description = "Azure Firewall private IP"
  value       = module.hub.firewall_private_ip
}

output "firewall_public_ip" {
  description = "Azure Firewall public IP"
  value       = module.hub.firewall_public_ip
}

output "firewall_policy_id" {
  description = "Azure Firewall policy ID"
  value       = module.hub.firewall_policy_id
}

output "firewall_id" {
  description = "Azure Firewall ID"
  value       = module.hub.firewall_id
}

output "vpn_gateway_id" {
  description = "VPN Gateway ID"
  value       = module.hub.vpn_gateway_id
}

output "vpn_gateway_public_ip" {
  description = "VPN Gateway public IP"
  value       = module.hub.vpn_gateway_public_ip
}

output "vpn_gateway_bgp_peering_address" {
  description = "VPN Gateway BGP peering address"
  value       = module.hub.vpn_gateway_bgp_peering_address
}

output "vpn_gateway_bgp_asn" {
  description = "VPN Gateway BGP ASN"
  value       = module.hub.vpn_gateway_bgp_asn
}

output "appgw_subnet_id" {
  description = "Application Gateway subnet ID"
  value       = module.hub.appgw_subnet_id
}

output "application_gateway_id" {
  description = "Application Gateway ID"
  value       = module.hub.application_gateway_id
}

output "application_gateway_name" {
  description = "Application Gateway name"
  value       = module.hub.application_gateway_name
}

output "application_gateway_public_ip" {
  description = "Application Gateway public IP"
  value       = module.hub.application_gateway_public_ip
}
