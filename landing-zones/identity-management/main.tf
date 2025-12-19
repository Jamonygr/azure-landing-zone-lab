# =============================================================================
# IDENTITY MANAGEMENT PILLAR
# Wraps the identity landing zone (AD DS/DCs)
# =============================================================================

module "identity" {
  source = "./core"

  environment         = var.environment
  location            = var.location
  location_short      = var.location_short
  resource_group_name = var.resource_group_name
  tags                = var.tags

  identity_address_space = var.identity_address_space
  dc_subnet_prefix       = var.dc_subnet_prefix
  dns_servers            = var.dns_servers
  hub_address_prefix     = var.hub_address_prefix
  onprem_address_prefix  = var.onprem_address_prefix

  vm_size              = var.vm_size
  admin_username       = var.admin_username
  admin_password       = var.admin_password
  dc01_ip_address      = var.dc01_ip_address
  dc02_ip_address      = var.dc02_ip_address
  deploy_secondary_dc  = var.deploy_secondary_dc
  enable_auto_shutdown = var.enable_auto_shutdown
  firewall_private_ip  = var.firewall_private_ip
  deploy_route_table   = var.deploy_route_table
}
