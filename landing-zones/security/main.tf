# =============================================================================
# SECURITY PILLAR
# Shared services (Key Vault, Storage, SQL) + Private DNS zones and endpoints
# =============================================================================

module "shared_services" {
  source = "./shared-services"

  environment         = var.environment
  location            = var.location
  location_short      = var.location_short
  project             = var.project
  resource_group_name = var.resource_group_name
  tags                = var.tags
  tenant_id           = var.tenant_id

  shared_address_space = var.shared_address_space
  app_subnet_prefix    = var.app_subnet_prefix
  pe_subnet_prefix     = var.pe_subnet_prefix
  dns_servers          = var.dns_servers
  hub_address_prefix   = var.hub_address_prefix

  admin_password       = var.admin_password
  deploy_keyvault      = var.deploy_keyvault
  deploy_storage       = var.deploy_storage
  storage_account_name = var.storage_account_name
  deploy_sql           = var.deploy_sql
  sql_admin_login      = var.sql_admin_login
  sql_admin_password   = var.sql_admin_password
  firewall_private_ip  = var.firewall_private_ip
  deploy_route_table   = var.deploy_route_table
  random_suffix        = var.random_suffix

  deploy_private_endpoints     = var.deploy_private_endpoints
  private_dns_zone_blob_id     = var.deploy_private_dns_zones ? module.private_dns_blob[0].id : null
  private_dns_zone_keyvault_id = var.deploy_private_dns_zones ? module.private_dns_keyvault[0].id : null
  private_dns_zone_sql_id      = var.deploy_private_dns_zones ? module.private_dns_sql[0].id : null
}

locals {
  base_vnet_links = {
    "link-hub" = {
      vnet_id              = var.hub_vnet_id
      registration_enabled = false
    }
    "link-identity" = {
      vnet_id              = var.identity_vnet_id
      registration_enabled = false
    }
    "link-management" = {
      vnet_id              = var.management_vnet_id
      registration_enabled = false
    }
    "link-shared" = {
      vnet_id              = module.shared_services.vnet_id
      registration_enabled = false
    }
  }

  # Use boolean flags instead of checking vnet_id != null to avoid unknown keys at plan time
  workload_prod_link = var.deploy_workload_prod ? {
    "link-workload-prod" = {
      vnet_id              = var.workload_prod_vnet_id
      registration_enabled = false
    }
  } : {}

  workload_dev_link = var.deploy_workload_dev ? {
    "link-workload-dev" = {
      vnet_id              = var.workload_dev_vnet_id
      registration_enabled = false
    }
  } : {}

  vnet_links = merge(local.base_vnet_links, local.workload_prod_link, local.workload_dev_link)
}

# -----------------------------------------------------------------------------
# Private DNS Zones (Blob, Key Vault, SQL)
# -----------------------------------------------------------------------------

module "private_dns_blob" {
  source = "../../modules/networking/private-dns-zone"
  count  = var.deploy_private_dns_zones ? 1 : 0

  zone_name           = "privatelink.blob.core.windows.net"
  resource_group_name = var.resource_group_name
  tags                = var.tags

  virtual_network_links = local.vnet_links
}

module "private_dns_keyvault" {
  source = "../../modules/networking/private-dns-zone"
  count  = var.deploy_private_dns_zones ? 1 : 0

  zone_name           = "privatelink.vaultcore.azure.net"
  resource_group_name = var.resource_group_name
  tags                = var.tags

  virtual_network_links = local.vnet_links
}

module "private_dns_sql" {
  source = "../../modules/networking/private-dns-zone"
  count  = var.deploy_private_dns_zones ? 1 : 0

  zone_name           = "privatelink.database.windows.net"
  resource_group_name = var.resource_group_name
  tags                = var.tags

  virtual_network_links = local.vnet_links
}
