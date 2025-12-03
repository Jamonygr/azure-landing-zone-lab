# =============================================================================
# VNET PEERING MODULE - MAIN
# Creates bidirectional peering between two VNets
# =============================================================================

locals {
  vnet_2_rg = var.vnet_2_resource_group_name != null ? var.vnet_2_resource_group_name : var.resource_group_name
}

# Peering from VNet 1 to VNet 2
resource "azurerm_virtual_network_peering" "vnet1_to_vnet2" {
  name                         = "${var.name_prefix}-${var.vnet_1_name}-to-${var.vnet_2_name}"
  resource_group_name          = var.resource_group_name
  virtual_network_name         = var.vnet_1_name
  remote_virtual_network_id    = var.vnet_2_id
  allow_virtual_network_access = var.allow_virtual_network_access
  allow_forwarded_traffic      = var.allow_forwarded_traffic
  allow_gateway_transit        = var.allow_gateway_transit_vnet1
  use_remote_gateways          = false
}

# Peering from VNet 2 to VNet 1
resource "azurerm_virtual_network_peering" "vnet2_to_vnet1" {
  name                         = "${var.name_prefix}-${var.vnet_2_name}-to-${var.vnet_1_name}"
  resource_group_name          = local.vnet_2_rg
  virtual_network_name         = var.vnet_2_name
  remote_virtual_network_id    = var.vnet_1_id
  allow_virtual_network_access = var.allow_virtual_network_access
  allow_forwarded_traffic      = var.allow_forwarded_traffic
  allow_gateway_transit        = false
  use_remote_gateways          = var.use_remote_gateways_vnet2

  depends_on = [azurerm_virtual_network_peering.vnet1_to_vnet2]
}
