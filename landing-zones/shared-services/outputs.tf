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

output "app_nsg_id" {
  description = "Application subnet NSG ID"
  value       = module.app_nsg.id
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

output "sql_server_id" {
  description = "SQL Server resource ID"
  value       = var.deploy_sql ? module.sql[0].server_id : null
}

output "sql_database_id" {
  description = "SQL Database resource ID"
  value       = var.deploy_sql ? module.sql[0].database_id : null
}

output "sql_database_name" {
  description = "SQL Database name"
  value       = var.deploy_sql ? module.sql[0].database_name : null
}

# =============================================================================
# PRIVATE ENDPOINT OUTPUTS
# =============================================================================

output "keyvault_private_endpoint_id" {
  description = "Key Vault Private Endpoint ID"
  value       = var.deploy_private_endpoints && var.deploy_keyvault ? module.keyvault_private_endpoint[0].id : null
}

output "storage_private_endpoint_id" {
  description = "Storage Account Private Endpoint ID"
  value       = var.deploy_private_endpoints && var.deploy_storage ? module.storage_private_endpoint[0].id : null
}

output "sql_private_endpoint_id" {
  description = "SQL Server Private Endpoint ID"
  value       = var.deploy_private_endpoints && var.deploy_sql ? module.sql_private_endpoint[0].id : null
}
