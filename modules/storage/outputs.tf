# =============================================================================
# STORAGE ACCOUNT MODULE - OUTPUTS
# =============================================================================

output "id" {
  description = "The ID of the storage account"
  value       = azurerm_storage_account.this.id
}

output "name" {
  description = "The name of the storage account"
  value       = azurerm_storage_account.this.name
}

output "primary_blob_endpoint" {
  description = "The primary blob endpoint"
  value       = azurerm_storage_account.this.primary_blob_endpoint
}

output "primary_file_endpoint" {
  description = "The primary file endpoint"
  value       = azurerm_storage_account.this.primary_file_endpoint
}

output "primary_access_key" {
  description = "The primary access key"
  value       = azurerm_storage_account.this.primary_access_key
  sensitive   = true
}

output "primary_connection_string" {
  description = "The primary connection string"
  value       = azurerm_storage_account.this.primary_connection_string
  sensitive   = true
}
