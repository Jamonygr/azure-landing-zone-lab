# =============================================================================
# IDENTITY MANAGEMENT PILLAR - OUTPUTS
# =============================================================================

output "vnet_id" {
  description = "Identity VNet ID"
  value       = module.identity.vnet_id
}

output "vnet_name" {
  description = "Identity VNet name"
  value       = module.identity.vnet_name
}

output "dc_subnet_id" {
  description = "DC subnet ID"
  value       = module.identity.dc_subnet_id
}

output "dc01_private_ip" {
  description = "DC01 private IP"
  value       = module.identity.dc01_private_ip
}

output "dc02_private_ip" {
  description = "DC02 private IP"
  value       = module.identity.dc02_private_ip
}

output "dns_servers" {
  description = "DNS servers (DC IPs)"
  value       = module.identity.dns_servers
}

output "dc01_id" {
  description = "DC01 VM ID"
  value       = module.identity.dc01_id
}

output "dc02_id" {
  description = "DC02 VM ID"
  value       = module.identity.dc02_id
}

output "dc_nsg_id" {
  description = "DC NSG ID"
  value       = module.identity.dc_nsg_id
}
