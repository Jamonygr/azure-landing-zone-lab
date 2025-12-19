# =============================================================================
# SECURITY PILLAR - OUTPUTS
# =============================================================================

output "vnet_id" {
  description = "Shared services VNet ID"
  value       = module.shared_services.vnet_id
}

output "vnet_name" {
  description = "Shared services VNet name"
  value       = module.shared_services.vnet_name
}

output "app_subnet_id" {
  description = "Application subnet ID"
  value       = module.shared_services.app_subnet_id
}

output "pe_subnet_id" {
  description = "Private endpoint subnet ID"
  value       = module.shared_services.pe_subnet_id
}

output "keyvault_id" {
  description = "Key Vault ID"
  value       = module.shared_services.keyvault_id
}

output "keyvault_uri" {
  description = "Key Vault URI"
  value       = module.shared_services.keyvault_uri
}

output "storage_account_id" {
  description = "Storage account ID"
  value       = module.shared_services.storage_account_id
}

output "storage_account_name" {
  description = "Storage account name"
  value       = module.shared_services.storage_account_name
}

output "sql_server_id" {
  description = "SQL Server resource ID"
  value       = module.shared_services.sql_server_id
}

output "sql_server_fqdn" {
  description = "SQL Server FQDN"
  value       = module.shared_services.sql_server_fqdn
}

output "sql_database_id" {
  description = "SQL Database ID"
  value       = module.shared_services.sql_database_id
}

output "sql_database_name" {
  description = "SQL Database name"
  value       = module.shared_services.sql_database_name
}

output "private_dns_zone_blob_id" {
  description = "Private DNS zone ID for Blob"
  value       = var.deploy_private_dns_zones ? module.private_dns_blob[0].id : null
}

output "private_dns_zone_keyvault_id" {
  description = "Private DNS zone ID for Key Vault"
  value       = var.deploy_private_dns_zones ? module.private_dns_keyvault[0].id : null
}

output "private_dns_zone_sql_id" {
  description = "Private DNS zone ID for SQL"
  value       = var.deploy_private_dns_zones ? module.private_dns_sql[0].id : null
}
