# =============================================================================
# AZURE LANDING ZONE LAB - ROOT CONFIGURATION
# =============================================================================

terraform {
  required_version = ">= 1.9.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
    azapi = {
      source  = "Azure/azapi"
      version = "~> 2.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6.0"
    }
  }

  # Backend configuration - uncomment and configure for remote state
  # backend "azurerm" {
  #   resource_group_name  = "rg-terraform-state"
  #   storage_account_name = "stterraformstate"
  #   container_name       = "tfstate"
  #   key                  = "landingzone-lab.tfstate"
  # }
}

provider "azurerm" {
  subscription_id = var.subscription_id

  features {
    key_vault {
      purge_soft_delete_on_destroy    = true
      recover_soft_deleted_key_vaults = true
    }
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
    virtual_machine {
      delete_os_disk_on_deletion     = true
      skip_shutdown_and_force_delete = false
    }
  }
}

# =============================================================================
# DATA SOURCES
# =============================================================================

data "azurerm_client_config" "current" {}

# Random suffix for globally unique names
resource "random_string" "suffix" {
  length  = 4
  special = false
  upper   = false
}

# =============================================================================
# RESOURCE GROUPS
# =============================================================================

resource "azurerm_resource_group" "hub" {
  name     = "rg-hub-${local.environment}-${local.location_short}"
  location = var.location
  tags     = local.common_tags
}

resource "azurerm_resource_group" "identity" {
  name     = "rg-identity-${local.environment}-${local.location_short}"
  location = var.location
  tags     = local.common_tags
}

resource "azurerm_resource_group" "management" {
  name     = "rg-management-${local.environment}-${local.location_short}"
  location = var.location
  tags     = local.common_tags
}

resource "azurerm_resource_group" "shared" {
  name     = "rg-shared-${local.environment}-${local.location_short}"
  location = var.location
  tags     = local.common_tags
}

resource "azurerm_resource_group" "workload_prod" {
  count    = var.deploy_workload_prod ? 1 : 0
  name     = "rg-workload-prod-${local.environment}-${local.location_short}"
  location = var.location
  tags     = local.common_tags
}

resource "azurerm_resource_group" "workload_dev" {
  count    = var.deploy_workload_dev ? 1 : 0
  name     = "rg-workload-dev-${local.environment}-${local.location_short}"
  location = var.location
  tags     = local.common_tags
}

# On-Prem Simulation Resource Group
resource "azurerm_resource_group" "onprem" {
  count    = var.deploy_onprem_simulation ? 1 : 0
  name     = "rg-onprem-${local.environment}-${local.location_short}"
  location = var.location
  tags     = local.common_tags
}

# =============================================================================
# HUB LANDING ZONE
# =============================================================================

module "hub" {
  source = "./landing-zones/hub"

  environment         = local.environment
  location            = var.location
  location_short      = local.location_short
  resource_group_name = azurerm_resource_group.hub.name
  tags                = local.common_tags

  hub_address_space      = var.hub_address_space
  gateway_subnet_prefix  = var.hub_gateway_subnet_prefix
  firewall_subnet_prefix = var.hub_firewall_subnet_prefix
  hub_mgmt_subnet_prefix = var.hub_mgmt_subnet_prefix

  deploy_firewall         = var.deploy_firewall
  firewall_sku_tier       = var.firewall_sku_tier
  deploy_vpn_gateway      = var.deploy_vpn_gateway
  vpn_gateway_sku         = var.vpn_gateway_sku
  enable_bgp              = var.enable_bgp
  hub_bgp_asn             = var.hub_bgp_asn
  vpn_client_address_pool = var.vpn_client_address_pool

  # Spoke address spaces for gateway routing
  identity_address_space        = var.identity_address_space[0]
  management_address_space      = var.management_address_space[0]
  shared_services_address_space = var.shared_address_space[0]
  workload_address_space        = var.workload_prod_address_space[0]

  # Application Gateway
  deploy_application_gateway = var.deploy_application_gateway
  appgw_subnet_prefix        = var.hub_appgw_subnet_prefix
  appgw_waf_mode             = var.appgw_waf_mode
  # Note: log_analytics_workspace_id and lb_backend_ips are passed as null/empty
  # to avoid circular dependencies. Diagnostics configured via monitoring_diagnostics module.
  # Backend pool IPs must be configured after initial deployment if needed.
  log_analytics_workspace_id = null
  enable_diagnostics         = false
  lb_backend_ips             = []
}

# =============================================================================
# IDENTITY LANDING ZONE
# =============================================================================

module "identity" {
  source = "./landing-zones/identity"

  environment         = local.environment
  location            = var.location
  location_short      = local.location_short
  resource_group_name = azurerm_resource_group.identity.name
  tags                = local.common_tags

  identity_address_space = var.identity_address_space
  dc_subnet_prefix       = var.identity_dc_subnet_prefix
  dns_servers            = [var.dc01_ip_address]
  hub_address_prefix     = var.hub_address_space[0]
  onprem_address_prefix  = var.onprem_address_space[0]

  vm_size              = var.vm_size
  admin_username       = var.admin_username
  admin_password       = var.admin_password
  dc01_ip_address      = var.dc01_ip_address
  dc02_ip_address      = var.dc02_ip_address
  deploy_secondary_dc  = var.deploy_secondary_dc
  enable_auto_shutdown = var.enable_auto_shutdown
  firewall_private_ip  = var.deploy_firewall ? module.hub.firewall_private_ip : null
  deploy_route_table   = var.deploy_firewall
}

# =============================================================================
# MANAGEMENT LANDING ZONE
# =============================================================================

module "management" {
  source = "./landing-zones/management"

  environment         = local.environment
  location            = var.location
  location_short      = local.location_short
  resource_group_name = azurerm_resource_group.management.name
  tags                = local.common_tags

  mgmt_address_space         = var.management_address_space
  jumpbox_subnet_prefix      = var.management_jumpbox_subnet_prefix
  dns_servers                = module.identity.dns_servers
  hub_address_prefix         = var.hub_address_space[0]
  vpn_client_address_pool    = var.vpn_client_address_pool
  onprem_address_prefix      = var.onprem_address_space[0]
  allowed_jumpbox_source_ips = var.allowed_jumpbox_source_ips

  vm_size                  = var.vm_size
  admin_username           = var.admin_username
  admin_password           = var.admin_password
  enable_jumpbox_public_ip = var.enable_jumpbox_public_ip
  enable_auto_shutdown     = var.enable_auto_shutdown
  deploy_log_analytics     = var.deploy_log_analytics
  log_retention_days       = var.log_retention_days
  log_daily_quota_gb       = var.log_daily_quota_gb
  firewall_private_ip      = var.deploy_firewall ? module.hub.firewall_private_ip : null
  deploy_route_table       = var.deploy_firewall

  # Monitoring - disabled initially, will be enabled after all resources are created
  deploy_monitoring = false
  alert_email_receivers = [
    {
      name          = "admin"
      email_address = "admin@example.com"
    }
  ]
  monitored_vm_ids         = []
  monitored_firewall_id    = ""
  monitored_aks_cluster_id = ""
}

# =============================================================================
# SHARED SERVICES LANDING ZONE
# =============================================================================

module "shared_services" {
  source = "./landing-zones/shared-services"

  environment         = local.environment
  location            = var.location
  location_short      = local.location_short
  project             = var.project
  resource_group_name = azurerm_resource_group.shared.name
  tags                = local.common_tags
  tenant_id           = data.azurerm_client_config.current.tenant_id

  shared_address_space = var.shared_address_space
  app_subnet_prefix    = var.shared_app_subnet_prefix
  pe_subnet_prefix     = var.shared_pe_subnet_prefix
  dns_servers          = module.identity.dns_servers
  hub_address_prefix   = var.hub_address_space[0]

  admin_password       = var.admin_password
  deploy_keyvault      = var.deploy_keyvault
  deploy_storage       = var.deploy_storage
  storage_account_name = "st${var.project}${local.environment}${random_string.suffix.result}"
  deploy_sql           = var.deploy_sql
  sql_admin_login      = var.sql_admin_login
  sql_admin_password   = var.sql_admin_password
  firewall_private_ip  = var.deploy_firewall ? module.hub.firewall_private_ip : null
  deploy_route_table   = var.deploy_firewall
  random_suffix        = random_string.suffix.result

  # Private Endpoints
  deploy_private_endpoints     = var.deploy_private_endpoints
  private_dns_zone_blob_id     = var.deploy_private_dns_zones ? module.private_dns_blob[0].id : null
  private_dns_zone_keyvault_id = var.deploy_private_dns_zones ? module.private_dns_keyvault[0].id : null
  private_dns_zone_sql_id      = var.deploy_private_dns_zones ? module.private_dns_sql[0].id : null
}

# =============================================================================
# WORKLOAD PROD LANDING ZONE
# =============================================================================

module "workload_prod" {
  source = "./landing-zones/workload"
  count  = var.deploy_workload_prod ? 1 : 0

  workload_name       = "prod"
  workload_short      = "prd"
  environment         = local.environment
  location            = var.location
  location_short      = local.location_short
  resource_group_name = azurerm_resource_group.workload_prod[0].name
  tags                = merge(local.common_tags, { Workload = "Production" })

  workload_address_space = var.workload_prod_address_space
  web_subnet_prefix      = var.workload_prod_web_subnet_prefix
  app_subnet_prefix      = var.workload_prod_app_subnet_prefix
  data_subnet_prefix     = var.workload_prod_data_subnet_prefix
  dns_servers            = module.identity.dns_servers
  hub_address_prefix     = var.hub_address_space[0]

  firewall_private_ip = var.deploy_firewall ? module.hub.firewall_private_ip : null
  deploy_route_table  = var.deploy_firewall

  # AKS Cluster
  deploy_aks                 = var.deploy_aks
  aks_subnet_prefix          = var.aks_subnet_prefix
  aks_node_count             = var.aks_node_count
  aks_vm_size                = var.aks_vm_size
  log_analytics_workspace_id = var.deploy_log_analytics ? module.management.log_analytics_workspace_id : null
  enable_diagnostics         = var.deploy_log_analytics

  # Load Balancer with IIS Web Servers
  deploy_load_balancer = var.deploy_load_balancer
  lb_type              = var.lb_type
  lb_private_ip        = var.lb_private_ip
  lb_web_server_count  = var.lb_web_server_count
  lb_web_server_size   = var.lb_web_server_size
  admin_username       = var.admin_username
  admin_password       = var.admin_password

  # PaaS Services - Tier 1 (Free)
  deploy_functions      = var.deploy_functions
  deploy_static_web_app = var.deploy_static_web_app
  deploy_logic_apps     = var.deploy_logic_apps
  deploy_event_grid     = var.deploy_event_grid

  # PaaS Services - Tier 2 (Low Cost)
  deploy_service_bus = var.deploy_service_bus
  deploy_app_service = var.deploy_app_service

  # PaaS Services - Tier 3 (Data)
  deploy_cosmos_db = var.deploy_cosmos_db
  cosmos_location  = var.cosmos_location != "" ? var.cosmos_location : null

  # Alternative location for services with quota issues
  paas_alternative_location = var.paas_alternative_location
}

# =============================================================================
# WORKLOAD DEV LANDING ZONE
# =============================================================================

module "workload_dev" {
  source = "./landing-zones/workload"
  count  = var.deploy_workload_dev ? 1 : 0

  workload_name       = "dev"
  workload_short      = "dev"
  environment         = local.environment
  location            = var.location
  location_short      = local.location_short
  resource_group_name = azurerm_resource_group.workload_dev[0].name
  tags                = merge(local.common_tags, { Workload = "Development" })

  workload_address_space = var.workload_dev_address_space
  web_subnet_prefix      = var.workload_dev_web_subnet_prefix
  app_subnet_prefix      = var.workload_dev_app_subnet_prefix
  data_subnet_prefix     = var.workload_dev_data_subnet_prefix
  dns_servers            = module.identity.dns_servers
  hub_address_prefix     = var.hub_address_space[0]

  firewall_private_ip = var.deploy_firewall ? module.hub.firewall_private_ip : null
  deploy_route_table  = var.deploy_firewall

  enable_diagnostics = var.deploy_log_analytics

  # Optional Cosmos location override
  cosmos_location = var.cosmos_location != "" ? var.cosmos_location : null
}

# =============================================================================
# SIMULATED ON-PREMISES ENVIRONMENT
# Site-to-Site IPsec VPN with Local Network Gateways (realistic simulation)
# =============================================================================

module "onprem" {
  source = "./landing-zones/onprem-simulated"
  count  = var.deploy_onprem_simulation ? 1 : 0

  environment         = local.environment
  location            = var.location
  location_short      = local.location_short
  resource_group_name = azurerm_resource_group.onprem[0].name
  tags                = merge(local.common_tags, { Location = "OnPremises-Simulated" })

  onprem_address_space  = var.onprem_address_space
  gateway_subnet_prefix = var.onprem_gateway_subnet_prefix
  servers_subnet_prefix = var.onprem_servers_subnet_prefix

  vpn_gateway_sku       = var.vpn_gateway_sku
  enable_bgp            = var.enable_bgp
  onprem_bgp_asn        = var.onprem_bgp_asn
  hub_vpn_gateway_id    = var.deploy_vpn_gateway ? module.hub.vpn_gateway_id : null
  deploy_vpn_connection = var.deploy_vpn_gateway
  vpn_shared_key        = var.vpn_shared_key

  # Site-to-Site VPN parameters
  hub_vpn_gateway_public_ip = var.deploy_vpn_gateway ? module.hub.vpn_gateway_public_ip : null
  hub_address_spaces = concat(
    var.hub_address_space,
    var.identity_address_space,
    var.management_address_space,
    var.shared_address_space,
    var.deploy_workload_prod ? var.workload_prod_address_space : [],
    var.deploy_workload_dev ? var.workload_dev_address_space : []
  )
  hub_bgp_asn             = var.hub_bgp_asn
  hub_bgp_peering_address = var.deploy_vpn_gateway && var.enable_bgp ? module.hub.vpn_gateway_bgp_peering_address : null

  vm_size                = var.vm_size
  admin_username         = var.admin_username
  admin_password         = var.admin_password
  enable_auto_shutdown   = var.enable_auto_shutdown
  allowed_rdp_source_ips = var.allowed_rdp_source_ips

  depends_on = [module.hub]
}

# =============================================================================
# LOCAL NETWORK GATEWAY IN HUB - Represents On-Prem from Azure's perspective
# =============================================================================

module "lng_to_onprem" {
  source = "./modules/networking/local-network-gateway"
  count  = var.deploy_onprem_simulation && var.deploy_vpn_gateway ? 1 : 0

  name                = "lng-to-onprem-${local.environment}"
  resource_group_name = azurerm_resource_group.hub.name
  location            = var.location
  gateway_address     = module.onprem[0].vpn_gateway_public_ip
  address_space       = var.enable_bgp ? [] : var.onprem_address_space # Empty when using BGP (routes learned dynamically)
  enable_bgp          = var.enable_bgp
  bgp_asn             = var.onprem_bgp_asn
  bgp_peering_address = var.enable_bgp ? module.onprem[0].vpn_gateway_bgp_peering_address : null
  tags                = local.common_tags

  depends_on = [module.onprem]
}

# Site-to-Site IPsec VPN Connection from Hub to On-Prem
module "vpn_connection_hub_to_onprem" {
  source = "./modules/networking/vpn-connection"
  count  = var.deploy_onprem_simulation && var.deploy_vpn_gateway ? 1 : 0

  name                       = "con-hub-to-onprem-${local.environment}"
  resource_group_name        = azurerm_resource_group.hub.name
  location                   = var.location
  type                       = "IPsec"
  virtual_network_gateway_id = module.hub.vpn_gateway_id
  local_network_gateway_id   = module.lng_to_onprem[0].id
  shared_key                 = var.vpn_shared_key
  enable_bgp                 = var.enable_bgp
  tags                       = local.common_tags

  depends_on = [module.hub, module.onprem, module.lng_to_onprem]
}

# =============================================================================
# VNET PEERING (Hub to Spokes)
# =============================================================================

module "peering_hub_to_identity" {
  source = "./modules/networking/peering"

  name_prefix                 = "peer"
  resource_group_name         = azurerm_resource_group.hub.name
  vnet_1_id                   = module.hub.vnet_id
  vnet_1_name                 = module.hub.vnet_name
  vnet_2_id                   = module.identity.vnet_id
  vnet_2_name                 = module.identity.vnet_name
  vnet_2_resource_group_name  = azurerm_resource_group.identity.name
  allow_gateway_transit_vnet1 = var.deploy_vpn_gateway
  use_remote_gateways_vnet2   = var.deploy_vpn_gateway

  depends_on = [module.hub]
}

module "peering_hub_to_management" {
  source = "./modules/networking/peering"

  name_prefix                 = "peer"
  resource_group_name         = azurerm_resource_group.hub.name
  vnet_1_id                   = module.hub.vnet_id
  vnet_1_name                 = module.hub.vnet_name
  vnet_2_id                   = module.management.vnet_id
  vnet_2_name                 = module.management.vnet_name
  vnet_2_resource_group_name  = azurerm_resource_group.management.name
  allow_gateway_transit_vnet1 = var.deploy_vpn_gateway
  use_remote_gateways_vnet2   = var.deploy_vpn_gateway

  depends_on = [module.hub]
}

module "peering_hub_to_shared" {
  source = "./modules/networking/peering"

  name_prefix                 = "peer"
  resource_group_name         = azurerm_resource_group.hub.name
  vnet_1_id                   = module.hub.vnet_id
  vnet_1_name                 = module.hub.vnet_name
  vnet_2_id                   = module.shared_services.vnet_id
  vnet_2_name                 = module.shared_services.vnet_name
  vnet_2_resource_group_name  = azurerm_resource_group.shared.name
  allow_gateway_transit_vnet1 = var.deploy_vpn_gateway
  use_remote_gateways_vnet2   = var.deploy_vpn_gateway

  depends_on = [module.hub]
}

module "peering_hub_to_workload_prod" {
  source = "./modules/networking/peering"
  count  = var.deploy_workload_prod ? 1 : 0

  name_prefix                 = "peer"
  resource_group_name         = azurerm_resource_group.hub.name
  vnet_1_id                   = module.hub.vnet_id
  vnet_1_name                 = module.hub.vnet_name
  vnet_2_id                   = module.workload_prod[0].vnet_id
  vnet_2_name                 = module.workload_prod[0].vnet_name
  vnet_2_resource_group_name  = azurerm_resource_group.workload_prod[0].name
  allow_gateway_transit_vnet1 = var.deploy_vpn_gateway
  use_remote_gateways_vnet2   = var.deploy_vpn_gateway

  depends_on = [module.hub]
}

module "peering_hub_to_workload_dev" {
  source = "./modules/networking/peering"
  count  = var.deploy_workload_dev ? 1 : 0

  name_prefix                 = "peer"
  resource_group_name         = azurerm_resource_group.hub.name
  vnet_1_id                   = module.hub.vnet_id
  vnet_1_name                 = module.hub.vnet_name
  vnet_2_id                   = module.workload_dev[0].vnet_id
  vnet_2_name                 = module.workload_dev[0].vnet_name
  vnet_2_resource_group_name  = azurerm_resource_group.workload_dev[0].name
  allow_gateway_transit_vnet1 = var.deploy_vpn_gateway
  use_remote_gateways_vnet2   = var.deploy_vpn_gateway

  depends_on = [module.hub]
}

# =============================================================================
# FIREWALL RULES
# =============================================================================

module "firewall_rules_base" {
  source = "./modules/firewall-rules"
  count  = var.deploy_firewall ? 1 : 0

  name               = "rcg-base-rules"
  firewall_policy_id = module.hub.firewall_policy_id
  priority           = 100

  network_rule_collections = [
    {
      name     = "allow-dns"
      priority = 100
      action   = "Allow"
      rules = [
        {
          name                  = "allow-dns-to-dc"
          protocols             = ["UDP", "TCP"]
          source_addresses      = ["10.0.0.0/8"]
          destination_addresses = [var.dc01_ip_address, var.dc02_ip_address]
          destination_ports     = ["53"]
        }
      ]
    },
    {
      name     = "allow-rdp"
      priority = 200
      action   = "Allow"
      rules = [
        {
          name                  = "allow-rdp-from-hub"
          protocols             = ["TCP"]
          source_addresses      = var.hub_address_space
          destination_addresses = ["10.0.0.0/8"]
          destination_ports     = ["3389"]
        },
        {
          name                  = "allow-rdp-from-vpn"
          protocols             = ["TCP"]
          source_addresses      = [var.vpn_client_address_pool]
          destination_addresses = ["10.0.0.0/8"]
          destination_ports     = ["3389"]
        }
      ]
    },
    {
      name     = "allow-inter-spoke"
      priority = 300
      action   = "Allow"
      rules = [
        {
          name                  = "allow-spoke-to-spoke"
          protocols             = ["Any"]
          source_addresses      = ["10.0.0.0/8"]
          destination_addresses = ["10.0.0.0/8"]
          destination_ports     = ["*"]
        }
      ]
    },
    {
      name     = "allow-onprem"
      priority = 400
      action   = "Allow"
      rules = [
        {
          name                  = "allow-onprem-to-azure"
          protocols             = ["Any"]
          source_addresses      = var.onprem_address_space
          destination_addresses = ["10.0.0.0/8"]
          destination_ports     = ["*"]
        },
        {
          name                  = "allow-azure-to-onprem"
          protocols             = ["Any"]
          source_addresses      = ["10.0.0.0/8"]
          destination_addresses = var.onprem_address_space
          destination_ports     = ["*"]
        }
      ]
    }
  ]

  application_rule_collections = [
    {
      name     = "allow-internet"
      priority = 500
      action   = "Allow"
      rules = [
        {
          name              = "allow-windows-update"
          source_addresses  = ["10.0.0.0/8"]
          destination_fqdns = ["*.windowsupdate.microsoft.com", "*.update.microsoft.com", "*.windowsupdate.com"]
          protocols = [
            { type = "Https", port = 443 }
          ]
        },
        {
          name              = "allow-azure-services"
          source_addresses  = ["10.0.0.0/8"]
          destination_fqdns = ["*.azure.com", "*.microsoft.com", "*.windows.net", "*.azure-automation.net"]
          protocols = [
            { type = "Https", port = 443 }
          ]
        }
      ]
    }
  ]

  # No DNAT rules for web - public LB is separate from firewall
  nat_rule_collections = []

  depends_on = [module.hub, module.workload_prod]
}

# =============================================================================
# FIREWALL RULES - PAAS SERVICES
# =============================================================================

module "firewall_rules_paas" {
  source = "./modules/firewall-rules"
  count  = var.deploy_firewall ? 1 : 0

  name               = "rcg-paas-rules"
  firewall_policy_id = module.hub.firewall_policy_id
  priority           = 200

  network_rule_collections = []

  application_rule_collections = [
    {
      name     = "allow-paas-services"
      priority = 100
      action   = "Allow"
      rules = [
        {
          name              = "allow-azure-functions"
          source_addresses  = ["10.0.0.0/8"]
          destination_fqdns = ["*.azurewebsites.net", "*.scm.azurewebsites.net"]
          protocols = [
            { type = "Https", port = 443 }
          ]
        },
        {
          name              = "allow-static-web-apps"
          source_addresses  = ["10.0.0.0/8"]
          destination_fqdns = ["*.azurestaticapps.net", "*.swa.microsoft.com"]
          protocols = [
            { type = "Https", port = 443 }
          ]
        },
        {
          name              = "allow-logic-apps"
          source_addresses  = ["10.0.0.0/8"]
          destination_fqdns = ["*.logic.azure.com", "*.azure-api.net"]
          protocols = [
            { type = "Https", port = 443 }
          ]
        },
        {
          name              = "allow-event-grid"
          source_addresses  = ["10.0.0.0/8"]
          destination_fqdns = ["*.eventgrid.azure.net"]
          protocols = [
            { type = "Https", port = 443 }
          ]
        },
        {
          name              = "allow-service-bus"
          source_addresses  = ["10.0.0.0/8"]
          destination_fqdns = ["*.servicebus.windows.net"]
          protocols = [
            { type = "Https", port = 443 }
          ]
        },
        {
          name              = "allow-cosmos-db"
          source_addresses  = ["10.0.0.0/8"]
          destination_fqdns = ["*.documents.azure.com", "*.cosmos.azure.com"]
          protocols = [
            { type = "Https", port = 443 }
          ]
        },
        {
          name              = "allow-app-insights"
          source_addresses  = ["10.0.0.0/8"]
          destination_fqdns = ["*.applicationinsights.azure.com", "*.in.applicationinsights.azure.com", "*.live.applicationinsights.azure.com"]
          protocols = [
            { type = "Https", port = 443 }
          ]
        }
      ]
    }
  ]

  nat_rule_collections = []

  depends_on = [module.firewall_rules_base]
}

# =============================================================================
# VPN CONNECTION (Hub to On-Prem) - COMMENTED OUT TO SAVE DEPLOYMENT TIME
# =============================================================================

# module "vpn_connection_hub_to_onprem" {
#   source = "./modules/networking/vpn-connection"
#   count  = var.deploy_onprem_simulation && var.deploy_vpn_gateway ? 1 : 0
#
#   name                            = "con-hub-to-onprem-${local.environment}"
#   resource_group_name             = azurerm_resource_group.hub.name
#   location                        = var.location
#   type                            = "Vnet2Vnet"
#   virtual_network_gateway_id      = module.hub.vpn_gateway_id
#   peer_virtual_network_gateway_id = module.onprem[0].vpn_gateway_id
#   shared_key                      = var.vpn_shared_key
#   enable_bgp                      = var.enable_bgp
#   tags                            = local.common_tags
#
#   depends_on = [module.hub, module.onprem]
# }

# =============================================================================
# MONITORING - PROVISIONED LAST AFTER ALL RESOURCES ARE CREATED
# =============================================================================

# Action Group for alerts
module "monitoring_action_group" {
  source = "./modules/monitoring/action-group"

  action_group_name   = "ag-${local.environment}-${local.location_short}"
  resource_group_name = azurerm_resource_group.management.name
  short_name          = "alerts"
  tags                = local.common_tags

  email_receivers = [
    {
      name          = "admin"
      email_address = "admin@example.com"
    }
  ]

  depends_on = [
    module.hub,
    module.identity,
    module.management,
    module.shared_services
  ]
}

# Monitoring Alerts
module "monitoring_alerts" {
  source = "./modules/monitoring/alerts"

  resource_group_name = azurerm_resource_group.management.name
  location            = var.location
  alert_name_prefix   = "alert-${local.environment}"
  action_group_id     = module.monitoring_action_group.action_group_id
  alerts_enabled      = true
  tags                = local.common_tags

  # VM monitoring
  vm_ids = concat(
    [module.identity.dc01_id],
    module.management.jumpbox_id != null ? [module.management.jumpbox_id] : [],
    var.deploy_workload_prod && var.deploy_load_balancer ? module.workload_prod[0].web_server_vm_ids : []
  )
  enable_vm_alerts = true
  vm_cpu_threshold = 85

  # AKS monitoring
  aks_cluster_id       = var.deploy_workload_prod && var.deploy_aks ? module.workload_prod[0].aks_id : ""
  aks_cpu_threshold    = 80
  aks_memory_threshold = 80
  aks_min_node_count   = 1
  enable_aks_alerts    = var.deploy_workload_prod && var.deploy_aks

  # Firewall monitoring
  firewall_id               = var.deploy_firewall ? module.hub.firewall_id : ""
  firewall_health_threshold = 90
  enable_firewall_alerts    = var.deploy_firewall

  # VPN monitoring (disabled)
  vpn_gateway_id    = var.deploy_vpn_gateway ? module.hub.vpn_gateway_id : ""
  enable_vpn_alerts = var.deploy_vpn_gateway

  # SQL monitoring (disabled by default)
  sql_database_id   = var.deploy_sql ? module.shared_services.sql_database_id : ""
  enable_sql_alerts = var.deploy_sql

  depends_on = [
    module.monitoring_action_group,
    module.hub,
    module.identity,
    module.management,
    module.shared_services
  ]
}

# Diagnostic Settings
module "monitoring_diagnostics" {
  source = "./modules/monitoring/diagnostic-settings"
  count  = var.deploy_log_analytics ? 1 : 0

  diagnostic_name_prefix     = "diag-${local.environment}-${random_string.suffix.result}"
  log_analytics_workspace_id = module.management.log_analytics_workspace_id

  # Resource IDs for diagnostic settings
  firewall_id                 = var.deploy_firewall ? module.hub.firewall_id : ""
  enable_firewall_diagnostics = var.deploy_firewall
  vpn_gateway_id              = var.deploy_vpn_gateway ? module.hub.vpn_gateway_id : ""
  enable_vpn_diagnostics      = var.deploy_vpn_gateway
  aks_cluster_id              = var.deploy_workload_prod && var.deploy_aks ? module.workload_prod[0].aks_id : ""
  enable_aks_diagnostics      = var.deploy_workload_prod && var.deploy_aks
  sql_server_id               = var.deploy_sql ? module.shared_services.sql_server_id : ""
  sql_database_id             = var.deploy_sql ? module.shared_services.sql_database_id : ""
  enable_sql_diagnostics      = var.deploy_sql
  keyvault_id                 = var.deploy_keyvault ? module.shared_services.keyvault_id : ""
  enable_keyvault_diagnostics = var.deploy_keyvault
  storage_account_id          = var.deploy_storage ? module.shared_services.storage_account_id : ""
  enable_storage_diagnostics  = var.deploy_storage
  # NSG diagnostics disabled - requires known keys at plan time
  # To enable, use -target to apply NSGs first, then run apply again
  nsg_ids                = []
  enable_nsg_diagnostics = false

  depends_on = [
    module.monitoring_alerts,
    module.hub,
    module.identity,
    module.management,
    module.shared_services
  ]
}

# =============================================================================
# APPLICATION GATEWAY BACKEND POOL UPDATE
# This updates the App Gateway backend pool with workload web server IPs
# after the workload module is deployed (breaks the dependency cycle)
# =============================================================================

resource "null_resource" "appgw_backend_update" {
  count = var.deploy_application_gateway && var.deploy_load_balancer && var.deploy_workload_prod ? 1 : 0

  triggers = {
    web_server_ips = join(",", module.workload_prod[0].web_server_ips)
  }

  provisioner "local-exec" {
    command     = <<-EOT
      az network application-gateway address-pool update `
        --gateway-name "agw-hub-${local.environment}-${local.location_short}" `
        --resource-group "${azurerm_resource_group.hub.name}" `
        --name "workload-web-servers" `
        --servers ${join(" ", module.workload_prod[0].web_server_ips)}
    EOT
    interpreter = ["pwsh", "-Command"]
  }

  depends_on = [
    module.hub,
    module.workload_prod
  ]
}

# =============================================================================
# APPLICATION GATEWAY DIAGNOSTICS
# Enables diagnostics after Log Analytics workspace exists (breaks dependency cycle)
# =============================================================================

resource "azurerm_monitor_diagnostic_setting" "appgw" {
  count = var.deploy_application_gateway && var.deploy_log_analytics ? 1 : 0

  name                       = "diag-agw-hub-${local.environment}-${local.location_short}"
  target_resource_id         = module.hub.application_gateway_id
  log_analytics_workspace_id = module.management.log_analytics_workspace_id

  enabled_log {
    category = "ApplicationGatewayAccessLog"
  }

  enabled_log {
    category = "ApplicationGatewayPerformanceLog"
  }

  enabled_log {
    category = "ApplicationGatewayFirewallLog"
  }

  enabled_metric {
    category = "AllMetrics"
  }

  depends_on = [
    module.hub,
    module.management
  ]
}

# =============================================================================
# PRIVATE DNS ZONES (Centralized in Hub)
# =============================================================================

# Private DNS Zone for Azure Blob Storage
module "private_dns_blob" {
  source = "./modules/networking/private-dns-zone"
  count  = var.deploy_private_dns_zones ? 1 : 0

  zone_name           = "privatelink.blob.core.windows.net"
  resource_group_name = azurerm_resource_group.hub.name
  tags                = local.common_tags

  virtual_network_links = merge(
    {
      "link-hub" = {
        vnet_id              = module.hub.vnet_id
        registration_enabled = false
      }
      "link-identity" = {
        vnet_id              = module.identity.vnet_id
        registration_enabled = false
      }
      "link-management" = {
        vnet_id              = module.management.vnet_id
        registration_enabled = false
      }
      "link-shared" = {
        vnet_id              = module.shared_services.vnet_id
        registration_enabled = false
      }
    },
    var.deploy_workload_prod ? {
      "link-workload-prod" = {
        vnet_id              = module.workload_prod[0].vnet_id
        registration_enabled = false
      }
    } : {}
  )
}

# Private DNS Zone for Azure Key Vault
module "private_dns_keyvault" {
  source = "./modules/networking/private-dns-zone"
  count  = var.deploy_private_dns_zones ? 1 : 0

  zone_name           = "privatelink.vaultcore.azure.net"
  resource_group_name = azurerm_resource_group.hub.name
  tags                = local.common_tags

  virtual_network_links = merge(
    {
      "link-hub" = {
        vnet_id              = module.hub.vnet_id
        registration_enabled = false
      }
      "link-identity" = {
        vnet_id              = module.identity.vnet_id
        registration_enabled = false
      }
      "link-management" = {
        vnet_id              = module.management.vnet_id
        registration_enabled = false
      }
      "link-shared" = {
        vnet_id              = module.shared_services.vnet_id
        registration_enabled = false
      }
    },
    var.deploy_workload_prod ? {
      "link-workload-prod" = {
        vnet_id              = module.workload_prod[0].vnet_id
        registration_enabled = false
      }
    } : {}
  )
}

# Private DNS Zone for Azure SQL Database
module "private_dns_sql" {
  source = "./modules/networking/private-dns-zone"
  count  = var.deploy_private_dns_zones ? 1 : 0

  zone_name           = "privatelink.database.windows.net"
  resource_group_name = azurerm_resource_group.hub.name
  tags                = local.common_tags

  virtual_network_links = merge(
    {
      "link-hub" = {
        vnet_id              = module.hub.vnet_id
        registration_enabled = false
      }
      "link-identity" = {
        vnet_id              = module.identity.vnet_id
        registration_enabled = false
      }
      "link-management" = {
        vnet_id              = module.management.vnet_id
        registration_enabled = false
      }
      "link-shared" = {
        vnet_id              = module.shared_services.vnet_id
        registration_enabled = false
      }
    },
    var.deploy_workload_prod ? {
      "link-workload-prod" = {
        vnet_id              = module.workload_prod[0].vnet_id
        registration_enabled = false
      }
    } : {}
  )
}

# =============================================================================
# NAT GATEWAY (Workload Web Subnet)
# =============================================================================

module "nat_gateway" {
  source = "./modules/networking/nat-gateway"
  count  = var.deploy_nat_gateway && var.deploy_workload_prod ? 1 : 0

  name                = "natgw-workload-${local.environment}-${local.location_short}"
  resource_group_name = azurerm_resource_group.workload_prod[0].name
  location            = var.location
  tags                = local.common_tags

  subnet_id = module.workload_prod[0].web_subnet_id

  depends_on = [module.workload_prod]
}

# =============================================================================
# APPLICATION SECURITY GROUPS (Workload Tiers)
# =============================================================================

module "asg_web" {
  source = "./modules/networking/asg"
  count  = var.deploy_application_security_groups && var.deploy_workload_prod ? 1 : 0

  name                = "asg-web-${local.environment}-${local.location_short}"
  resource_group_name = azurerm_resource_group.workload_prod[0].name
  location            = var.location
  tags                = local.common_tags
}

module "asg_app" {
  source = "./modules/networking/asg"
  count  = var.deploy_application_security_groups && var.deploy_workload_prod ? 1 : 0

  name                = "asg-app-${local.environment}-${local.location_short}"
  resource_group_name = azurerm_resource_group.workload_prod[0].name
  location            = var.location
  tags                = local.common_tags
}

module "asg_data" {
  source = "./modules/networking/asg"
  count  = var.deploy_application_security_groups && var.deploy_workload_prod ? 1 : 0

  name                = "asg-data-${local.environment}-${local.location_short}"
  resource_group_name = azurerm_resource_group.workload_prod[0].name
  location            = var.location
  tags                = local.common_tags
}

# =============================================================================
# VNET FLOW LOGS (Replaces deprecated NSG Flow Logs)
# =============================================================================
# Azure Virtual Network Flow Logs - modern replacement for NSG Flow Logs
# Captures flow data at the VNet level for comprehensive traffic visibility

module "vnet_flow_logs_hub" {
  source = "./modules/monitoring/vnet-flow-logs"
  count  = var.enable_vnet_flow_logs ? 1 : 0

  name               = "flowlog-vnet-hub-${local.environment}-${local.location_short}"
  location           = var.location
  virtual_network_id = module.hub.vnet_id
  storage_account_id = module.shared_services.storage_account_id
  tags               = local.common_tags

  # Network Watcher settings - use provided name or default convention
  network_watcher_name                = var.network_watcher_name != null ? var.network_watcher_name : "NetworkWatcher_${replace(lower(var.location), " ", "")}"
  network_watcher_resource_group_name = "NetworkWatcherRG"
  create_network_watcher              = var.create_network_watcher
  resource_group_name                 = azurerm_resource_group.management.name

  # Retention
  retention_enabled = true
  retention_days    = var.nsg_flow_logs_retention_days

  # Traffic Analytics (optional)
  enable_traffic_analytics            = var.enable_traffic_analytics && var.deploy_log_analytics
  log_analytics_workspace_guid        = var.deploy_log_analytics ? module.management.log_analytics_workspace_guid : null
  log_analytics_workspace_resource_id = var.deploy_log_analytics ? module.management.log_analytics_workspace_id : null

  depends_on = [module.hub, module.shared_services, module.management]
}

module "vnet_flow_logs_workload" {
  source = "./modules/monitoring/vnet-flow-logs"
  count  = var.enable_vnet_flow_logs && var.deploy_workload_prod ? 1 : 0

  name               = "flowlog-vnet-prod-${local.environment}-${local.location_short}"
  location           = var.location
  virtual_network_id = module.workload_prod[0].vnet_id
  storage_account_id = module.shared_services.storage_account_id
  tags               = local.common_tags

  # Network Watcher settings - use provided name or default convention
  network_watcher_name                = var.network_watcher_name != null ? var.network_watcher_name : "NetworkWatcher_${replace(lower(var.location), " ", "")}"
  network_watcher_resource_group_name = "NetworkWatcherRG"
  create_network_watcher              = var.create_network_watcher
  resource_group_name                 = azurerm_resource_group.management.name

  # Retention
  retention_enabled = true
  retention_days    = var.nsg_flow_logs_retention_days

  # Traffic Analytics (optional)
  enable_traffic_analytics            = var.enable_traffic_analytics && var.deploy_log_analytics
  log_analytics_workspace_guid        = var.deploy_log_analytics ? module.management.log_analytics_workspace_guid : null
  log_analytics_workspace_resource_id = var.deploy_log_analytics ? module.management.log_analytics_workspace_id : null

  depends_on = [module.workload_prod, module.shared_services, module.management]
}

module "vnet_flow_logs_identity" {
  source = "./modules/monitoring/vnet-flow-logs"
  count  = var.enable_vnet_flow_logs ? 1 : 0

  name               = "flowlog-vnet-identity-${local.environment}-${local.location_short}"
  location           = var.location
  virtual_network_id = module.identity.vnet_id
  storage_account_id = module.shared_services.storage_account_id
  tags               = local.common_tags

  # Network Watcher settings - use provided name or default convention
  network_watcher_name                = var.network_watcher_name != null ? var.network_watcher_name : "NetworkWatcher_${replace(lower(var.location), " ", "")}"
  network_watcher_resource_group_name = "NetworkWatcherRG"
  create_network_watcher              = var.create_network_watcher
  resource_group_name                 = azurerm_resource_group.management.name

  # Retention
  retention_enabled = true
  retention_days    = var.nsg_flow_logs_retention_days

  # Traffic Analytics (optional)
  enable_traffic_analytics            = var.enable_traffic_analytics && var.deploy_log_analytics
  log_analytics_workspace_guid        = var.deploy_log_analytics ? module.management.log_analytics_workspace_guid : null
  log_analytics_workspace_resource_id = var.deploy_log_analytics ? module.management.log_analytics_workspace_id : null

  depends_on = [module.identity, module.shared_services, module.management, module.vnet_flow_logs_hub]
}

module "vnet_flow_logs_management" {
  source = "./modules/monitoring/vnet-flow-logs"
  count  = var.enable_vnet_flow_logs ? 1 : 0

  name               = "flowlog-vnet-mgmt-${local.environment}-${local.location_short}"
  location           = var.location
  virtual_network_id = module.management.vnet_id
  storage_account_id = module.shared_services.storage_account_id
  tags               = local.common_tags

  # Network Watcher settings - use provided name or default convention
  network_watcher_name                = var.network_watcher_name != null ? var.network_watcher_name : "NetworkWatcher_${replace(lower(var.location), " ", "")}"
  network_watcher_resource_group_name = "NetworkWatcherRG"
  create_network_watcher              = var.create_network_watcher
  resource_group_name                 = azurerm_resource_group.management.name

  # Retention
  retention_enabled = true
  retention_days    = var.nsg_flow_logs_retention_days

  # Traffic Analytics (optional)
  enable_traffic_analytics            = var.enable_traffic_analytics && var.deploy_log_analytics
  log_analytics_workspace_guid        = var.deploy_log_analytics ? module.management.log_analytics_workspace_guid : null
  log_analytics_workspace_resource_id = var.deploy_log_analytics ? module.management.log_analytics_workspace_id : null

  depends_on = [module.management, module.shared_services, module.vnet_flow_logs_identity]
}

module "vnet_flow_logs_shared" {
  source = "./modules/monitoring/vnet-flow-logs"
  count  = var.enable_vnet_flow_logs ? 1 : 0

  name               = "flowlog-vnet-shared-${local.environment}-${local.location_short}"
  location           = var.location
  virtual_network_id = module.shared_services.vnet_id
  storage_account_id = module.shared_services.storage_account_id
  tags               = local.common_tags

  # Network Watcher settings - use provided name or default convention
  network_watcher_name                = var.network_watcher_name != null ? var.network_watcher_name : "NetworkWatcher_${replace(lower(var.location), " ", "")}"
  network_watcher_resource_group_name = "NetworkWatcherRG"
  create_network_watcher              = var.create_network_watcher
  resource_group_name                 = azurerm_resource_group.management.name

  # Retention
  retention_enabled = true
  retention_days    = var.nsg_flow_logs_retention_days

  # Traffic Analytics (optional)
  enable_traffic_analytics            = var.enable_traffic_analytics && var.deploy_log_analytics
  log_analytics_workspace_guid        = var.deploy_log_analytics ? module.management.log_analytics_workspace_guid : null
  log_analytics_workspace_resource_id = var.deploy_log_analytics ? module.management.log_analytics_workspace_id : null

  depends_on = [module.shared_services, module.management, module.vnet_flow_logs_management]
}

# =============================================================================
# NSG FLOW LOGS (DEPRECATED - Azure retired new NSG Flow Log creation June 2025)
# =============================================================================
# NOTE: As of June 30, 2025, Azure no longer supports creation of new NSG Flow Logs.
# NSG Flow Logs will be fully retired on September 30, 2027.
# Use VNet Flow Logs above instead.
# See: https://learn.microsoft.com/azure/network-watcher/nsg-flow-logs-migrate

# =============================================================================
# AZURE BACKUP (Recovery Services Vault)
# =============================================================================

resource "azurerm_resource_group" "backup" {
  count    = var.deploy_backup ? 1 : 0
  name     = "rg-backup-${local.environment}-${local.location_short}"
  location = var.location
  tags     = local.common_tags
}

module "backup" {
  source = "./modules/backup"
  count  = var.deploy_backup ? 1 : 0

  vault_name          = "rsv-${local.environment}-${local.location_short}"
  location            = var.location
  resource_group_name = azurerm_resource_group.backup[0].name
  tags                = local.common_tags

  storage_mode_type   = var.backup_storage_redundancy
  soft_delete_enabled = var.enable_soft_delete

  # VMs to protect
  protected_vms = [
    {
      name     = "dc01"
      id       = module.identity.dc01_id
      critical = true
    }
  ]

  depends_on = [
    module.identity,
    module.workload_prod
  ]
}

# =============================================================================
# AZURE WORKBOOKS (Monitoring Dashboards)
# =============================================================================

module "workbooks" {
  source = "./modules/monitoring/workbooks"
  count  = var.deploy_workbooks && var.deploy_log_analytics ? 1 : 0

  environment         = local.environment
  location            = var.location
  resource_group_name = azurerm_resource_group.management.name
  tags                = local.common_tags

  log_analytics_workspace_id = module.management.log_analytics_workspace_id

  # Feature flags for workbooks
  deploy_vm_workbook       = true
  deploy_network_workbook  = true
  deploy_firewall_workbook = var.deploy_firewall

  depends_on = [module.management]
}

# =============================================================================
# CONNECTION MONITOR (Network Connectivity Testing)
# =============================================================================

module "connection_monitor" {
  source = "./modules/monitoring/connection-monitor"
  count  = var.deploy_connection_monitor && var.deploy_log_analytics ? 1 : 0

  monitor_name           = "cmon-${local.environment}-${local.location_short}"
  location               = var.location
  resource_group_name    = azurerm_resource_group.management.name
  create_network_watcher = var.create_network_watcher
  network_watcher_name   = var.network_watcher_name
  tags                   = local.common_tags

  log_analytics_workspace_id = module.management.log_analytics_workspace_id

  # Source endpoints (VMs with Network Watcher Agent)
  source_endpoints = [
    {
      name        = "DC01"
      resource_id = module.identity.dc01_id
    }
  ]

  # Destination endpoints
  destination_endpoints = [
    {
      name    = "Azure-Portal"
      address = "portal.azure.com"
      type    = "ExternalAddress"
    },
    {
      name    = "Microsoft"
      address = "www.microsoft.com"
      type    = "ExternalAddress"
    }
  ]

  # Test configurations
  test_configurations = [
    {
      name              = "tcp-443"
      protocol          = "Tcp"
      frequency_seconds = 60
      port              = 443
      trace_route       = true
    },
    {
      name              = "icmp-ping"
      protocol          = "Icmp"
      frequency_seconds = 60
      trace_route       = true
    }
  ]

  depends_on = [module.identity, module.management]
}

# =============================================================================
# AUTOMATION (Scheduled Start/Stop)
# =============================================================================

resource "azurerm_resource_group" "automation" {
  count    = var.enable_scheduled_startstop ? 1 : 0
  name     = "rg-automation-${local.environment}-${local.location_short}"
  location = var.location
  tags     = local.common_tags
}

module "automation" {
  source = "./modules/automation"
  count  = var.enable_scheduled_startstop ? 1 : 0

  automation_account_name = "aa-${local.environment}-${local.location_short}"
  location                = var.location
  resource_group_name     = azurerm_resource_group.automation[0].name
  tags                    = local.common_tags

  subscription_id = var.subscription_id

  # Resource groups to manage
  resource_group_names = [
    azurerm_resource_group.identity.name,
    var.deploy_workload_prod ? azurerm_resource_group.workload_prod[0].name : ""
  ]

  # Schedule configuration
  timezone              = var.startstop_timezone
  enable_start_schedule = true
  enable_stop_schedule  = true

  depends_on = [
    module.identity,
    module.workload_prod
  ]
}

# =============================================================================
# RBAC CUSTOM ROLES
# =============================================================================

module "rbac" {
  source = "./modules/rbac"
  count  = var.deploy_rbac_custom_roles ? 1 : 0

  # Role definitions
  deploy_network_operator_role  = true
  deploy_backup_operator_role   = true
  deploy_monitoring_reader_role = true
}

# =============================================================================
# AZURE POLICY
# =============================================================================

module "azure_policy" {
  source = "./modules/policy"
  count  = var.deploy_azure_policy ? 1 : 0

  scope       = "/subscriptions/${var.subscription_id}"
  location    = var.location
  environment = local.environment

  # Policy configuration
  enable_allowed_locations_policy    = true
  allowed_locations                  = var.policy_allowed_locations
  enable_require_tag_policy          = true
  required_tags                      = var.policy_required_tags
  enable_inherit_tag_policy          = false # Disabled - policy definition deprecated
  enable_audit_public_network_access = true
  enable_require_https_storage       = true
  enable_audit_unattached_disks      = false # Disabled - policy definition deprecated
  enable_require_nsg_on_subnet       = true
}

# =============================================================================
# MANAGEMENT GROUPS (CAF Hierarchy)
# =============================================================================

module "management_groups" {
  source = "./modules/management-groups"
  count  = var.deploy_management_groups ? 1 : 0

  root_management_group_name = var.management_group_root_name
  root_management_group_id   = var.management_group_root_id

  create_platform_mg       = true
  create_landing_zones_mg  = true
  create_sandbox_mg        = true
  create_decommissioned_mg = true

  # Place current subscription in Landing Zones > Corp
  subscription_ids_landing_zones_corp = [var.subscription_id]
}

# =============================================================================
# COST MANAGEMENT
# =============================================================================

module "cost_management" {
  source = "./modules/cost-management"
  count  = var.deploy_cost_management ? 1 : 0

  scope               = "/subscriptions/${var.subscription_id}"
  resource_group_name = azurerm_resource_group.management.name
  environment         = local.environment
  location            = var.location

  enable_budget = true
  budget_amount = var.cost_budget_amount
  budget_name   = "monthly-budget-${var.project}"

  enable_action_group = length(var.cost_alert_emails) > 0
  action_group_email_receivers = [for i, email in var.cost_alert_emails : {
    name          = "cost-alert-${i + 1}"
    email_address = email
  }]

  enable_anomaly_alert          = length(var.cost_alert_emails) > 0
  anomaly_alert_email_receivers = var.cost_alert_emails

  tags = local.common_tags
}

# =============================================================================
# REGULATORY COMPLIANCE (Workload RGs Only)
# =============================================================================

module "regulatory_compliance_workload_prod" {
  source = "./modules/regulatory-compliance"
  count  = var.deploy_regulatory_compliance && var.deploy_workload_prod ? 1 : 0

  scope       = azurerm_resource_group.workload_prod[0].id
  location    = var.location
  environment = local.environment

  enable_hipaa             = var.enable_hipaa_compliance
  hipaa_enforcement_mode   = var.compliance_enforcement_mode
  enable_pci_dss           = var.enable_pci_dss_compliance
  pci_dss_enforcement_mode = var.compliance_enforcement_mode

  log_analytics_workspace_id = var.deploy_log_analytics ? module.management.log_analytics_workspace_id : null
}
