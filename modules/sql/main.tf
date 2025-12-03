# =============================================================================
# AZURE SQL DATABASE MODULE - MAIN
# =============================================================================

# SQL Server
resource "azurerm_mssql_server" "this" {
  name                          = var.server_name
  resource_group_name           = var.resource_group_name
  location                      = var.location
  version                       = "12.0"
  administrator_login           = var.admin_login
  administrator_login_password  = var.admin_password
  minimum_tls_version           = var.min_tls_version
  public_network_access_enabled = var.public_network_access_enabled
  tags                          = var.tags

  dynamic "azuread_administrator" {
    for_each = var.azuread_admin != null ? [var.azuread_admin] : []
    content {
      login_username = azuread_administrator.value.login_username
      object_id      = azuread_administrator.value.object_id
    }
  }
}

# SQL Database
resource "azurerm_mssql_database" "this" {
  name         = var.database_name
  server_id    = azurerm_mssql_server.this.id
  sku_name     = var.sku_name
  max_size_gb  = var.max_size_gb
  collation    = "SQL_Latin1_General_CP1_CI_AS"
  license_type = "LicenseIncluded"
  tags         = var.tags
}

# Firewall Rules
resource "azurerm_mssql_firewall_rule" "this" {
  for_each         = { for rule in var.allowed_ip_addresses : rule.name => rule }
  name             = each.value.name
  server_id        = azurerm_mssql_server.this.id
  start_ip_address = each.value.start_ip_address
  end_ip_address   = each.value.end_ip_address
}

# Allow Azure Services
resource "azurerm_mssql_firewall_rule" "azure_services" {
  count            = var.allow_azure_services ? 1 : 0
  name             = "AllowAzureServices"
  server_id        = azurerm_mssql_server.this.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}
