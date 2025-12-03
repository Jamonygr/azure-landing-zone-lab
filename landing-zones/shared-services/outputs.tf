# =============================================================================
# SHARED SERVICES LANDING ZONE - OUTPUTS
# =============================================================================

output "vnet_id" {
  description = "Shared Services VNet ID"
  value       = module.shared_vnet.id
}

output "vnet_name" {
  description = "Shared Services VNet name"
  value       = module.shared_vnet.name
}

output "app_subnet_id" {
  description = "Application subnet ID"
  value       = module.app_subnet.id
}

output "pe_subnet_id" {
  description = "Private Endpoint subnet ID"
  value       = module.pe_subnet.id
}

output "keyvault_id" {
  description = "Key Vault ID"
  value       = var.deploy_keyvault ? module.keyvault[0].id : null
}

output "keyvault_uri" {
  description = "Key Vault URI"
  value       = var.deploy_keyvault ? module.keyvault[0].uri : null
}

output "storage_account_id" {
  description = "Storage Account ID"
  value       = var.deploy_storage ? module.storage[0].id : null
}

output "storage_account_name" {
  description = "Storage Account name"
  value       = var.deploy_storage ? module.storage[0].name : null
}

output "sql_server_fqdn" {
  description = "SQL Server FQDN"
  value       = var.deploy_sql ? module.sql[0].server_fqdn : null
}

output "sql_database_name" {
  description = "SQL Database name"
  value       = var.deploy_sql ? module.sql[0].database_name : null
}
