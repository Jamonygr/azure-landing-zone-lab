# =============================================================================
# AZURE COSMOS DB MODULE - Serverless Capacity
# =============================================================================

# Cosmos DB Account
resource "azurerm_cosmosdb_account" "this" {
  name                = "cosmos-${var.name_suffix}"
  resource_group_name = var.resource_group_name
  location            = var.location
  offer_type          = "Standard"
  kind                = var.kind

  # Serverless capability
  dynamic "capabilities" {
    for_each = var.enable_serverless ? [1] : []
    content {
      name = "EnableServerless"
    }
  }

  # Additional capabilities
  dynamic "capabilities" {
    for_each = var.capabilities
    content {
      name = capabilities.value
    }
  }

  consistency_policy {
    consistency_level       = var.consistency_level
    max_interval_in_seconds = var.consistency_level == "BoundedStaleness" ? var.max_interval_in_seconds : null
    max_staleness_prefix    = var.consistency_level == "BoundedStaleness" ? var.max_staleness_prefix : null
  }

  geo_location {
    location          = var.location
    failover_priority = 0
  }

  public_network_access_enabled     = var.public_network_access_enabled
  is_virtual_network_filter_enabled = var.is_virtual_network_filter_enabled

  dynamic "virtual_network_rule" {
    for_each = var.virtual_network_rules
    content {
      id                                   = virtual_network_rule.value.subnet_id
      ignore_missing_vnet_service_endpoint = virtual_network_rule.value.ignore_missing_vnet_service_endpoint
    }
  }

  identity {
    type = "SystemAssigned"
  }

  tags = var.tags
}

# SQL Database (for SQL API)
resource "azurerm_cosmosdb_sql_database" "this" {
  count               = var.kind == "GlobalDocumentDB" && length(var.sql_databases) > 0 ? length(var.sql_databases) : 0
  name                = var.sql_databases[count.index].name
  resource_group_name = var.resource_group_name
  account_name        = azurerm_cosmosdb_account.this.name
}

# SQL Container
resource "azurerm_cosmosdb_sql_container" "this" {
  count                 = var.kind == "GlobalDocumentDB" ? length(var.sql_containers) : 0
  name                  = var.sql_containers[count.index].name
  resource_group_name   = var.resource_group_name
  account_name          = azurerm_cosmosdb_account.this.name
  database_name         = var.sql_containers[count.index].database_name
  partition_key_paths   = var.sql_containers[count.index].partition_key_paths
  partition_key_version = 2

  indexing_policy {
    indexing_mode = "consistent"

    included_path {
      path = "/*"
    }
  }

  depends_on = [azurerm_cosmosdb_sql_database.this]
}

# MongoDB Database
resource "azurerm_cosmosdb_mongo_database" "this" {
  count               = var.kind == "MongoDB" && length(var.mongo_databases) > 0 ? length(var.mongo_databases) : 0
  name                = var.mongo_databases[count.index].name
  resource_group_name = var.resource_group_name
  account_name        = azurerm_cosmosdb_account.this.name
}

# Diagnostic Settings
resource "azurerm_monitor_diagnostic_setting" "this" {
  count                      = var.enable_diagnostics ? 1 : 0
  name                       = "diag-${azurerm_cosmosdb_account.this.name}"
  target_resource_id         = azurerm_cosmosdb_account.this.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category = "DataPlaneRequests"
  }

  enabled_log {
    category = "QueryRuntimeStatistics"
  }

  enabled_log {
    category = "PartitionKeyStatistics"
  }

  enabled_metric {
    category = "Requests"
  }

  enabled_metric {
    category = "SLI"
  }
}
