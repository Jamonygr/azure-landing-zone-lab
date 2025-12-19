# =============================================================================
# MANAGEMENT PILLAR
# Jumpbox + Log Analytics + monitoring/diagnostics + backup + automation
# =============================================================================

# Core management landing zone (jumpbox, VNet, Log Analytics)
module "management" {
  source = "./core"

  environment         = var.environment
  location            = var.location
  location_short      = var.location_short
  resource_group_name = var.resource_group_name
  tags                = var.tags

  mgmt_address_space        = var.mgmt_address_space
  jumpbox_subnet_prefix     = var.jumpbox_subnet_prefix
  dns_servers               = var.dns_servers
  hub_address_prefix        = var.hub_address_prefix
  vpn_client_address_pool   = var.vpn_client_address_pool
  onprem_address_prefix     = var.onprem_address_prefix
  allowed_jumpbox_source_ips = var.allowed_jumpbox_source_ips

  vm_size                = var.vm_size
  admin_username         = var.admin_username
  admin_password         = var.admin_password
  enable_jumpbox_public_ip = var.enable_jumpbox_public_ip
  enable_auto_shutdown   = var.enable_auto_shutdown
  deploy_log_analytics   = var.deploy_log_analytics
  log_retention_days     = var.log_retention_days
  log_daily_quota_gb     = var.log_daily_quota_gb
  firewall_private_ip    = var.firewall_private_ip
  deploy_route_table     = var.deploy_route_table

  # Disable module-level monitoring; handled below
  deploy_monitoring     = false
  alert_email_receivers = []
  monitored_vm_ids      = []
}

# -----------------------------------------------------------------------------
# Monitoring: Action Group
# -----------------------------------------------------------------------------

module "action_group" {
  source = "../../modules/monitoring/action-group"
  count  = var.deploy_monitoring ? 1 : 0

  action_group_name   = "ag-${var.environment}-${var.location_short}"
  resource_group_name = var.resource_group_name
  short_name          = "alerts"
  tags                = var.tags
  enabled             = true

  email_receivers = var.alert_email_receivers

  depends_on = [module.management]
}

# -----------------------------------------------------------------------------
# Monitoring: Alerts
# -----------------------------------------------------------------------------

module "alerts" {
  source = "../../modules/monitoring/alerts"
  count  = var.deploy_monitoring && length(module.action_group) > 0 ? 1 : 0

  resource_group_name = var.resource_group_name
  location            = var.location
  alert_name_prefix   = "alert-${var.environment}"
  action_group_id     = module.action_group[0].action_group_id
  alerts_enabled      = true
  tags                = var.tags

  vm_ids                     = var.monitored_vm_ids
  enable_vm_alerts           = length(var.monitored_vm_ids) > 0
  vm_cpu_threshold           = var.vm_cpu_threshold
  vm_memory_threshold_bytes  = var.vm_memory_threshold_bytes
  vm_disk_iops_threshold     = var.vm_disk_iops_threshold
  vm_network_threshold_bytes = var.vm_network_threshold_bytes

  aks_cluster_id    = var.monitored_aks_cluster_id
  enable_aks_alerts = var.monitored_aks_cluster_id != ""
  aks_cpu_threshold          = var.aks_cpu_threshold
  aks_memory_threshold       = var.aks_memory_threshold
  aks_min_node_count         = var.aks_min_node_count
  aks_pending_pods_threshold = var.aks_pending_pods_threshold

  firewall_id               = var.monitored_firewall_id
  enable_firewall_alerts    = var.enable_firewall_monitoring
  firewall_health_threshold = var.firewall_health_threshold
  firewall_throughput_threshold = var.firewall_throughput_threshold

  vpn_gateway_id    = var.monitored_vpn_gateway_id
  enable_vpn_alerts = var.enable_vpn_monitoring
  vpn_bandwidth_threshold = var.vpn_bandwidth_threshold

  sql_database_id   = var.monitored_sql_database_id
  enable_sql_alerts = var.monitored_sql_database_id != ""
  sql_dtu_threshold                = var.sql_dtu_threshold
  sql_storage_threshold            = var.sql_storage_threshold
  sql_failed_connections_threshold = var.sql_failed_connections_threshold

  depends_on = [module.management]
}

# -----------------------------------------------------------------------------
# Monitoring: Diagnostic Settings
# -----------------------------------------------------------------------------

module "diagnostic_settings" {
  source = "../../modules/monitoring/diagnostic-settings"
  count  = var.deploy_monitoring && var.deploy_log_analytics ? 1 : 0

  diagnostic_name_prefix     = "diag-${var.environment}"
  log_analytics_workspace_id = module.management.log_analytics_workspace_id

  firewall_id                 = var.monitored_firewall_id
  enable_firewall_diagnostics = var.enable_firewall_monitoring
  vpn_gateway_id              = var.monitored_vpn_gateway_id
  enable_vpn_diagnostics      = var.enable_vpn_monitoring
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

  depends_on = [module.management]
}

# -----------------------------------------------------------------------------
# Azure Workbooks
# -----------------------------------------------------------------------------

module "workbooks" {
  source = "../../modules/monitoring/workbooks"
  count  = var.deploy_workbooks && var.deploy_log_analytics ? 1 : 0

  environment         = var.environment
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  log_analytics_workspace_id = module.management.log_analytics_workspace_id

  deploy_vm_workbook       = true
  deploy_network_workbook  = true
  deploy_firewall_workbook = var.enable_firewall_monitoring

  depends_on = [module.management]
}

# -----------------------------------------------------------------------------
# Connection Monitor
# -----------------------------------------------------------------------------

module "connection_monitor" {
  source = "../../modules/monitoring/connection-monitor"
  count  = var.deploy_connection_monitor && var.deploy_log_analytics && length(var.monitored_vm_ids) > 0 ? 1 : 0

  monitor_name           = "cmon-${var.environment}-${var.location_short}"
  location               = var.location
  resource_group_name    = var.resource_group_name
  create_network_watcher = var.create_network_watcher
  network_watcher_name   = var.network_watcher_name
  tags                   = var.tags

  log_analytics_workspace_id = module.management.log_analytics_workspace_id

  source_endpoints = [
    {
      name        = "source-vm"
      resource_id = var.monitored_vm_ids[0]
    }
  ]

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

  depends_on = [module.management]
}

# -----------------------------------------------------------------------------
# Backup - Recovery Services Vault
# -----------------------------------------------------------------------------

resource "azurerm_resource_group" "backup" {
  count    = var.deploy_backup ? 1 : 0
  name     = "rg-backup-${var.environment}-${var.location_short}"
  location = var.location
  tags     = var.tags
}

module "backup" {
  source = "../../modules/backup"
  count  = var.deploy_backup ? 1 : 0

  vault_name          = "rsv-${var.environment}-${var.location_short}"
  location            = var.location
  resource_group_name = azurerm_resource_group.backup[0].name
  tags                = var.tags

  storage_mode_type   = var.backup_storage_redundancy
  soft_delete_enabled = var.enable_soft_delete
  protected_vms       = var.backup_protected_vms
}

# -----------------------------------------------------------------------------
# Automation - scheduled start/stop
# -----------------------------------------------------------------------------

resource "azurerm_resource_group" "automation" {
  count    = var.enable_scheduled_startstop ? 1 : 0
  name     = "rg-automation-${var.environment}-${var.location_short}"
  location = var.location
  tags     = var.tags
}

module "automation" {
  source = "../../modules/automation"
  count  = var.enable_scheduled_startstop ? 1 : 0

  automation_account_name = "aa-${var.environment}-${var.location_short}"
  location                = var.location
  resource_group_name     = azurerm_resource_group.automation[0].name
  tags                    = var.tags

  subscription_id      = var.subscription_id
  resource_group_names = var.resource_group_names_for_automation

  timezone              = var.startstop_timezone
  enable_start_schedule = true
  enable_stop_schedule  = true

  depends_on = [module.management]
}
