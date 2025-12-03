# =============================================================================
# VIRTUAL NETWORK MODULE - MAIN
# =============================================================================

resource "azurerm_virtual_network" "this" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  address_space       = var.address_space
  dns_servers         = length(var.dns_servers) > 0 ? var.dns_servers : null
  tags                = var.tags
}
