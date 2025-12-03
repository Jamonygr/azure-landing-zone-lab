# =============================================================================
# HUB LANDING ZONE
# Central connectivity hub with Firewall and VPN Gateway
# =============================================================================

# Hub VNet
module "hub_vnet" {
  source = "../../modules/networking/vnet"

  name                = "vnet-hub-${var.environment}-${var.location_short}"
  resource_group_name = var.resource_group_name
  location            = var.location
  address_space       = var.hub_address_space
  dns_servers         = var.dns_servers
  tags                = var.tags
}

# Gateway Subnet (required name: GatewaySubnet)
module "gateway_subnet" {
  source = "../../modules/networking/subnet"

  name                 = "GatewaySubnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = module.hub_vnet.name
  address_prefixes     = [var.gateway_subnet_prefix]
}

# Azure Firewall Subnet (required name: AzureFirewallSubnet)
module "firewall_subnet" {
  source = "../../modules/networking/subnet"

  name                 = "AzureFirewallSubnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = module.hub_vnet.name
  address_prefixes     = [var.firewall_subnet_prefix]
}

# Management Subnet (for jump boxes, etc.)
module "hub_mgmt_subnet" {
  source = "../../modules/networking/subnet"

  name                 = "snet-hub-mgmt-${var.environment}-${var.location_short}"
  resource_group_name  = var.resource_group_name
  virtual_network_name = module.hub_vnet.name
  address_prefixes     = [var.hub_mgmt_subnet_prefix]
  service_endpoints    = ["Microsoft.KeyVault", "Microsoft.Storage", "Microsoft.Sql"]
}

# Azure Firewall
module "firewall" {
  source = "../../modules/firewall"
  count  = var.deploy_firewall ? 1 : 0

  name                = "afw-hub-${var.environment}-${var.location_short}"
  resource_group_name = var.resource_group_name
  location            = var.location
  subnet_id           = module.firewall_subnet.id
  sku_tier            = var.firewall_sku_tier
  dns_proxy_enabled   = true
  tags                = var.tags
}

# VPN Gateway
module "vpn_gateway" {
  source = "../../modules/networking/vpn-gateway"
  count  = var.deploy_vpn_gateway ? 1 : 0

  name                = "vpng-hub-${var.environment}-${var.location_short}"
  resource_group_name = var.resource_group_name
  location            = var.location
  subnet_id           = module.gateway_subnet.id
  sku                 = var.vpn_gateway_sku
  enable_bgp          = var.enable_bgp
  bgp_asn             = var.hub_bgp_asn
  tags                = var.tags
}

# NSG for Management Subnet
module "hub_mgmt_nsg" {
  source = "../../modules/networking/nsg"

  name                  = "nsg-hub-mgmt-${var.environment}-${var.location_short}"
  resource_group_name   = var.resource_group_name
  location              = var.location
  subnet_id             = module.hub_mgmt_subnet.id
  associate_with_subnet = true
  tags                  = var.tags

  security_rules = [
    {
      name                       = "AllowRDPFromVPN"
      priority                   = 100
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      destination_port_range     = "3389"
      source_address_prefix      = var.vpn_client_address_pool
      destination_address_prefix = "*"
    },
    {
      name                       = "AllowSSHFromVPN"
      priority                   = 110
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      destination_port_range     = "22"
      source_address_prefix      = var.vpn_client_address_pool
      destination_address_prefix = "*"
    },
    {
      name                       = "AllowAllInbound"
      priority                   = 4096
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "*"
      destination_port_range     = "*"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    }
  ]
}

# Route Table for Hub Management Subnet
module "hub_route_table" {
  source = "../../modules/networking/route-table"
  count  = var.deploy_firewall ? 1 : 0

  name                = "rt-hub-mgmt-${var.environment}-${var.location_short}"
  resource_group_name = var.resource_group_name
  location            = var.location
  subnet_ids          = [module.hub_mgmt_subnet.id]
  tags                = var.tags
  depends_on          = [module.hub_mgmt_nsg] # Avoid concurrent subnet updates (NSG + route table)

  routes = [
    {
      name                   = "default-via-firewall"
      address_prefix         = "0.0.0.0/0"
      next_hop_type          = "VirtualAppliance"
      next_hop_in_ip_address = module.firewall[0].private_ip_address
    }
  ]
}

# Route Table for Gateway Subnet (routes spoke traffic through firewall)
module "gateway_route_table" {
  source = "../../modules/networking/route-table"
  count  = var.deploy_firewall && var.deploy_vpn_gateway ? 1 : 0

  name                          = "rt-gateway-${var.environment}-${var.location_short}"
  resource_group_name           = var.resource_group_name
  location                      = var.location
  subnet_ids                    = [module.gateway_subnet.id]
  disable_bgp_route_propagation = false
  tags                          = var.tags

  routes = [
    {
      name                   = "identity-spoke-via-firewall"
      address_prefix         = var.identity_address_space
      next_hop_type          = "VirtualAppliance"
      next_hop_in_ip_address = module.firewall[0].private_ip_address
    },
    {
      name                   = "management-spoke-via-firewall"
      address_prefix         = var.management_address_space
      next_hop_type          = "VirtualAppliance"
      next_hop_in_ip_address = module.firewall[0].private_ip_address
    },
    {
      name                   = "shared-spoke-via-firewall"
      address_prefix         = var.shared_services_address_space
      next_hop_type          = "VirtualAppliance"
      next_hop_in_ip_address = module.firewall[0].private_ip_address
    },
    {
      name                   = "workload-spoke-via-firewall"
      address_prefix         = var.workload_address_space
      next_hop_type          = "VirtualAppliance"
      next_hop_in_ip_address = module.firewall[0].private_ip_address
    }
  ]
}
