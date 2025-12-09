# =============================================================================
# AZURE STATIC WEB APP MODULE - Free Tier
# =============================================================================

resource "azurerm_static_web_app" "this" {
  name                = "stapp-${var.name_suffix}"
  resource_group_name = var.resource_group_name
  location            = var.location
  sku_tier            = var.sku_tier
  sku_size            = var.sku_size

  # Identity only available for Standard tier
  dynamic "identity" {
    for_each = var.sku_tier != "Free" ? [1] : []
    content {
      type = "SystemAssigned"
    }
  }

  tags = var.tags
}

# Custom domain (optional)
resource "azurerm_static_web_app_custom_domain" "this" {
  count             = var.custom_domain != null ? 1 : 0
  static_web_app_id = azurerm_static_web_app.this.id
  domain_name       = var.custom_domain
  validation_type   = "cname-delegation"
}
