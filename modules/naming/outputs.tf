# =============================================================================
# NAMING CONVENTION MODULE - OUTPUTS
# =============================================================================

output "prefix" {
  description = "Base naming prefix"
  value       = local.prefix
}

output "location_short" {
  description = "Short location code"
  value       = local.loc
}

output "resource_group" {
  description = "Resource group name format"
  value       = "rg-${local.prefix}"
}

output "virtual_network" {
  description = "Virtual network name format"
  value       = "vnet-${local.prefix}"
}

output "subnet" {
  description = "Subnet name format"
  value       = "snet-${local.prefix}"
}

output "network_security_group" {
  description = "NSG name format"
  value       = "nsg-${local.prefix}"
}

output "route_table" {
  description = "Route table name format"
  value       = "rt-${local.prefix}"
}

output "virtual_machine" {
  description = "Virtual machine name format"
  value       = "vm-${local.prefix}"
}

output "network_interface" {
  description = "Network interface name format"
  value       = "nic-${local.prefix}"
}

output "public_ip" {
  description = "Public IP name format"
  value       = "pip-${local.prefix}"
}

output "firewall" {
  description = "Firewall name format"
  value       = "afw-${local.prefix}"
}

output "firewall_policy" {
  description = "Firewall policy name format"
  value       = "afwp-${local.prefix}"
}

output "vpn_gateway" {
  description = "VPN Gateway name format"
  value       = "vpng-${local.prefix}"
}

output "local_network_gateway" {
  description = "Local network gateway name format"
  value       = "lgw-${local.prefix}"
}

output "connection" {
  description = "Connection name format"
  value       = "con-${local.prefix}"
}

output "storage_account" {
  description = "Storage account name format"
  value       = lower(substr(replace("st${var.project}${var.environment}${local.loc}${var.instance}", "-", ""), 0, 24))
}

output "key_vault" {
  description = "Key Vault name format"
  value       = "kv-${var.project}-${var.environment}-${var.instance}"
}

output "log_analytics" {
  description = "Log Analytics name format"
  value       = "log-${local.prefix}"
}

output "sql_server" {
  description = "SQL Server name format"
  value       = "sql-${local.prefix}"
}

output "sql_database" {
  description = "SQL Database name format"
  value       = "sqldb-${local.prefix}"
}

output "recovery_vault" {
  description = "Recovery vault name format"
  value       = "rsv-${local.prefix}"
}

output "private_endpoint" {
  description = "Private endpoint name format"
  value       = "pe-${local.prefix}"
}

output "bastion" {
  description = "Bastion name format"
  value       = "bas-${local.prefix}"
}
