# =============================================================================
# STORAGE ACCOUNT MODULE - MAIN
# =============================================================================

resource "azurerm_storage_account" "this" {
  name                            = var.name
  resource_group_name             = var.resource_group_name
  location                        = var.location
  account_tier                    = var.account_tier
  account_replication_type        = var.account_replication_type
  account_kind                    = var.account_kind
  access_tier                     = var.access_tier
  min_tls_version                 = var.min_tls_version
  allow_nested_items_to_be_public = var.allow_nested_items_to_be_public
  tags                            = var.tags

  dynamic "network_rules" {
    for_each = var.network_rules != null ? [var.network_rules] : []
    content {
      default_action             = network_rules.value.default_action
      bypass                     = network_rules.value.bypass
      ip_rules                   = network_rules.value.ip_rules
      virtual_network_subnet_ids = network_rules.value.virtual_network_subnet_ids
    }
  }
}

# Blob Containers
resource "azurerm_storage_container" "this" {
  for_each              = { for c in var.containers : c.name => c }
  name                  = each.value.name
  storage_account_name  = azurerm_storage_account.this.name
  container_access_type = each.value.container_access_type
}

# File Shares
resource "azurerm_storage_share" "this" {
  for_each             = { for s in var.file_shares : s.name => s }
  name                 = each.value.name
  storage_account_name = azurerm_storage_account.this.name
  quota                = each.value.quota
}
