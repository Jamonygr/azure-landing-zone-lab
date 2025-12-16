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

  depends_on = [module.gateway_subnet] # Serialize subnet creation to avoid Azure API conflicts
}

# Management Subnet (for jump boxes, etc.)
module "hub_mgmt_subnet" {
  source = "../../modules/networking/subnet"

  name                 = "snet-hub-mgmt-${var.environment}-${var.location_short}"
  resource_group_name  = var.resource_group_name
  virtual_network_name = module.hub_vnet.name
  address_prefixes     = [var.hub_mgmt_subnet_prefix]
  service_endpoints    = ["Microsoft.KeyVault", "Microsoft.Storage", "Microsoft.Sql"]

  depends_on = [module.firewall_subnet] # Serialize subnet creation to avoid Azure API conflicts
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

  depends_on = [module.hub_mgmt_subnet] # Ensure all subnets created before deploying firewall
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

  depends_on = [module.firewall] # Deploy VPN Gateway after Firewall to avoid concurrent subnet ops
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

  depends_on = [module.vpn_gateway] # Wait for VPN Gateway to complete before modifying subnets

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
      name                       = "DenyAllInbound"
      priority                   = 4096
      direction                  = "Inbound"
      access                     = "Deny"
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

# =============================================================================
# APPLICATION GATEWAY
# =============================================================================

# Application Gateway Subnet
module "appgw_subnet" {
  source = "../../modules/networking/subnet"
  count  = var.deploy_application_gateway ? 1 : 0

  name                 = "snet-hub-appgw-${var.environment}-${var.location_short}"
  resource_group_name  = var.resource_group_name
  virtual_network_name = module.hub_vnet.name
  address_prefixes     = [var.appgw_subnet_prefix]

  depends_on = [module.hub_mgmt_subnet]
}

# NSG for Application Gateway Subnet (required for WAF_v2)
module "appgw_nsg" {
  source = "../../modules/networking/nsg"
  count  = var.deploy_application_gateway ? 1 : 0

  name                  = "nsg-appgw-${var.environment}-${var.location_short}"
  resource_group_name   = var.resource_group_name
  location              = var.location
  subnet_id             = module.appgw_subnet[0].id
  associate_with_subnet = true
  tags                  = var.tags

  depends_on = [module.appgw_subnet]

  security_rules = [
    {
      name                       = "AllowGatewayManager"
      priority                   = 100
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      destination_port_range     = "65200-65535"
      source_address_prefix      = "GatewayManager"
      destination_address_prefix = "*"
    },
    {
      name                       = "AllowAzureLoadBalancer"
      priority                   = 110
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "*"
      destination_port_range     = "*"
      source_address_prefix      = "AzureLoadBalancer"
      destination_address_prefix = "*"
    },
    {
      name                       = "AllowHTTP"
      priority                   = 200
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      destination_port_range     = "80"
      source_address_prefix      = "Internet"
      destination_address_prefix = "*"
    },
    {
      name                       = "AllowHTTPS"
      priority                   = 210
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      destination_port_range     = "443"
      source_address_prefix      = "Internet"
      destination_address_prefix = "*"
    }
  ]
}

# Application Gateway
module "application_gateway" {
  source = "../../modules/application-gateway"
  count  = var.deploy_application_gateway ? 1 : 0

  name_suffix         = "hub-${var.environment}-${var.location_short}"
  resource_group_name = var.resource_group_name
  location            = var.location
  subnet_id           = module.appgw_subnet[0].id
  zones               = [] # Set to [] for lab to reduce costs

  sku_name = "WAF_v2"
  sku_tier = "WAF_v2"
  capacity = 1 # Minimum for lab

  # Backend pool for workload web servers (always created, IPs added via null_resource)
  backend_pools = {
    "workload-web-servers" = {
      ip_addresses = var.lb_backend_ips # Empty initially, populated by null_resource
    }
  }

  backend_http_settings = {
    "http-80" = {
      port                                = 80
      protocol                            = "Http"
      probe_name                          = "web-probe"
      pick_host_name_from_backend_address = true
    }
  }

  # Use default listener (port 80) - route to workload backend pool
  http_listeners = {}
  routing_rules  = {}

  # Override the default routing rule to use our workload pool and settings
  default_backend_pool_name          = "workload-web-servers"
  default_backend_http_settings_name = "http-80"

  health_probes = {
    "web-probe" = {
      protocol                                  = "Http"
      path                                      = "/"
      pick_host_name_from_backend_http_settings = false
      host                                      = "localhost"
      interval                                  = 30
      timeout                                   = 30
      unhealthy_threshold                       = 3
      match = {
        status_code = ["200-399"]
      }
    }
  }

  waf_configuration = {
    enabled          = true
    firewall_mode    = var.appgw_waf_mode
    rule_set_type    = "OWASP"
    rule_set_version = "3.2"
  }

  log_analytics_workspace_id = var.log_analytics_workspace_id
  enable_diagnostics         = var.enable_diagnostics
  tags                       = var.tags

  depends_on = [module.appgw_nsg]
}
