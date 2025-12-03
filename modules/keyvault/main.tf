# =============================================================================
# AZURE KEY VAULT MODULE - MAIN
# =============================================================================

# Data source for current client
data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "this" {
  name                            = var.name
  resource_group_name             = var.resource_group_name
  location                        = var.location
  tenant_id                       = var.tenant_id
  sku_name                        = var.sku_name
  soft_delete_retention_days      = var.soft_delete_retention_days
  purge_protection_enabled        = var.purge_protection_enabled
  enable_rbac_authorization       = var.enable_rbac_authorization
  enabled_for_deployment          = var.enabled_for_deployment
  enabled_for_disk_encryption     = var.enabled_for_disk_encryption
  enabled_for_template_deployment = var.enabled_for_template_deployment
  tags                            = var.tags

  network_acls {
    bypass                     = var.network_acls.bypass
    default_action             = var.network_acls.default_action
    ip_rules                   = var.network_acls.ip_rules
    virtual_network_subnet_ids = var.network_acls.virtual_network_subnet_ids
  }
}

# RBAC Role Assignment for current user/service principal
resource "azurerm_role_assignment" "keyvault_admin" {
  scope                = azurerm_key_vault.this.id
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = data.azurerm_client_config.current.object_id
}

# Key Vault Secrets
resource "azurerm_key_vault_secret" "this" {
  for_each     = nonsensitive(var.secrets)
  name         = each.key
  value        = each.value.value
  key_vault_id = azurerm_key_vault.this.id
  content_type = each.value.content_type

  depends_on = [azurerm_role_assignment.keyvault_admin]
}
