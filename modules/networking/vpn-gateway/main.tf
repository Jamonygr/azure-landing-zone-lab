# =============================================================================
# VPN GATEWAY MODULE - MAIN
# =============================================================================

locals {
  pip_name = var.pip_name != null ? var.pip_name : "pip-${var.name}"
}

# Public IP for VPN Gateway
resource "azurerm_public_ip" "this" {
  name                = local.pip_name
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

# VPN Gateway
resource "azurerm_virtual_network_gateway" "this" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags

  type     = "Vpn"
  vpn_type = var.type

  active_active = var.active_active
  enable_bgp    = var.enable_bgp
  sku           = var.sku
  generation    = var.vpn_type

  ip_configuration {
    name                          = "vnetGatewayConfig"
    public_ip_address_id          = azurerm_public_ip.this.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = var.subnet_id
  }

  dynamic "bgp_settings" {
    for_each = var.enable_bgp ? [1] : []
    content {
      asn = var.bgp_asn
    }
  }

  timeouts {
    create = "60m"
    update = "60m"
    delete = "60m"
    read   = "5m"
  }

  lifecycle {
    ignore_changes = [
      timeouts
    ]
  }
}
