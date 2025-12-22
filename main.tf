# =============================================================================
# AZURE LANDING ZONE LAB - PILLAR ORCHESTRATION
# Networking | Identity Management | Governance | Security | Management
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
# DATA SOURCES & RANDOM SUFFIX
# =============================================================================

data "azurerm_client_config" "current" {}

resource "random_password" "admin_password" {
  length           = 20
  special          = true
  min_upper        = 1
  min_lower        = 1
  min_numeric      = 1
  min_special      = 1
  override_special = "!@#%&*()-_=+[]{}:?,."
}

resource "random_password" "sql_admin_password" {
  length           = 20
  special          = true
  min_upper        = 1
  min_lower        = 1
  min_numeric      = 1
  min_special      = 1
  override_special = "!@#%&*()-_=+[]{}:?,."
}

resource "random_password" "vpn_shared_key" {
  length  = 32
  special = false
}

resource "random_string" "suffix" {
  length  = 4
  special = false
  upper   = false
}

# =============================================================================
# RESOURCE GROUPS (per pillar)
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

resource "azurerm_resource_group" "onprem" {
  count    = var.deploy_onprem_simulation ? 1 : 0
  name     = "rg-onprem-${local.environment}-${local.location_short}"
  location = var.location
  tags     = local.common_tags
}

# =============================================================================
# NETWORKING PILLAR (Hub, Firewall, VPN, App Gateway, Firewall Rules)
# =============================================================================

module "networking" {
  source = "./landing-zones/networking"

  environment         = local.environment
  location            = var.location
  location_short      = local.location_short
  resource_group_name = azurerm_resource_group.hub.name
  tags                = local.common_tags

  hub_address_space       = var.hub_address_space
  gateway_subnet_prefix   = var.hub_gateway_subnet_prefix
  firewall_subnet_prefix  = var.hub_firewall_subnet_prefix
  hub_mgmt_subnet_prefix  = var.hub_mgmt_subnet_prefix
  hub_appgw_subnet_prefix = var.hub_appgw_subnet_prefix

  deploy_firewall         = var.deploy_firewall
  firewall_sku_tier       = var.firewall_sku_tier
  deploy_vpn_gateway      = var.deploy_vpn_gateway
  vpn_gateway_sku         = var.vpn_gateway_sku
  enable_bgp              = var.enable_bgp
  hub_bgp_asn             = var.hub_bgp_asn
  vpn_client_address_pool = var.vpn_client_address_pool

  identity_address_space   = var.identity_address_space
  management_address_space = var.management_address_space
  shared_address_space     = var.shared_address_space
  workload_address_space   = var.workload_prod_address_space

  deploy_application_gateway = var.deploy_application_gateway
  appgw_waf_mode             = var.appgw_waf_mode

  lb_backend_ips  = []
  dc01_ip_address = var.dc01_ip_address
  dc02_ip_address = var.dc02_ip_address
}

# =============================================================================
# IDENTITY MANAGEMENT PILLAR
# =============================================================================

module "identity" {
  source = "./landing-zones/identity-management"

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
  admin_password       = local.effective_admin_password
  dc01_ip_address      = var.dc01_ip_address
  dc02_ip_address      = var.dc02_ip_address
  deploy_secondary_dc  = var.deploy_secondary_dc
  enable_auto_shutdown = var.enable_auto_shutdown
  firewall_private_ip  = var.deploy_firewall ? module.networking.firewall_private_ip : null
  deploy_route_table   = var.deploy_firewall
}

# =============================================================================
# MANAGEMENT PILLAR
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
  firewall_private_ip        = var.deploy_firewall ? module.networking.firewall_private_ip : null
  deploy_route_table         = var.deploy_firewall

  vm_size                  = var.vm_size
  admin_username           = var.admin_username
  admin_password           = local.effective_admin_password
  enable_jumpbox_public_ip = var.enable_jumpbox_public_ip
  enable_auto_shutdown     = var.enable_auto_shutdown

  deploy_log_analytics = var.deploy_log_analytics
  log_retention_days   = var.log_retention_days
  log_daily_quota_gb   = var.log_daily_quota_gb

  deploy_monitoring = true
  alert_email_receivers = [
    {
      name          = "admin"
      email_address = "admin@example.com"
    }
  ]
  monitored_vm_ids             = concat(
    [module.identity.dc01_id],
    var.deploy_secondary_dc ? [module.identity.dc02_id] : []
  )
  monitored_aks_cluster_id     = ""
  monitored_firewall_id        = var.deploy_firewall ? module.networking.firewall_id : ""
  monitored_vpn_gateway_id     = var.deploy_vpn_gateway ? module.networking.vpn_gateway_id : ""
  monitored_sql_database_id    = ""
  monitored_sql_server_id      = ""
  monitored_keyvault_id        = ""
  monitored_storage_account_id = ""
  monitored_nsg_ids            = []

  # Use static boolean flags instead of checking IDs at plan time
  enable_firewall_monitoring = var.deploy_firewall
  enable_vpn_monitoring      = var.deploy_vpn_gateway

  vm_cpu_threshold                 = 85
  vm_memory_threshold_bytes        = 1073741824
  vm_disk_iops_threshold           = 500
  vm_network_threshold_bytes       = 1073741824
  aks_cpu_threshold                = 80
  aks_memory_threshold             = 80
  aks_min_node_count               = 1
  aks_pending_pods_threshold       = 5
  sql_dtu_threshold                = 80
  sql_storage_threshold            = 80
  sql_failed_connections_threshold = 5
  firewall_health_threshold        = 90
  firewall_throughput_threshold    = 1073741824
  vpn_bandwidth_threshold          = 104857600

  deploy_backup             = var.deploy_backup
  backup_storage_redundancy = var.backup_storage_redundancy
  enable_soft_delete        = var.enable_soft_delete
  backup_protected_vms = [
    {
      name     = "dc01"
      id       = module.identity.dc01_id
      critical = true
    }
  ]

  deploy_workbooks          = var.deploy_workbooks
  deploy_connection_monitor = var.deploy_connection_monitor
  create_network_watcher    = var.create_network_watcher
  network_watcher_name      = var.network_watcher_name

  enable_scheduled_startstop = var.enable_scheduled_startstop
  subscription_id            = local.effective_subscription_id
  startstop_timezone         = var.startstop_timezone
  startstop_start_time       = var.startstop_start_time
  startstop_stop_time        = var.startstop_stop_time
  resource_group_names_for_automation = concat(
    [azurerm_resource_group.identity.name],
    var.deploy_workload_prod ? [azurerm_resource_group.workload_prod[0].name] : []
  )
}

# =============================================================================
# SECURITY PILLAR
# =============================================================================

module "security" {
  source = "./landing-zones/security"

  environment         = local.environment
  location            = var.location
  location_short      = local.location_short
  resource_group_name = azurerm_resource_group.shared.name
  project             = var.project
  tags                = local.common_tags
  tenant_id           = data.azurerm_client_config.current.tenant_id

  shared_address_space = var.shared_address_space
  app_subnet_prefix    = var.shared_app_subnet_prefix
  pe_subnet_prefix     = var.shared_pe_subnet_prefix
  dns_servers          = module.identity.dns_servers
  hub_address_prefix   = var.hub_address_space[0]
  firewall_private_ip  = var.deploy_firewall ? module.networking.firewall_private_ip : null
  deploy_route_table   = var.deploy_firewall

  deploy_keyvault          = var.deploy_keyvault
  deploy_storage           = var.deploy_storage
  deploy_sql               = var.deploy_sql
  deploy_private_endpoints = var.deploy_private_endpoints
  deploy_private_dns_zones = var.deploy_private_dns_zones

  admin_password       = local.effective_admin_password
  sql_admin_login      = var.sql_admin_login
  sql_admin_password   = local.effective_sql_admin_password
  storage_account_name = "st${var.project}${local.environment}${random_string.suffix.result}"
  random_suffix        = random_string.suffix.result

  hub_vnet_id           = module.networking.vnet_id
  identity_vnet_id      = module.identity.vnet_id
  management_vnet_id    = module.management.vnet_id
  workload_prod_vnet_id = var.deploy_workload_prod ? module.workload_prod[0].vnet_id : null
  workload_dev_vnet_id  = var.deploy_workload_dev ? module.workload_dev[0].vnet_id : null
  deploy_workload_prod  = var.deploy_workload_prod
  deploy_workload_dev   = var.deploy_workload_dev
}

# =============================================================================
# WORKLOAD PROD / DEV
# =============================================================================

module "workload_prod" {
  source = "./landing-zones/management/workload"
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

  firewall_private_ip = var.deploy_firewall ? module.networking.firewall_private_ip : null
  deploy_route_table  = var.deploy_firewall

  deploy_aks                 = var.deploy_aks
  aks_subnet_prefix          = var.aks_subnet_prefix
  aks_node_count             = var.aks_node_count
  aks_vm_size                = var.aks_vm_size
  log_analytics_workspace_id = var.deploy_log_analytics ? module.management.log_analytics_workspace_id : null
  enable_diagnostics         = var.deploy_log_analytics

  deploy_load_balancer = var.deploy_load_balancer
  lb_type              = var.lb_type
  lb_private_ip        = var.lb_private_ip
  lb_web_server_count  = var.lb_web_server_count
  lb_web_server_size   = var.lb_web_server_size
  admin_username       = var.admin_username
  admin_password       = local.effective_admin_password

  deploy_functions      = var.deploy_functions
  deploy_static_web_app = var.deploy_static_web_app
  deploy_logic_apps     = var.deploy_logic_apps
  deploy_event_grid     = var.deploy_event_grid
  deploy_service_bus    = var.deploy_service_bus
  deploy_app_service    = var.deploy_app_service
  deploy_cosmos_db      = var.deploy_cosmos_db
  cosmos_location       = var.cosmos_location != "" ? var.cosmos_location : null

  paas_alternative_location = var.paas_alternative_location
}

module "workload_dev" {
  source = "./landing-zones/management/workload"
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

  firewall_private_ip = var.deploy_firewall ? module.networking.firewall_private_ip : null
  deploy_route_table  = var.deploy_firewall

  enable_diagnostics = var.deploy_log_analytics
  cosmos_location    = var.cosmos_location != "" ? var.cosmos_location : null
}

# =============================================================================
# NETWORKING CONNECTIVITY (peering, flow logs, NAT, ASGs, AppGW diag)
# =============================================================================

module "networking_connectivity" {
  source = "./landing-zones/networking/connectivity"

  environment    = local.environment
  location       = var.location
  location_short = local.location_short
  tags           = local.common_tags

  hub_resource_group_name = azurerm_resource_group.hub.name
  hub_vnet_id             = module.networking.vnet_id
  hub_vnet_name           = module.networking.vnet_name
  deploy_vpn_gateway      = var.deploy_vpn_gateway

  identity_vnet_id                  = module.identity.vnet_id
  identity_vnet_name                = module.identity.vnet_name
  identity_resource_group_name      = azurerm_resource_group.identity.name
  management_vnet_id                = module.management.vnet_id
  management_vnet_name              = module.management.vnet_name
  management_resource_group_name    = azurerm_resource_group.management.name
  shared_vnet_id                    = module.security.vnet_id
  shared_vnet_name                  = module.security.vnet_name
  shared_resource_group_name        = azurerm_resource_group.shared.name
  workload_prod_vnet_id             = var.deploy_workload_prod ? module.workload_prod[0].vnet_id : null
  workload_prod_vnet_name           = var.deploy_workload_prod ? module.workload_prod[0].vnet_name : null
  workload_prod_resource_group_name = var.deploy_workload_prod ? azurerm_resource_group.workload_prod[0].name : null
  workload_dev_vnet_id              = var.deploy_workload_dev ? module.workload_dev[0].vnet_id : null
  workload_dev_vnet_name            = var.deploy_workload_dev ? module.workload_dev[0].vnet_name : null
  workload_dev_resource_group_name  = var.deploy_workload_dev ? azurerm_resource_group.workload_dev[0].name : null
  deploy_workload_prod              = var.deploy_workload_prod
  deploy_workload_dev               = var.deploy_workload_dev

  enable_vnet_flow_logs        = var.enable_vnet_flow_logs
  storage_account_id           = module.security.storage_account_id
  create_network_watcher       = var.create_network_watcher
  network_watcher_name         = var.network_watcher_name
  nsg_flow_logs_retention_days = var.nsg_flow_logs_retention_days
  enable_traffic_analytics     = var.enable_traffic_analytics && var.deploy_log_analytics
  log_analytics_workspace_id   = var.deploy_log_analytics ? module.management.log_analytics_workspace_id : null
  log_analytics_workspace_guid = var.deploy_log_analytics ? module.management.log_analytics_workspace_guid : null

  deploy_nat_gateway                 = var.deploy_nat_gateway
  workload_web_subnet_id             = var.deploy_workload_prod ? module.workload_prod[0].web_subnet_id : null
  workload_resource_group_name       = var.deploy_workload_prod ? azurerm_resource_group.workload_prod[0].name : null
  deploy_application_security_groups = var.deploy_application_security_groups

  deploy_application_gateway = var.deploy_application_gateway
  application_gateway_name   = module.networking.application_gateway_name
  application_gateway_id     = module.networking.application_gateway_id
  appgw_backend_ips          = var.deploy_workload_prod && var.deploy_load_balancer ? module.workload_prod[0].web_server_ips : []
  enable_appgw_diagnostics   = var.deploy_application_gateway && var.deploy_log_analytics
}

# =============================================================================
# SIMULATED ON-PREMISES ENVIRONMENT
# =============================================================================

module "onprem" {
  source = "./landing-zones/networking/onprem-simulated"
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
  hub_vpn_gateway_id    = var.deploy_vpn_gateway ? module.networking.vpn_gateway_id : null
  deploy_vpn_connection = var.deploy_vpn_gateway
  vpn_shared_key        = local.effective_vpn_shared_key

  hub_vpn_gateway_public_ip = var.deploy_vpn_gateway ? module.networking.vpn_gateway_public_ip : null
  hub_address_spaces = concat(
    var.hub_address_space,
    var.identity_address_space,
    var.management_address_space,
    var.shared_address_space,
    var.deploy_workload_prod ? var.workload_prod_address_space : [],
    var.deploy_workload_dev ? var.workload_dev_address_space : []
  )
  hub_bgp_asn             = var.hub_bgp_asn
  hub_bgp_peering_address = var.deploy_vpn_gateway && var.enable_bgp ? module.networking.vpn_gateway_bgp_peering_address : null

  vm_size                = var.vm_size
  admin_username         = var.admin_username
  admin_password         = local.effective_admin_password
  enable_auto_shutdown   = var.enable_auto_shutdown
  allowed_rdp_source_ips = var.allowed_rdp_source_ips

  depends_on = [module.networking]
}

module "lng_to_onprem" {
  source = "./modules/networking/local-network-gateway"
  count  = var.deploy_onprem_simulation && var.deploy_vpn_gateway ? 1 : 0

  name                = "lng-to-onprem-${local.environment}"
  resource_group_name = azurerm_resource_group.hub.name
  location            = var.location
  gateway_address     = module.onprem[0].vpn_gateway_public_ip
  address_space       = var.enable_bgp ? [] : var.onprem_address_space
  enable_bgp          = var.enable_bgp
  bgp_asn             = var.onprem_bgp_asn
  bgp_peering_address = var.enable_bgp ? module.onprem[0].vpn_gateway_bgp_peering_address : null
  tags                = local.common_tags

  depends_on = [module.onprem]
}

module "vpn_connection_hub_to_onprem" {
  source = "./modules/networking/vpn-connection"
  count  = var.deploy_onprem_simulation && var.deploy_vpn_gateway ? 1 : 0

  name                       = "con-hub-to-onprem-${local.environment}"
  resource_group_name        = azurerm_resource_group.hub.name
  location                   = var.location
  type                       = "IPsec"
  virtual_network_gateway_id = module.networking.vpn_gateway_id
  local_network_gateway_id   = module.lng_to_onprem[0].id
  shared_key                 = local.effective_vpn_shared_key
  enable_bgp                 = var.enable_bgp
  tags                       = local.common_tags

  depends_on = [module.networking, module.onprem, module.lng_to_onprem]
}

# =============================================================================
# GOVERNANCE PILLAR
# =============================================================================

module "governance" {
  source = "./landing-zones/governance"

  subscription_id = local.effective_subscription_id
  location        = var.location
  environment     = local.environment

  deploy_management_groups   = var.deploy_management_groups
  management_group_root_name = var.management_group_root_name
  management_group_root_id   = var.management_group_root_id
  parent_management_group_id = null

  subscription_ids_platform_identity     = []
  subscription_ids_platform_management   = []
  subscription_ids_platform_connectivity = []
  subscription_ids_landing_zones_corp    = [local.effective_subscription_id]
  subscription_ids_landing_zones_online  = []
  subscription_ids_sandbox               = []
  subscription_ids_decommissioned        = []
  additional_management_groups           = []

  deploy_azure_policy                = var.deploy_azure_policy
  policy_allowed_locations           = var.policy_allowed_locations
  policy_required_tags               = var.policy_required_tags
  enable_inherit_tag_policy          = false
  enable_audit_public_network_access = var.enable_audit_public_network_access
  enable_require_https_storage       = var.enable_require_https_storage
  enable_require_nsg_on_subnet       = var.enable_require_nsg_on_subnet
  enable_allowed_vm_skus             = false
  allowed_vm_skus                    = []

  deploy_cost_management              = var.deploy_cost_management
  cost_budget_amount                  = var.cost_budget_amount
  cost_alert_emails                   = var.cost_alert_emails
  cost_management_resource_group_name = azurerm_resource_group.management.name

  deploy_regulatory_compliance = var.deploy_regulatory_compliance
  enable_hipaa_compliance      = var.enable_hipaa_compliance
  enable_pci_dss_compliance    = var.enable_pci_dss_compliance
  compliance_enforcement_mode  = var.compliance_enforcement_mode
  log_analytics_workspace_id   = var.deploy_log_analytics ? module.management.log_analytics_workspace_id : null
  compliance_scope             = var.deploy_workload_prod ? azurerm_resource_group.workload_prod[0].id : azurerm_resource_group.shared.id

  deploy_rbac_custom_roles     = var.deploy_rbac_custom_roles
  network_operator_principals  = []
  backup_operator_principals   = []
  monitoring_reader_principals = []

  tags = local.common_tags
}
