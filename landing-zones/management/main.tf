# =============================================================================
# MANAGEMENT LANDING ZONE
# Jump boxes, monitoring, and shared management services
# =============================================================================

# Management VNet
module "mgmt_vnet" {
  source = "../../modules/networking/vnet"

  name                = "vnet-mgmt-${var.environment}-${var.location_short}"
  resource_group_name = var.resource_group_name
  location            = var.location
  address_space       = var.mgmt_address_space
  dns_servers         = var.dns_servers
  tags                = var.tags
}

# Jump Box Subnet
module "jumpbox_subnet" {
  source = "../../modules/networking/subnet"

  name                 = "snet-jumpbox-${var.environment}-${var.location_short}"
  resource_group_name  = var.resource_group_name
  virtual_network_name = module.mgmt_vnet.name
  address_prefixes     = [var.jumpbox_subnet_prefix]
  service_endpoints    = ["Microsoft.KeyVault", "Microsoft.Storage", "Microsoft.Sql"]
}

# NSG for Jump Boxes
module "jumpbox_nsg" {
  source = "../../modules/networking/nsg"

  name                  = "nsg-jumpbox-${var.environment}-${var.location_short}"
  resource_group_name   = var.resource_group_name
  location              = var.location
  subnet_id             = module.jumpbox_subnet.id
  associate_with_subnet = true
  tags                  = var.tags

  depends_on = [module.jumpbox_subnet]  # Wait for subnet before NSG association

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
      name                       = "AllowRDPFromHub"
      priority                   = 110
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      destination_port_range     = "3389"
      source_address_prefix      = var.hub_address_prefix
      destination_address_prefix = "*"
    },
    {
      name                       = "AllowRDPFromOnPrem"
      priority                   = 120
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      destination_port_range     = "3389"
      source_address_prefix      = var.onprem_address_prefix
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

# Jump Box VM
module "jumpbox" {
  source = "../../modules/compute/windows-vm"

  name                 = "vmjumpbox01"
  resource_group_name  = var.resource_group_name
  location             = var.location
  subnet_id            = module.jumpbox_subnet.id
  size                 = var.vm_size
  admin_username       = var.admin_username
  admin_password       = var.admin_password
  enable_public_ip     = var.enable_jumpbox_public_ip
  enable_auto_shutdown = var.enable_auto_shutdown
  tags                 = merge(var.tags, { Role = "JumpBox" })
}

# Log Analytics Workspace
module "log_analytics" {
  source = "../../modules/monitoring/log-analytics"
  count  = var.deploy_log_analytics ? 1 : 0

  name                = "log-${var.environment}-${var.location_short}"
  resource_group_name = var.resource_group_name
  location            = var.location
  retention_in_days   = var.log_retention_days
  daily_quota_gb      = var.log_daily_quota_gb
  tags                = var.tags
}

# Route Table (via Firewall)
module "mgmt_route_table" {
  source = "../../modules/networking/route-table"
  count  = var.deploy_route_table ? 1 : 0

  name                = "rt-mgmt-${var.environment}-${var.location_short}"
  resource_group_name = var.resource_group_name
  location            = var.location
  subnet_ids          = [module.jumpbox_subnet.id]
  tags                = var.tags
  depends_on          = [module.jumpbox_nsg] # Serialize subnet updates (NSG association before route table)

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

# =============================================================================
# MONITORING - ACTION GROUP
# =============================================================================

module "action_group" {
  source = "../../modules/monitoring/action-group"
  count  = var.deploy_monitoring ? 1 : 0

  action_group_name   = "ag-${var.environment}-${var.location_short}"
  resource_group_name = var.resource_group_name
  short_name          = "alerts"
  enabled             = true
  tags                = var.tags

  email_receivers = var.alert_email_receivers
}

# =============================================================================
# MONITORING - ALERTS (15 alerts for VMs, AKS, SQL, Firewall, VPN)
# =============================================================================

module "alerts" {
  source = "../../modules/monitoring/alerts"
  count  = var.deploy_monitoring && length(module.action_group) > 0 ? 1 : 0

  resource_group_name = var.resource_group_name
  location            = var.location
  alert_name_prefix   = "alert-${var.environment}"
  action_group_id     = module.action_group[0].action_group_id
  alerts_enabled      = var.alerts_enabled
  tags                = var.tags

  # VM monitoring
  vm_ids                     = var.monitored_vm_ids
  enable_vm_alerts           = length(var.monitored_vm_ids) > 0
  vm_cpu_threshold           = var.vm_cpu_threshold
  vm_memory_threshold_bytes  = var.vm_memory_threshold_bytes
  vm_disk_iops_threshold     = var.vm_disk_iops_threshold
  vm_network_threshold_bytes = var.vm_network_threshold_bytes

  # AKS monitoring
  aks_cluster_id             = var.monitored_aks_cluster_id
  enable_aks_alerts          = var.monitored_aks_cluster_id != ""
  aks_cpu_threshold          = var.aks_cpu_threshold
  aks_memory_threshold       = var.aks_memory_threshold
  aks_min_node_count         = var.aks_min_node_count
  aks_pending_pods_threshold = var.aks_pending_pods_threshold

  # SQL monitoring
  sql_database_id                  = var.monitored_sql_database_id
  enable_sql_alerts                = var.monitored_sql_database_id != ""
  sql_dtu_threshold                = var.sql_dtu_threshold
  sql_storage_threshold            = var.sql_storage_threshold
  sql_failed_connections_threshold = var.sql_failed_connections_threshold

  # Firewall monitoring
  firewall_id                   = var.monitored_firewall_id
  enable_firewall_alerts        = var.monitored_firewall_id != ""
  firewall_health_threshold     = var.firewall_health_threshold
  firewall_throughput_threshold = var.firewall_throughput_threshold

  # VPN Gateway monitoring
  vpn_gateway_id          = var.monitored_vpn_gateway_id
  enable_vpn_alerts       = var.monitored_vpn_gateway_id != ""
  vpn_bandwidth_threshold = var.vpn_bandwidth_threshold
}

# =============================================================================
# MONITORING - DIAGNOSTIC SETTINGS
# =============================================================================

module "diagnostic_settings" {
  source = "../../modules/monitoring/diagnostic-settings"
  count  = var.deploy_monitoring && var.deploy_log_analytics ? 1 : 0

  diagnostic_name_prefix     = "diag-${var.environment}"
  log_analytics_workspace_id = module.log_analytics[0].id

  # Resource IDs for diagnostic settings
  firewall_id                 = var.monitored_firewall_id
  enable_firewall_diagnostics = var.monitored_firewall_id != ""
  vpn_gateway_id              = var.monitored_vpn_gateway_id
  enable_vpn_diagnostics      = var.monitored_vpn_gateway_id != ""
  aks_cluster_id              = var.monitored_aks_cluster_id
  enable_aks_diagnostics      = var.monitored_aks_cluster_id != ""
  sql_server_id               = var.monitored_sql_server_id
  sql_database_id             = var.monitored_sql_database_id
  enable_sql_diagnostics      = var.monitored_sql_database_id != "" || var.monitored_sql_server_id != ""
  keyvault_id                 = var.monitored_keyvault_id
  enable_keyvault_diagnostics = var.monitored_keyvault_id != ""
  storage_account_id          = var.monitored_storage_account_id
  enable_storage_diagnostics  = var.monitored_storage_account_id != ""
  nsg_ids                     = var.monitored_nsg_ids
  enable_nsg_diagnostics      = length(var.monitored_nsg_ids) > 0
}
