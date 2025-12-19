# =============================================================================
# GOVERNANCE PILLAR
# Management Groups, Azure Policy, Cost Management, Regulatory Compliance, RBAC
# =============================================================================

module "management_groups" {
  source = "../../modules/management-groups"
  count  = var.deploy_management_groups ? 1 : 0

  root_management_group_name = var.management_group_root_name
  root_management_group_id   = var.management_group_root_id
  parent_management_group_id = var.parent_management_group_id

  create_platform_mg       = true
  create_landing_zones_mg  = true
  create_sandbox_mg        = true
  create_decommissioned_mg = true

  subscription_ids_platform_identity     = var.subscription_ids_platform_identity
  subscription_ids_platform_management   = var.subscription_ids_platform_management
  subscription_ids_platform_connectivity = var.subscription_ids_platform_connectivity
  subscription_ids_landing_zones_corp    = var.subscription_ids_landing_zones_corp
  subscription_ids_landing_zones_online  = var.subscription_ids_landing_zones_online
  subscription_ids_sandbox               = var.subscription_ids_sandbox
  subscription_ids_decommissioned        = var.subscription_ids_decommissioned
  additional_management_groups           = var.additional_management_groups
}

module "azure_policy" {
  source = "../../modules/policy"
  count  = var.deploy_azure_policy ? 1 : 0

  scope       = "/subscriptions/${var.subscription_id}"
  location    = var.location
  environment = var.environment

  enable_allowed_locations_policy    = true
  allowed_locations                  = var.policy_allowed_locations
  enable_require_tag_policy          = true
  required_tags                      = var.policy_required_tags
  enable_inherit_tag_policy          = var.enable_inherit_tag_policy
  enable_audit_public_network_access = var.enable_audit_public_network_access
  enable_require_https_storage       = var.enable_require_https_storage
  enable_audit_unattached_disks      = false
  enable_require_nsg_on_subnet       = var.enable_require_nsg_on_subnet
  enable_allowed_vm_skus             = var.enable_allowed_vm_skus
  allowed_vm_skus                    = var.allowed_vm_skus
}

module "cost_management" {
  source = "../../modules/cost-management"
  count  = var.deploy_cost_management ? 1 : 0

  scope               = "/subscriptions/${var.subscription_id}"
  resource_group_name = var.cost_management_resource_group_name
  environment         = var.environment
  location            = var.location

  enable_budget = true
  budget_amount = var.cost_budget_amount
  budget_name   = "monthly-budget"

  enable_action_group = length(var.cost_alert_emails) > 0
  action_group_email_receivers = [for i, email in var.cost_alert_emails : {
    name          = "cost-alert-${i + 1}"
    email_address = email
  }]

  enable_anomaly_alert          = length(var.cost_alert_emails) > 0
  anomaly_alert_email_receivers = var.cost_alert_emails

  tags = var.tags
}

module "regulatory_compliance" {
  source = "../../modules/regulatory-compliance"
  count  = var.deploy_regulatory_compliance ? 1 : 0

  scope       = var.compliance_scope
  location    = var.location
  environment = var.environment

  enable_hipaa             = var.enable_hipaa_compliance
  hipaa_enforcement_mode   = var.compliance_enforcement_mode
  enable_pci_dss           = var.enable_pci_dss_compliance
  pci_dss_enforcement_mode = var.compliance_enforcement_mode

  log_analytics_workspace_id = var.log_analytics_workspace_id
}

module "rbac" {
  source = "../../modules/rbac"
  count  = var.deploy_rbac_custom_roles ? 1 : 0

  deploy_network_operator_role  = true
  deploy_backup_operator_role   = true
  deploy_monitoring_reader_role = true

  network_operator_principals  = var.network_operator_principals
  backup_operator_principals   = var.backup_operator_principals
  monitoring_reader_principals = var.monitoring_reader_principals
}

# =============================================================================
# MONITORING
# Log Analytics, Action Groups, Alerts, Diagnostic Settings, Workbooks
# =============================================================================

module "log_analytics" {
  source = "../../modules/monitoring/log-analytics"
  count  = var.deploy_monitoring ? 1 : 0

  name                = var.log_analytics_workspace_name
  resource_group_name = var.monitoring_resource_group_name
  location            = var.location
  sku                 = var.log_analytics_sku
  retention_in_days   = var.log_analytics_retention_days
  daily_quota_gb      = var.log_analytics_daily_quota_gb

  tags = var.tags
}

module "monitoring_action_group" {
  source = "../../modules/monitoring/action-group"
  count  = var.deploy_monitoring && length(var.monitoring_alert_emails) > 0 ? 1 : 0

  action_group_name   = "${var.environment}-monitoring-alerts"
  resource_group_name = var.monitoring_resource_group_name
  short_name          = substr("${var.environment}alerts", 0, 12)
  enabled             = true

  email_receivers = [for i, email in var.monitoring_alert_emails : {
    name                    = "alert-receiver-${i + 1}"
    email_address           = email
    use_common_alert_schema = true
  }]

  sms_receivers     = var.monitoring_sms_receivers
  webhook_receivers = var.monitoring_webhook_receivers

  tags = var.tags
}

module "monitoring_alerts" {
  source = "../../modules/monitoring/alerts"
  count  = var.deploy_monitoring && var.deploy_monitoring_alerts ? 1 : 0

  resource_group_name = var.monitoring_resource_group_name
  location            = var.location
  alert_name_prefix   = "${var.environment}-governance"
  action_group_id     = length(module.monitoring_action_group) > 0 ? module.monitoring_action_group[0].action_group_id : var.external_action_group_id
  alerts_enabled      = var.monitoring_alerts_enabled

  # VM Alerts
  enable_vm_alerts           = var.enable_vm_alerts
  vm_ids                     = var.monitored_vm_ids
  vm_cpu_threshold           = var.vm_cpu_alert_threshold
  vm_memory_threshold_bytes  = var.vm_memory_alert_threshold_bytes
  vm_disk_iops_threshold     = var.vm_disk_iops_threshold
  vm_network_threshold_bytes = var.vm_network_threshold_bytes

  # AKS Alerts
  enable_aks_alerts          = var.enable_aks_alerts
  aks_cluster_id             = var.monitored_aks_cluster_id
  aks_cpu_threshold          = var.aks_cpu_alert_threshold
  aks_memory_threshold       = var.aks_memory_alert_threshold
  aks_min_node_count         = var.aks_min_node_count
  aks_pending_pods_threshold = var.aks_pending_pods_threshold

  # SQL Alerts
  enable_sql_alerts                = var.enable_sql_alerts
  sql_database_id                  = var.monitored_sql_database_id
  sql_dtu_threshold                = var.sql_dtu_alert_threshold
  sql_storage_threshold            = var.sql_storage_alert_threshold
  sql_failed_connections_threshold = var.sql_failed_connections_threshold

  # Firewall Alerts
  enable_firewall_alerts        = var.enable_firewall_alerts
  firewall_id                   = var.monitored_firewall_id
  firewall_health_threshold     = var.firewall_health_threshold
  firewall_throughput_threshold = var.firewall_throughput_threshold

  # VPN Gateway Alerts
  enable_vpn_alerts       = var.enable_vpn_alerts
  vpn_gateway_id          = var.monitored_vpn_gateway_id
  vpn_bandwidth_threshold = var.vpn_bandwidth_threshold

  tags = var.tags
}

module "diagnostic_settings" {
  source = "../../modules/monitoring/diagnostic-settings"
  count  = var.deploy_monitoring && var.deploy_diagnostic_settings ? 1 : 0

  diagnostic_name_prefix     = "${var.environment}-diag"
  log_analytics_workspace_id = length(module.log_analytics) > 0 ? module.log_analytics[0].id : var.external_log_analytics_workspace_id

  # Firewall Diagnostics
  enable_firewall_diagnostics = var.enable_firewall_diagnostics
  firewall_id                 = var.monitored_firewall_id

  # VPN Gateway Diagnostics
  enable_vpn_diagnostics = var.enable_vpn_diagnostics
  vpn_gateway_id         = var.monitored_vpn_gateway_id

  # AKS Diagnostics
  enable_aks_diagnostics = var.enable_aks_diagnostics
  aks_cluster_id         = var.monitored_aks_cluster_id

  # SQL Diagnostics
  enable_sql_diagnostics = var.enable_sql_diagnostics
  sql_server_id          = var.monitored_sql_server_id
  sql_database_id        = var.monitored_sql_database_id

  # Key Vault Diagnostics
  enable_keyvault_diagnostics = var.enable_keyvault_diagnostics
  keyvault_id                 = var.monitored_keyvault_id

  # Storage Diagnostics
  enable_storage_diagnostics = var.enable_storage_diagnostics
  storage_account_id         = var.monitored_storage_account_id

  # NSG Diagnostics
  enable_nsg_diagnostics = var.enable_nsg_diagnostics
  nsg_ids                = var.monitored_nsg_ids
}

module "workbooks" {
  source = "../../modules/monitoring/workbooks"
  count  = var.deploy_monitoring && var.deploy_workbooks ? 1 : 0

  environment                = var.environment
  location                   = var.location
  resource_group_name        = var.monitoring_resource_group_name
  log_analytics_workspace_id = length(module.log_analytics) > 0 ? module.log_analytics[0].id : var.external_log_analytics_workspace_id

  deploy_vm_workbook       = var.deploy_vm_workbook
  deploy_network_workbook  = var.deploy_network_workbook
  deploy_firewall_workbook = var.deploy_firewall_workbook

  tags = var.tags
}
