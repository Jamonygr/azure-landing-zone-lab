# =============================================================================
# ROUTE TABLE MODULE - MAIN
# =============================================================================

resource "azurerm_route_table" "this" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags

  dynamic "route" {
    for_each = var.routes
    content {
      name                   = route.value.name
      address_prefix         = route.value.address_prefix
      next_hop_type          = route.value.next_hop_type
      next_hop_in_ip_address = route.value.next_hop_in_ip_address
    }
  }
}

# Associate route table with subnets
resource "azurerm_subnet_route_table_association" "this" {
  count          = length(var.subnet_ids)
  subnet_id      = var.subnet_ids[count.index]
  route_table_id = azurerm_route_table.this.id

  timeouts {
    create = "30m"
  }
}
