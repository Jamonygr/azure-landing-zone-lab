# =============================================================================
# AZURE COSMOS DB MODULE - Outputs
# =============================================================================

output "account_id" {
  description = "ID of the Cosmos DB account"
  value       = azurerm_cosmosdb_account.this.id
}

output "account_name" {
  description = "Name of the Cosmos DB account"
  value       = azurerm_cosmosdb_account.this.name
}

output "account_endpoint" {
  description = "Endpoint of the Cosmos DB account"
  value       = azurerm_cosmosdb_account.this.endpoint
}

output "identity_principal_id" {
  description = "Principal ID of the managed identity"
  value       = azurerm_cosmosdb_account.this.identity[0].principal_id
}

output "sql_database_ids" {
  description = "List of SQL database IDs"
  value       = [for db in azurerm_cosmosdb_sql_database.this : db.id]
}

output "sql_container_ids" {
  description = "List of SQL container IDs"
  value       = [for container in azurerm_cosmosdb_sql_container.this : container.id]
}

output "mongo_database_ids" {
  description = "List of MongoDB database IDs"
  value       = [for db in azurerm_cosmosdb_mongo_database.this : db.id]
}
