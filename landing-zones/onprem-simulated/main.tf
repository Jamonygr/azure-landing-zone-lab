# =============================================================================
# SIMULATED ON-PREMISES LANDING ZONE
# Connected via Site-to-Site IPsec VPN with Local Network Gateways
# This simulates a real on-premises datacenter with VPN connection to Azure
# =============================================================================

# On-Premises VNet
module "onprem_vnet" {
  source = "../../modules/networking/vnet"

  name                = "vnet-onprem-${var.environment}-${var.location_short}"
  resource_group_name = var.resource_group_name
  location            = var.location
  address_space       = var.onprem_address_space
  tags                = var.tags
}

# Gateway Subnet (required for VPN)
module "onprem_gateway_subnet" {
  source = "../../modules/networking/subnet"

  name                 = "GatewaySubnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = module.onprem_vnet.name
  address_prefixes     = [var.gateway_subnet_prefix]
}

# Servers Subnet
module "onprem_servers_subnet" {
  source = "../../modules/networking/subnet"

  name                 = "snet-servers-onprem-${var.environment}-${var.location_short}"
  resource_group_name  = var.resource_group_name
  virtual_network_name = module.onprem_vnet.name
  address_prefixes     = [var.servers_subnet_prefix]

  depends_on = [module.onprem_gateway_subnet]  # Serialize subnet creation
}

# NSG for Servers
module "onprem_nsg" {
  source = "../../modules/networking/nsg"

  name                  = "nsg-onprem-${var.environment}-${var.location_short}"
  resource_group_name   = var.resource_group_name
  location              = var.location
  subnet_id             = module.onprem_servers_subnet.id
  associate_with_subnet = true
  tags                  = var.tags

  depends_on = [module.onprem_servers_subnet]  # Wait for subnets before NSG association

  security_rules = [
    {
      name                       = "AllowRDPFromAzure"
      priority                   = 100
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      destination_port_range     = "3389"
      source_address_prefix      = "10.0.0.0/8"
      destination_address_prefix = "*"
    },
    {
      name                       = "AllowSMB"
      priority                   = 110
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      destination_port_range     = "445"
      source_address_prefix      = "10.0.0.0/8"
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

# On-Premises VPN Gateway
module "onprem_vpn_gateway" {
  source = "../../modules/networking/vpn-gateway"
  count  = var.deploy_vpn_gateway ? 1 : 0

  name                = "vpng-onprem-${var.environment}-${var.location_short}"
  resource_group_name = var.resource_group_name
  location            = var.location
  subnet_id           = module.onprem_gateway_subnet.id
  sku                 = var.vpn_gateway_sku
  enable_bgp          = var.enable_bgp
  bgp_asn             = var.onprem_bgp_asn
  tags                = var.tags

  depends_on = [module.onprem_nsg]  # Deploy VPN Gateway after NSG to avoid concurrent subnet ops
}

# =============================================================================
# LOCAL NETWORK GATEWAY - Represents the Hub (Azure) from On-Prem perspective
# =============================================================================

# This tells the on-prem VPN gateway where Azure Hub is and what networks it has
module "lng_to_hub" {
  source = "../../modules/networking/local-network-gateway"
  count  = var.deploy_vpn_connection ? 1 : 0

  name                = "lng-to-hub-${var.environment}"
  resource_group_name = var.resource_group_name
  location            = var.location
  gateway_address     = var.hub_vpn_gateway_public_ip
  address_space       = var.enable_bgp ? [] : var.hub_address_spaces # Empty when using BGP (routes learned dynamically)
  enable_bgp          = var.enable_bgp
  bgp_asn             = var.hub_bgp_asn
  bgp_peering_address = var.hub_bgp_peering_address
  tags                = var.tags
}

# =============================================================================
# SITE-TO-SITE VPN CONNECTION (IPsec tunnel from On-Prem to Hub)
# =============================================================================

module "vpn_connection_onprem_to_hub" {
  source = "../../modules/networking/vpn-connection"
  count  = var.deploy_vpn_connection && var.deploy_vpn_gateway ? 1 : 0

  name                       = "con-onprem-to-hub-${var.environment}"
  resource_group_name        = var.resource_group_name
  location                   = var.location
  type                       = "IPsec"
  virtual_network_gateway_id = module.onprem_vpn_gateway[0].id
  local_network_gateway_id   = module.lng_to_hub[0].id
  shared_key                 = var.vpn_shared_key
  enable_bgp                 = var.enable_bgp
  tags                       = var.tags
}

# =============================================================================
# ON-PREM MANAGEMENT VM (Jumpbox with Public IP and RDP access)
# This is your entry point to the simulated on-premises environment
# =============================================================================

# Public IP for On-Prem Management VM
resource "azurerm_public_ip" "onprem_mgmt" {
  name                = "pip-vmonpremmgmt01"
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = merge(var.tags, { Role = "OnPremManagement" })
}

# NSG for On-Prem Management VM - Restrict RDP to allowed IPs only
resource "azurerm_network_security_group" "onprem_mgmt" {
  name                = "nsg-onprem-mgmt-${var.environment}-${var.location_short}"
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags

  # Only create RDP rule if allowed IPs are specified
  dynamic "security_rule" {
    for_each = length(var.allowed_rdp_source_ips) > 0 ? [1] : []
    content {
      name                       = "AllowRDPFromTrusted"
      priority                   = 100
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "3389"
      source_address_prefixes    = var.allowed_rdp_source_ips
      destination_address_prefix = "*"
    }
  }

  # Allow RDP from Azure VPN/Hub ranges
  security_rule {
    name                       = "AllowRDPFromAzure"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "10.0.0.0/8"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowICMPFromAzure"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Icmp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "10.0.0.0/8"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "DenyAllInbound"
    priority                   = 4096
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# NIC for On-Prem Management VM
resource "azurerm_network_interface" "onprem_mgmt" {
  name                = "nic-vmonpremmgmt01"
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags

  timeouts {
    create = "60m"
  }

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = module.onprem_servers_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.onprem_mgmt.id
  }
}

# Associate NSG with NIC
resource "azurerm_network_interface_security_group_association" "onprem_mgmt" {
  network_interface_id      = azurerm_network_interface.onprem_mgmt.id
  network_security_group_id = azurerm_network_security_group.onprem_mgmt.id
}

# On-Prem Management VM (small size with RDP access)
resource "azurerm_windows_virtual_machine" "onprem_mgmt" {
  name                  = "vmonpremmgmt01"
  resource_group_name   = var.resource_group_name
  location              = var.location
  size                  = "Standard_B2s" # 4GB RAM for RDP sessions
  admin_username        = var.admin_username
  admin_password        = var.admin_password
  network_interface_ids = [azurerm_network_interface.onprem_mgmt.id]
  tags                  = merge(var.tags, { Role = "Management", Location = "OnPremises" })

  os_disk {
    name                 = "osdisk-vmonpremmgmt01"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-Datacenter-smalldisk"
    version   = "latest"
  }
}

# Auto-shutdown for On-Prem Management VM
resource "azurerm_dev_test_global_vm_shutdown_schedule" "onprem_mgmt" {
  count              = var.enable_auto_shutdown ? 1 : 0
  virtual_machine_id = azurerm_windows_virtual_machine.onprem_mgmt.id
  location           = var.location
  enabled            = true

  daily_recurrence_time = "1900"
  timezone              = "UTC"

  notification_settings {
    enabled = false
  }
}

# =============================================================================
# ROUTE TABLE FOR ON-PREM (routes to Azure via VPN Gateway)
# =============================================================================

resource "azurerm_route_table" "onprem" {
  name                = "rt-onprem-${var.environment}-${var.location_short}"
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags
}

# Route to Azure networks via VPN Gateway
resource "azurerm_route" "to_azure" {
  name                = "route-to-azure"
  resource_group_name = var.resource_group_name
  route_table_name    = azurerm_route_table.onprem.name
  address_prefix      = "10.0.0.0/8"
  next_hop_type       = "VirtualNetworkGateway"
}

# Associate route table with servers subnet
resource "azurerm_subnet_route_table_association" "onprem_servers" {
  subnet_id      = module.onprem_servers_subnet.id
  route_table_id = azurerm_route_table.onprem.id

  timeouts {
    create = "30m"
  }

  depends_on = [module.onprem_nsg] # Avoid concurrent subnet updates (NSG + route table)
}
