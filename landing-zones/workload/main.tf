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

  depends_on = [module.web_subnet]  # Serialize subnet creation
}

# Data Tier Subnet
module "data_subnet" {
  source = "../../modules/networking/subnet"

  name                 = "snet-data-${var.workload_name}-${var.environment}-${var.location_short}"
  resource_group_name  = var.resource_group_name
  virtual_network_name = module.workload_vnet.name
  address_prefixes     = [var.data_subnet_prefix]
  service_endpoints    = ["Microsoft.Sql", "Microsoft.Storage"]

  depends_on = [module.app_subnet]  # Serialize subnet creation
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

  depends_on = [module.data_subnet]  # Wait for all subnets before NSG associations

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

  depends_on = [module.web_nsg]  # Serialize NSG associations

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

  depends_on = [module.app_nsg]  # Serialize NSG associations

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
# Note: Web subnet excluded when public LB deployed (to avoid asymmetric routing)
module "workload_route_table" {
  source = "../../modules/networking/route-table"
  count  = var.deploy_route_table ? 1 : 0

  name                = "rt-${var.workload_name}-${var.environment}-${var.location_short}"
  resource_group_name = var.resource_group_name
  location            = var.location
  # Exclude web subnet when public LB is deployed to avoid asymmetric routing
  subnet_ids          = var.deploy_load_balancer && var.lb_type == "public" ? [module.app_subnet.id, module.data_subnet.id] : [module.web_subnet.id, module.app_subnet.id, module.data_subnet.id]
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

# =============================================================================
# LOAD BALANCER AND WEB SERVERS (Optional)
# =============================================================================

# Load Balancer
module "load_balancer" {
  source = "../../modules/networking/load-balancer"
  count  = var.deploy_load_balancer ? 1 : 0

  name                = "lb-${var.workload_name}-${var.environment}-${var.location_short}"
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = "Standard"
  type                = var.lb_type
  subnet_id           = var.lb_type == "internal" ? module.web_subnet.id : null
  private_ip_address  = var.lb_type == "internal" ? var.lb_private_ip : null
  backend_pool_name   = "web-backend-pool"
  tags                = var.tags

  health_probes = {
    http = {
      protocol     = "Http"
      port         = 80
      request_path = "/"
    }
    rdp = {
      protocol = "Tcp"
      port     = 3389
    }
  }

  lb_rules = {
    http = {
      protocol      = "Tcp"
      frontend_port = 80
      backend_port  = 80
      probe_name    = "http"
    }
    https = {
      protocol      = "Tcp"
      frontend_port = 443
      backend_port  = 443
      probe_name    = "http"
    }
  }

  # NAT rules for RDP access to each web server
  nat_rules = {
    for i in range(var.lb_web_server_count) :
    "rdp-web${format("%02d", i + 1)}" => {
      protocol      = "Tcp"
      frontend_port = 3389 + i
      backend_port  = 3389
    }
  }

  enable_outbound_rule = var.lb_type == "public"
}

# Web Servers
module "web_servers" {
  source = "../../modules/compute/web-server"
  count  = var.deploy_load_balancer ? var.lb_web_server_count : 0

  name                = "web${format("%02d", count.index + 1)}-${var.workload_short}"
  resource_group_name = var.resource_group_name
  location            = var.location
  subnet_id           = module.web_subnet.id
  vm_size             = var.lb_web_server_size
  admin_username      = var.admin_username
  admin_password      = var.admin_password

  # Load Balancer association
  associate_with_lb  = true
  lb_backend_pool_id = module.load_balancer[0].backend_pool_id
  lb_nat_rule_ids    = [module.load_balancer[0].nat_rule_ids["rdp-web${format("%02d", count.index + 1)}"]]

  # IIS with custom content showing hostname
  install_iis        = true
  custom_iis_content = "<html><head><title>Azure Load Balancer Lab</title><style>body{font-family:Arial,sans-serif;background-color:#0078D4;color:white;display:flex;justify-content:center;align-items:center;height:100vh;margin:0}.container{text-align:center;background:rgba(0,0,0,0.3);padding:40px;border-radius:10px}h1{font-size:48px}p{font-size:24px}</style></head><body><div class='container'><h1>{hostname}</h1><p>Azure Landing Zone - ${var.workload_name} Workload</p><p>Load Balanced Web Server</p></div></body></html>"

  tags = merge(var.tags, { Role = "WebServer" })

  depends_on = [module.load_balancer, module.web_nsg]
}
