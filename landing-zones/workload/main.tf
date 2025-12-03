# =============================================================================
# WORKLOAD LANDING ZONE (REUSABLE)
# Web, App, and Database tier VMs
# =============================================================================

# Workload VNet
module "workload_vnet" {
  source = "../../modules/networking/vnet"

  name                = "vnet-${var.workload_name}-${var.environment}-${var.location_short}"
  resource_group_name = var.resource_group_name
  location            = var.location
  address_space       = var.workload_address_space
  dns_servers         = var.dns_servers
  tags                = var.tags
}

# Web Tier Subnet
module "web_subnet" {
  source = "../../modules/networking/subnet"

  name                 = "snet-web-${var.workload_name}-${var.environment}-${var.location_short}"
  resource_group_name  = var.resource_group_name
  virtual_network_name = module.workload_vnet.name
  address_prefixes     = [var.web_subnet_prefix]
  service_endpoints    = ["Microsoft.KeyVault", "Microsoft.Storage"]
}

# App Tier Subnet
module "app_subnet" {
  source = "../../modules/networking/subnet"

  name                 = "snet-app-${var.workload_name}-${var.environment}-${var.location_short}"
  resource_group_name  = var.resource_group_name
  virtual_network_name = module.workload_vnet.name
  address_prefixes     = [var.app_subnet_prefix]
  service_endpoints    = ["Microsoft.KeyVault", "Microsoft.Storage", "Microsoft.Sql"]
}

# Data Tier Subnet
module "data_subnet" {
  source = "../../modules/networking/subnet"

  name                 = "snet-data-${var.workload_name}-${var.environment}-${var.location_short}"
  resource_group_name  = var.resource_group_name
  virtual_network_name = module.workload_vnet.name
  address_prefixes     = [var.data_subnet_prefix]
  service_endpoints    = ["Microsoft.Sql", "Microsoft.Storage"]
}

# Web Tier NSG
module "web_nsg" {
  source = "../../modules/networking/nsg"

  name                  = "nsg-web-${var.workload_name}-${var.environment}-${var.location_short}"
  resource_group_name   = var.resource_group_name
  location              = var.location
  subnet_id             = module.web_subnet.id
  associate_with_subnet = true
  tags                  = var.tags

  security_rules = [
    {
      name                       = "AllowHTTP"
      priority                   = 100
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      destination_port_range     = "80"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    },
    {
      name                       = "AllowHTTPS"
      priority                   = 110
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      destination_port_range     = "443"
      source_address_prefix      = "*"
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

# App Tier NSG
module "app_nsg" {
  source = "../../modules/networking/nsg"

  name                  = "nsg-app-${var.workload_name}-${var.environment}-${var.location_short}"
  resource_group_name   = var.resource_group_name
  location              = var.location
  subnet_id             = module.app_subnet.id
  associate_with_subnet = true
  tags                  = var.tags

  security_rules = [
    {
      name                       = "AllowFromWebTier"
      priority                   = 100
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      destination_port_range     = "8080"
      source_address_prefix      = var.web_subnet_prefix
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

# Data Tier NSG
module "data_nsg" {
  source = "../../modules/networking/nsg"

  name                  = "nsg-data-${var.workload_name}-${var.environment}-${var.location_short}"
  resource_group_name   = var.resource_group_name
  location              = var.location
  subnet_id             = module.data_subnet.id
  associate_with_subnet = true
  tags                  = var.tags

  security_rules = [
    {
      name                       = "AllowSQLFromAppTier"
      priority                   = 100
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      destination_port_range     = "1433"
      source_address_prefix      = var.app_subnet_prefix
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

# Route Table (via Firewall)
module "workload_route_table" {
  source = "../../modules/networking/route-table"
  count  = var.deploy_route_table ? 1 : 0

  name                = "rt-${var.workload_name}-${var.environment}-${var.location_short}"
  resource_group_name = var.resource_group_name
  location            = var.location
  subnet_ids          = [module.web_subnet.id, module.app_subnet.id, module.data_subnet.id]
  tags                = var.tags
  depends_on          = [module.web_nsg, module.app_nsg, module.data_nsg] # Serialize subnet updates

  routes = [
    {
      name                   = "default-via-firewall"
      address_prefix         = "0.0.0.0/0"
      next_hop_type          = "VirtualAppliance"
      next_hop_in_ip_address = var.firewall_private_ip
    }
  ]
}

# =============================================================================
# AKS CLUSTER (Optional)
# =============================================================================

# AKS Subnet
module "aks_subnet" {
  source = "../../modules/networking/subnet"
  count  = var.deploy_aks ? 1 : 0

  name                 = "snet-aks-${var.workload_name}-${var.environment}-${var.location_short}"
  resource_group_name  = var.resource_group_name
  virtual_network_name = module.workload_vnet.name
  address_prefixes     = [var.aks_subnet_prefix]
  service_endpoints    = ["Microsoft.ContainerRegistry", "Microsoft.Storage", "Microsoft.KeyVault"]
}

# AKS Cluster
module "aks" {
  source = "../../modules/aks"
  count  = var.deploy_aks ? 1 : 0

  name                = "aks-${var.workload_name}-${var.environment}-${var.location_short}"
  resource_group_name = var.resource_group_name
  location            = var.location
  dns_prefix          = "aks-${var.workload_name}-${var.environment}"

  # Smallest possible cluster
  subnet_id       = module.aks_subnet[0].id
  node_count      = var.aks_node_count
  vm_size         = var.aks_vm_size
  os_disk_size_gb = 30
  max_pods        = 30

  # Free tier for lab
  sku_tier                = "Free"
  private_cluster_enabled = false # Public API for lab convenience

  # CAF best practices
  network_plugin            = "azure"
  network_policy            = "azure"
  workload_identity_enabled = true
  oidc_issuer_enabled       = true
  azure_policy_enabled      = false # Disable for lab to reduce overhead
  local_account_disabled    = false # Keep enabled for lab

  # Monitoring
  log_analytics_workspace_id = var.log_analytics_workspace_id

  tags = var.tags
}
