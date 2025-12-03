# =============================================================================
# SHARED SERVICES LANDING ZONE
# Key Vault, Storage, SQL Database, Private Endpoints
# =============================================================================

# Shared Services VNet
module "shared_vnet" {
  source = "../../modules/networking/vnet"

  name                = "vnet-shared-${var.environment}-${var.location_short}"
  resource_group_name = var.resource_group_name
  location            = var.location
  address_space       = var.shared_address_space
  dns_servers         = var.dns_servers
  tags                = var.tags
}

# Application Subnet
module "app_subnet" {
  source = "../../modules/networking/subnet"

  name                 = "snet-app-${var.environment}-${var.location_short}"
  resource_group_name  = var.resource_group_name
  virtual_network_name = module.shared_vnet.name
  address_prefixes     = [var.app_subnet_prefix]
  service_endpoints    = ["Microsoft.KeyVault", "Microsoft.Storage", "Microsoft.Sql"]
}

# Private Endpoint Subnet
module "pe_subnet" {
  source = "../../modules/networking/subnet"

  name                                      = "snet-privateendpoint-${var.environment}-${var.location_short}"
  resource_group_name                       = var.resource_group_name
  virtual_network_name                      = module.shared_vnet.name
  address_prefixes                          = [var.pe_subnet_prefix]
  private_endpoint_network_policies_enabled = false
}

# NSG for Application Subnet
module "app_nsg" {
  source = "../../modules/networking/nsg"

  name                  = "nsg-app-${var.environment}-${var.location_short}"
  resource_group_name   = var.resource_group_name
  location              = var.location
  subnet_id             = module.app_subnet.id
  associate_with_subnet = true
  tags                  = var.tags

  security_rules = [
    {
      name                       = "AllowHTTPSFromVNet"
      priority                   = 100
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      destination_port_range     = "443"
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

# Key Vault
module "keyvault" {
  source = "../../modules/keyvault"
  count  = var.deploy_keyvault ? 1 : 0

  name                = "kv-${var.project}-${var.random_suffix}"
  resource_group_name = var.resource_group_name
  location            = var.location
  tenant_id           = var.tenant_id
  tags                = var.tags

  secrets = {
    "vm-admin-password" = {
      value        = var.admin_password
      content_type = "password"
    }
  }
}

# Storage Account
module "storage" {
  source = "../../modules/storage"
  count  = var.deploy_storage ? 1 : 0

  name                     = var.storage_account_name
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_replication_type = "LRS"
  tags                     = var.tags

  containers = [
    { name = "scripts" },
    { name = "backups" },
    { name = "logs" }
  ]

  file_shares = [
    { name = "shared", quota = 5 }
  ]
}

# Azure SQL Database
module "sql" {
  source = "../../modules/sql"
  count  = var.deploy_sql ? 1 : 0

  server_name          = "sql-${var.project}-${var.random_suffix}"
  database_name        = "sqldb-${var.project}-${var.environment}"
  resource_group_name  = var.resource_group_name
  location             = var.location
  admin_login          = var.sql_admin_login
  admin_password       = var.sql_admin_password
  sku_name             = "Basic"
  allow_azure_services = true
  tags                 = var.tags
}

# Route Table (via Firewall)
module "shared_route_table" {
  source = "../../modules/networking/route-table"
  count  = var.deploy_route_table ? 1 : 0

  name                = "rt-shared-${var.environment}-${var.location_short}"
  resource_group_name = var.resource_group_name
  location            = var.location
  subnet_ids          = [module.app_subnet.id]
  tags                = var.tags
  depends_on          = [module.app_nsg] # Avoid concurrent subnet updates (NSG + route table)

  routes = [
    {
      name                   = "default-via-firewall"
      address_prefix         = "0.0.0.0/0"
      next_hop_type          = "VirtualAppliance"
      next_hop_in_ip_address = var.firewall_private_ip
    }
  ]
}
