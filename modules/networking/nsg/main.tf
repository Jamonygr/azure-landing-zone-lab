# =============================================================================
# NETWORK SECURITY GROUP MODULE - MAIN
# =============================================================================

resource "azurerm_network_security_group" "this" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags

  dynamic "security_rule" {
    for_each = var.security_rules
    content {
      name                         = security_rule.value.name
      priority                     = security_rule.value.priority
      direction                    = security_rule.value.direction
      access                       = security_rule.value.access
      protocol                     = security_rule.value.protocol
      source_port_range            = security_rule.value.source_port_ranges == null ? security_rule.value.source_port_range : null
      source_port_ranges           = security_rule.value.source_port_ranges
      destination_port_range       = security_rule.value.destination_port_ranges == null ? security_rule.value.destination_port_range : null
      destination_port_ranges      = security_rule.value.destination_port_ranges
      source_address_prefix        = security_rule.value.source_address_prefixes == null ? security_rule.value.source_address_prefix : null
      source_address_prefixes      = security_rule.value.source_address_prefixes
      destination_address_prefix   = security_rule.value.destination_address_prefixes == null ? security_rule.value.destination_address_prefix : null
      destination_address_prefixes = security_rule.value.destination_address_prefixes
      description                  = security_rule.value.description
    }
  }
}

# Associate NSG with subnet if provided
resource "azurerm_subnet_network_security_group_association" "this" {
  count                     = var.associate_with_subnet ? 1 : 0
  subnet_id                 = var.subnet_id
  network_security_group_id = azurerm_network_security_group.this.id

  timeouts {
    create = "60m"
    read   = "10m"
    delete = "60m"
  }
}
