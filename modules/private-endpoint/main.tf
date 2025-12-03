# =============================================================================
# PRIVATE ENDPOINT MODULE - MAIN
# =============================================================================

resource "azurerm_private_endpoint" "this" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  subnet_id           = var.subnet_id
  tags                = var.tags

  private_service_connection {
    name                           = "${var.name}-connection"
    private_connection_resource_id = var.private_connection_resource_id
    subresource_names              = var.subresource_names
    is_manual_connection           = var.is_manual_connection
  }

  dynamic "private_dns_zone_group" {
    for_each = var.private_dns_zone_id != null ? [1] : []
    content {
      name                 = var.private_dns_zone_group_name
      private_dns_zone_ids = [var.private_dns_zone_id]
    }
  }
}
