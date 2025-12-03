# =============================================================================
# LOCAL NETWORK GATEWAY MODULE - MAIN
# Represents the on-premises/remote VPN endpoint
# =============================================================================

resource "azurerm_local_network_gateway" "this" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  gateway_address     = var.gateway_address
  address_space       = var.address_space
  tags                = var.tags

  dynamic "bgp_settings" {
    for_each = var.enable_bgp ? [1] : []
    content {
      asn                 = var.bgp_asn
      bgp_peering_address = var.bgp_peering_address
    }
  }

  timeouts {
    create = "60m"
    update = "60m"
    delete = "60m"
    read   = "10m"
  }
}
