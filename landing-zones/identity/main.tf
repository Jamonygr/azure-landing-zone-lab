# =============================================================================
# IDENTITY LANDING ZONE
# Domain Controllers and Identity Services
# =============================================================================

# Identity VNet
module "identity_vnet" {
  source = "../../modules/networking/vnet"

  name                = "vnet-identity-${var.environment}-${var.location_short}"
  resource_group_name = var.resource_group_name
  location            = var.location
  address_space       = var.identity_address_space
  dns_servers         = var.dns_servers
  tags                = var.tags
}

# Domain Controllers Subnet
module "dc_subnet" {
  source = "../../modules/networking/subnet"

  name                 = "snet-dc-${var.environment}-${var.location_short}"
  resource_group_name  = var.resource_group_name
  virtual_network_name = module.identity_vnet.name
  address_prefixes     = [var.dc_subnet_prefix]
  service_endpoints    = ["Microsoft.KeyVault", "Microsoft.Storage"]
}

# NSG for Domain Controllers
module "dc_nsg" {
  source = "../../modules/networking/nsg"

  name                  = "nsg-dc-${var.environment}-${var.location_short}"
  resource_group_name   = var.resource_group_name
  location              = var.location
  subnet_id             = module.dc_subnet.id
  associate_with_subnet = true
  tags                  = var.tags

  security_rules = [
    # Allow AD DS Traffic
    {
      name                       = "AllowADDS-TCP"
      priority                   = 100
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      destination_port_ranges    = ["53", "88", "135", "389", "445", "464", "636", "3268", "3269", "49152-65535"]
      source_address_prefix      = "VirtualNetwork"
      destination_address_prefix = "*"
    },
    {
      name                       = "AllowADDS-UDP"
      priority                   = 110
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Udp"
      destination_port_ranges    = ["53", "88", "123", "389", "464"]
      source_address_prefix      = "VirtualNetwork"
      destination_address_prefix = "*"
    },
    {
      name                       = "AllowRDPFromHub"
      priority                   = 200
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      destination_port_range     = "3389"
      source_address_prefix      = var.hub_address_prefix
      destination_address_prefix = "*"
    },
    {
      name                       = "AllowRDPFromOnPrem"
      priority                   = 210
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      destination_port_range     = "3389"
      source_address_prefix      = var.onprem_address_prefix
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

# Primary Domain Controller VM
module "dc01" {
  source = "../../modules/compute/windows-vm"

  name                 = "vmdc01"
  resource_group_name  = var.resource_group_name
  location             = var.location
  subnet_id            = module.dc_subnet.id
  size                 = var.vm_size
  admin_username       = var.admin_username
  admin_password       = var.admin_password
  private_ip_address   = var.dc01_ip_address
  enable_auto_shutdown = var.enable_auto_shutdown
  tags                 = merge(var.tags, { Role = "DomainController" })

  data_disks = [
    {
      name         = "ntds"
      disk_size_gb = 20
      lun          = 0
    }
  ]
}

# Secondary Domain Controller VM (Optional)
module "dc02" {
  source = "../../modules/compute/windows-vm"
  count  = var.deploy_secondary_dc ? 1 : 0

  name                 = "vmdc02"
  resource_group_name  = var.resource_group_name
  location             = var.location
  subnet_id            = module.dc_subnet.id
  size                 = var.vm_size
  admin_username       = var.admin_username
  admin_password       = var.admin_password
  private_ip_address   = var.dc02_ip_address
  enable_auto_shutdown = var.enable_auto_shutdown
  tags                 = merge(var.tags, { Role = "DomainController" })

  data_disks = [
    {
      name         = "ntds"
      disk_size_gb = 20
      lun          = 0
    }
  ]
}

# Route Table (via Firewall)
module "identity_route_table" {
  source = "../../modules/networking/route-table"
  count  = var.deploy_route_table ? 1 : 0

  name                = "rt-identity-${var.environment}-${var.location_short}"
  resource_group_name = var.resource_group_name
  location            = var.location
  subnet_ids          = [module.dc_subnet.id]
  tags                = var.tags
  depends_on          = [module.dc_nsg] # Serialize subnet changes (NSG association before route table)

  routes = [
    {
      name                   = "default-via-firewall"
      address_prefix         = "0.0.0.0/0"
      next_hop_type          = "VirtualAppliance"
      next_hop_in_ip_address = var.firewall_private_ip
    },
    {
      name                   = "onprem-via-firewall"
      address_prefix         = var.onprem_address_prefix
      next_hop_type          = "VirtualAppliance"
      next_hop_in_ip_address = var.firewall_private_ip
    }
  ]
}
