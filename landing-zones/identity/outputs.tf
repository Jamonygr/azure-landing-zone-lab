# =============================================================================
# IDENTITY LANDING ZONE - OUTPUTS
# =============================================================================

output "vnet_id" {
  description = "Identity VNet ID"
  value       = module.identity_vnet.id
}

output "vnet_name" {
  description = "Identity VNet name"
  value       = module.identity_vnet.name
}

output "dc_subnet_id" {
  description = "DC subnet ID"
  value       = module.dc_subnet.id
}

output "dc01_private_ip" {
  description = "DC01 private IP"
  value       = module.dc01.private_ip_address
}

output "dc02_private_ip" {
  description = "DC02 private IP"
  value       = var.deploy_secondary_dc ? module.dc02[0].private_ip_address : null
}

output "dns_servers" {
  description = "DNS server IPs"
  value       = var.deploy_secondary_dc ? [module.dc01.private_ip_address, module.dc02[0].private_ip_address] : [module.dc01.private_ip_address]
}

output "dc01_id" {
  description = "DC01 VM ID"
  value       = module.dc01.id
}

output "dc02_id" {
  description = "DC02 VM ID"
  value       = var.deploy_secondary_dc ? module.dc02[0].id : null
}

output "dc_nsg_id" {
  description = "Domain Controllers NSG ID"
  value       = module.dc_nsg.id
}
