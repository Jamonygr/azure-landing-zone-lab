# =============================================================================
# NETWORKING CONNECTIVITY
# Peering, Flow Logs, NAT, ASGs, App Gateway diagnostics/backends
# =============================================================================

# -----------------------------------------------------------------------------
# Hub-to-spoke peering
# -----------------------------------------------------------------------------

module "peering_hub_to_identity" {
  source = "../../../modules/networking/peering"

  name_prefix                 = "peer"
  resource_group_name         = var.hub_resource_group_name
  vnet_1_id                   = var.hub_vnet_id
  vnet_1_name                 = var.hub_vnet_name
  vnet_2_id                   = var.identity_vnet_id
  vnet_2_name                 = var.identity_vnet_name
  vnet_2_resource_group_name  = var.identity_resource_group_name
  allow_gateway_transit_vnet1 = var.deploy_vpn_gateway
  use_remote_gateways_vnet2   = var.deploy_vpn_gateway
}

module "peering_hub_to_management" {
  source = "../../../modules/networking/peering"

  name_prefix                 = "peer"
  resource_group_name         = var.hub_resource_group_name
  vnet_1_id                   = var.hub_vnet_id
  vnet_1_name                 = var.hub_vnet_name
  vnet_2_id                   = var.management_vnet_id
  vnet_2_name                 = var.management_vnet_name
  vnet_2_resource_group_name  = var.management_resource_group_name
  allow_gateway_transit_vnet1 = var.deploy_vpn_gateway
  use_remote_gateways_vnet2   = var.deploy_vpn_gateway
}

module "peering_hub_to_shared" {
  source = "../../../modules/networking/peering"

  name_prefix                 = "peer"
  resource_group_name         = var.hub_resource_group_name
  vnet_1_id                   = var.hub_vnet_id
  vnet_1_name                 = var.hub_vnet_name
  vnet_2_id                   = var.shared_vnet_id
  vnet_2_name                 = var.shared_vnet_name
  vnet_2_resource_group_name  = var.shared_resource_group_name
  allow_gateway_transit_vnet1 = var.deploy_vpn_gateway
  use_remote_gateways_vnet2   = var.deploy_vpn_gateway
}

module "peering_hub_to_workload_prod" {
  source = "../../../modules/networking/peering"
  count  = var.deploy_workload_prod ? 1 : 0

  name_prefix                 = "peer"
  resource_group_name         = var.hub_resource_group_name
  vnet_1_id                   = var.hub_vnet_id
  vnet_1_name                 = var.hub_vnet_name
  vnet_2_id                   = var.workload_prod_vnet_id
  vnet_2_name                 = var.workload_prod_vnet_name
  vnet_2_resource_group_name  = var.workload_prod_resource_group_name
  allow_gateway_transit_vnet1 = var.deploy_vpn_gateway
  use_remote_gateways_vnet2   = var.deploy_vpn_gateway
}

module "peering_hub_to_workload_dev" {
  source = "../../../modules/networking/peering"
  count  = var.deploy_workload_dev ? 1 : 0

  name_prefix                 = "peer"
  resource_group_name         = var.hub_resource_group_name
  vnet_1_id                   = var.hub_vnet_id
  vnet_1_name                 = var.hub_vnet_name
  vnet_2_id                   = var.workload_dev_vnet_id
  vnet_2_name                 = var.workload_dev_vnet_name
  vnet_2_resource_group_name  = var.workload_dev_resource_group_name
  allow_gateway_transit_vnet1 = var.deploy_vpn_gateway
  use_remote_gateways_vnet2   = var.deploy_vpn_gateway
}

# -----------------------------------------------------------------------------
# NAT Gateway for workload web subnet
# -----------------------------------------------------------------------------

module "nat_gateway" {
  source = "../../../modules/networking/nat-gateway"
  count  = var.deploy_nat_gateway && var.deploy_workload_prod ? 1 : 0

  name                = "natgw-workload-${var.environment}-${var.location_short}"
  resource_group_name = var.workload_resource_group_name
  location            = var.location
  tags                = var.tags

  subnet_id = var.workload_web_subnet_id
}

# -----------------------------------------------------------------------------
# Application Security Groups
# -----------------------------------------------------------------------------

module "asg_web" {
  source = "../../../modules/networking/asg"
  count  = var.deploy_application_security_groups && var.deploy_workload_prod ? 1 : 0

  name                = "asg-web-${var.environment}-${var.location_short}"
  resource_group_name = var.workload_resource_group_name
  location            = var.location
  tags                = var.tags
}

module "asg_app" {
  source = "../../../modules/networking/asg"
  count  = var.deploy_application_security_groups && var.deploy_workload_prod ? 1 : 0

  name                = "asg-app-${var.environment}-${var.location_short}"
  resource_group_name = var.workload_resource_group_name
  location            = var.location
  tags                = var.tags
}

module "asg_data" {
  source = "../../../modules/networking/asg"
  count  = var.deploy_application_security_groups && var.deploy_workload_prod ? 1 : 0

  name                = "asg-data-${var.environment}-${var.location_short}"
  resource_group_name = var.workload_resource_group_name
  location            = var.location
  tags                = var.tags
}

# -----------------------------------------------------------------------------
# VNet Flow Logs
# -----------------------------------------------------------------------------

module "vnet_flow_logs_hub" {
  source = "../../../modules/monitoring/vnet-flow-logs"
  count  = var.enable_vnet_flow_logs ? 1 : 0

  name               = "flowlog-vnet-hub-${var.environment}-${var.location_short}"
  location           = var.location
  virtual_network_id = var.hub_vnet_id
  storage_account_id = var.storage_account_id
  tags               = var.tags

  network_watcher_name                = var.network_watcher_name != null ? var.network_watcher_name : "NetworkWatcher_${replace(lower(var.location), " ", "")}"
  network_watcher_resource_group_name = "NetworkWatcherRG"
  create_network_watcher              = var.create_network_watcher
  resource_group_name                 = var.management_resource_group_name

  retention_enabled = true
  retention_days    = var.nsg_flow_logs_retention_days

  enable_traffic_analytics            = var.enable_traffic_analytics
  log_analytics_workspace_guid        = var.log_analytics_workspace_guid
  log_analytics_workspace_resource_id = var.log_analytics_workspace_id
}

module "vnet_flow_logs_workload" {
  source = "../../../modules/monitoring/vnet-flow-logs"
  count  = var.enable_vnet_flow_logs && var.deploy_workload_prod && var.workload_prod_vnet_id != null ? 1 : 0

  name               = "flowlog-vnet-prod-${var.environment}-${var.location_short}"
  location           = var.location
  virtual_network_id = var.workload_prod_vnet_id
  storage_account_id = var.storage_account_id
  tags               = var.tags

  network_watcher_name                = var.network_watcher_name != null ? var.network_watcher_name : "NetworkWatcher_${replace(lower(var.location), " ", "")}"
  network_watcher_resource_group_name = "NetworkWatcherRG"
  create_network_watcher              = var.create_network_watcher
  resource_group_name                 = var.management_resource_group_name

  retention_enabled = true
  retention_days    = var.nsg_flow_logs_retention_days

  enable_traffic_analytics            = var.enable_traffic_analytics
  log_analytics_workspace_guid        = var.log_analytics_workspace_guid
  log_analytics_workspace_resource_id = var.log_analytics_workspace_id
}

module "vnet_flow_logs_identity" {
  source = "../../../modules/monitoring/vnet-flow-logs"
  count  = var.enable_vnet_flow_logs ? 1 : 0

  name               = "flowlog-vnet-identity-${var.environment}-${var.location_short}"
  location           = var.location
  virtual_network_id = var.identity_vnet_id
  storage_account_id = var.storage_account_id
  tags               = var.tags

  network_watcher_name                = var.network_watcher_name != null ? var.network_watcher_name : "NetworkWatcher_${replace(lower(var.location), " ", "")}"
  network_watcher_resource_group_name = "NetworkWatcherRG"
  create_network_watcher              = var.create_network_watcher
  resource_group_name                 = var.management_resource_group_name

  retention_enabled = true
  retention_days    = var.nsg_flow_logs_retention_days

  enable_traffic_analytics            = var.enable_traffic_analytics
  log_analytics_workspace_guid        = var.log_analytics_workspace_guid
  log_analytics_workspace_resource_id = var.log_analytics_workspace_id
}

module "vnet_flow_logs_management" {
  source = "../../../modules/monitoring/vnet-flow-logs"
  count  = var.enable_vnet_flow_logs ? 1 : 0

  name               = "flowlog-vnet-mgmt-${var.environment}-${var.location_short}"
  location           = var.location
  virtual_network_id = var.management_vnet_id
  storage_account_id = var.storage_account_id
  tags               = var.tags

  network_watcher_name                = var.network_watcher_name != null ? var.network_watcher_name : "NetworkWatcher_${replace(lower(var.location), " ", "")}"
  network_watcher_resource_group_name = "NetworkWatcherRG"
  create_network_watcher              = var.create_network_watcher
  resource_group_name                 = var.management_resource_group_name

  retention_enabled = true
  retention_days    = var.nsg_flow_logs_retention_days

  enable_traffic_analytics            = var.enable_traffic_analytics
  log_analytics_workspace_guid        = var.log_analytics_workspace_guid
  log_analytics_workspace_resource_id = var.log_analytics_workspace_id
}

module "vnet_flow_logs_shared" {
  source = "../../../modules/monitoring/vnet-flow-logs"
  count  = var.enable_vnet_flow_logs ? 1 : 0

  name               = "flowlog-vnet-shared-${var.environment}-${var.location_short}"
  location           = var.location
  virtual_network_id = var.shared_vnet_id
  storage_account_id = var.storage_account_id
  tags               = var.tags

  network_watcher_name                = var.network_watcher_name != null ? var.network_watcher_name : "NetworkWatcher_${replace(lower(var.location), " ", "")}"
  network_watcher_resource_group_name = "NetworkWatcherRG"
  create_network_watcher              = var.create_network_watcher
  resource_group_name                 = var.management_resource_group_name

  retention_enabled = true
  retention_days    = var.nsg_flow_logs_retention_days

  enable_traffic_analytics            = var.enable_traffic_analytics
  log_analytics_workspace_guid        = var.log_analytics_workspace_guid
  log_analytics_workspace_resource_id = var.log_analytics_workspace_id
}

# -----------------------------------------------------------------------------
# App Gateway backend update (post-deployment)
# -----------------------------------------------------------------------------

resource "null_resource" "appgw_backend_update" {
  count = var.deploy_application_gateway && length(var.appgw_backend_ips) > 0 ? 1 : 0

  triggers = {
    web_server_ips = join(",", var.appgw_backend_ips)
  }

  provisioner "local-exec" {
    command     = <<-EOT
      az network application-gateway address-pool update `
        --gateway-name "${var.application_gateway_name}" `
        --resource-group "${var.hub_resource_group_name}" `
        --name "workload-web-servers" `
        --servers ${join(" ", var.appgw_backend_ips)}
    EOT
    interpreter = ["pwsh", "-Command"]
  }
}

# -----------------------------------------------------------------------------
# App Gateway diagnostic settings
# -----------------------------------------------------------------------------

resource "azurerm_monitor_diagnostic_setting" "appgw" {
  count = var.deploy_application_gateway && var.enable_appgw_diagnostics ? 1 : 0

  name                       = "diag-agw-${var.environment}-${var.location_short}"
  target_resource_id         = var.application_gateway_id
  log_analytics_workspace_id = var.log_analytics_workspace_id

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
}
