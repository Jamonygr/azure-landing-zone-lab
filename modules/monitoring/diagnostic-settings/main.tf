# Diagnostic Settings Module
# Creates diagnostic settings to send logs and metrics to Log Analytics

# Firewall Diagnostic Settings
resource "azurerm_monitor_diagnostic_setting" "firewall" {
  count                      = var.enable_firewall_diagnostics ? 1 : 0
  name                       = "${var.diagnostic_name_prefix}-firewall"
  target_resource_id         = var.firewall_id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category = "AzureFirewallApplicationRule"
  }

  enabled_log {
    category = "AzureFirewallNetworkRule"
  }

  enabled_log {
    category = "AzureFirewallDnsProxy"
  }

  enabled_metric {
    category = "AllMetrics"
  }
}

# VPN Gateway Diagnostic Settings
resource "azurerm_monitor_diagnostic_setting" "vpn_gateway" {
  count                      = var.enable_vpn_diagnostics ? 1 : 0
  name                       = "${var.diagnostic_name_prefix}-vpn-gateway"
  target_resource_id         = var.vpn_gateway_id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category = "GatewayDiagnosticLog"
  }

  enabled_log {
    category = "TunnelDiagnosticLog"
  }

  enabled_log {
    category = "RouteDiagnosticLog"
  }

  enabled_log {
    category = "IKEDiagnosticLog"
  }

  enabled_metric {
    category = "AllMetrics"
  }
}

# AKS Diagnostic Settings
resource "azurerm_monitor_diagnostic_setting" "aks" {
  count                      = var.enable_aks_diagnostics ? 1 : 0
  name                       = "${var.diagnostic_name_prefix}-aks"
  target_resource_id         = var.aks_cluster_id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category = "kube-apiserver"
  }

  enabled_log {
    category = "kube-controller-manager"
  }

  enabled_log {
    category = "kube-scheduler"
  }

  enabled_log {
    category = "kube-audit"
  }

  enabled_log {
    category = "cluster-autoscaler"
  }

  enabled_log {
    category = "guard"
  }

  enabled_metric {
    category = "AllMetrics"
  }
}

# SQL Server Diagnostic Settings
resource "azurerm_monitor_diagnostic_setting" "sql_server" {
  count                      = var.enable_sql_diagnostics ? 1 : 0
  name                       = "${var.diagnostic_name_prefix}-sql-server"
  target_resource_id         = var.sql_server_id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_metric {
    category = "AllMetrics"
  }
}

# SQL Database Diagnostic Settings
resource "azurerm_monitor_diagnostic_setting" "sql_database" {
  count                      = var.enable_sql_diagnostics ? 1 : 0
  name                       = "${var.diagnostic_name_prefix}-sql-database"
  target_resource_id         = var.sql_database_id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category = "SQLInsights"
  }

  enabled_log {
    category = "AutomaticTuning"
  }

  enabled_log {
    category = "QueryStoreRuntimeStatistics"
  }

  enabled_log {
    category = "Errors"
  }

  enabled_log {
    category = "DatabaseWaitStatistics"
  }

  enabled_log {
    category = "Timeouts"
  }

  enabled_log {
    category = "Blocks"
  }

  enabled_log {
    category = "Deadlocks"
  }

  enabled_metric {
    category = "Basic"
  }

  enabled_metric {
    category = "InstanceAndAppAdvanced"
  }
}

# Key Vault Diagnostic Settings
resource "azurerm_monitor_diagnostic_setting" "keyvault" {
  count                      = var.enable_keyvault_diagnostics ? 1 : 0
  name                       = "${var.diagnostic_name_prefix}-keyvault"
  target_resource_id         = var.keyvault_id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category = "AuditEvent"
  }

  enabled_log {
    category = "AzurePolicyEvaluationDetails"
  }

  enabled_metric {
    category = "AllMetrics"
  }
}

# Storage Account Diagnostic Settings
resource "azurerm_monitor_diagnostic_setting" "storage" {
  count                      = var.enable_storage_diagnostics ? 1 : 0
  name                       = "${var.diagnostic_name_prefix}-storage"
  target_resource_id         = "${var.storage_account_id}/blobServices/default"
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category = "StorageRead"
  }

  enabled_log {
    category = "StorageWrite"
  }

  enabled_log {
    category = "StorageDelete"
  }

  enabled_metric {
    category = "Transaction"
  }

  enabled_metric {
    category = "Capacity"
  }
}

# NSG Flow Logs (for network security groups)
resource "azurerm_monitor_diagnostic_setting" "nsg" {
  for_each                   = var.enable_nsg_diagnostics ? toset(var.nsg_ids) : toset([])
  name                       = "${var.diagnostic_name_prefix}-nsg"
  target_resource_id         = each.value
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category = "NetworkSecurityGroupEvent"
  }

  enabled_log {
    category = "NetworkSecurityGroupRuleCounter"
  }
}
