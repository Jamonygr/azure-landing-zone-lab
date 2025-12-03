# Azure Monitor Alerts Module
# Creates 15 metric alerts for VMs, AKS, SQL, Firewall, and VPN Gateway

locals {
  # Network Out metric only supports a single VM scope; guard against empty lists to avoid index errors
  vm_network_scope = length(var.vm_ids) > 0 ? [var.vm_ids[0]] : []
}

# =============================================================================
# VM ALERTS (4 alerts)
# =============================================================================

# 1. VM CPU Alert - High CPU Usage
resource "azurerm_monitor_metric_alert" "vm_cpu" {
  count                    = var.enable_vm_alerts ? 1 : 0
  name                     = "${var.alert_name_prefix}-vm-cpu-high"
  resource_group_name      = var.resource_group_name
  scopes                   = var.vm_ids
  description              = "Alert when VM CPU usage exceeds threshold"
  severity                 = 2
  frequency                = "PT5M"
  window_size              = "PT15M"
  enabled                  = var.alerts_enabled
  target_resource_type     = "Microsoft.Compute/virtualMachines"
  target_resource_location = var.location

  criteria {
    metric_namespace = "Microsoft.Compute/virtualMachines"
    metric_name      = "Percentage CPU"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = var.vm_cpu_threshold
  }

  action {
    action_group_id = var.action_group_id
  }

  tags = var.tags
}

# 2. VM Memory Alert - High Memory Usage
resource "azurerm_monitor_metric_alert" "vm_memory" {
  count                    = var.enable_vm_alerts ? 1 : 0
  name                     = "${var.alert_name_prefix}-vm-memory-high"
  resource_group_name      = var.resource_group_name
  scopes                   = var.vm_ids
  description              = "Alert when VM available memory is low"
  severity                 = 2
  frequency                = "PT5M"
  window_size              = "PT15M"
  enabled                  = var.alerts_enabled
  target_resource_type     = "Microsoft.Compute/virtualMachines"
  target_resource_location = var.location

  criteria {
    metric_namespace = "Microsoft.Compute/virtualMachines"
    metric_name      = "Available Memory Bytes"
    aggregation      = "Average"
    operator         = "LessThan"
    threshold        = var.vm_memory_threshold_bytes
  }

  action {
    action_group_id = var.action_group_id
  }

  tags = var.tags
}

# 3. VM Disk Read Alert - High Disk IOPS
resource "azurerm_monitor_metric_alert" "vm_disk_read" {
  count                    = var.enable_vm_alerts ? 1 : 0
  name                     = "${var.alert_name_prefix}-vm-disk-read-high"
  resource_group_name      = var.resource_group_name
  scopes                   = var.vm_ids
  description              = "Alert when VM disk read operations are high"
  severity                 = 3
  frequency                = "PT5M"
  window_size              = "PT15M"
  enabled                  = var.alerts_enabled
  target_resource_type     = "Microsoft.Compute/virtualMachines"
  target_resource_location = var.location

  criteria {
    metric_namespace = "Microsoft.Compute/virtualMachines"
    metric_name      = "Disk Read Operations/Sec"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = var.vm_disk_iops_threshold
  }

  action {
    action_group_id = var.action_group_id
  }

  tags = var.tags
}

# 4. VM Network Alert - High Network Out (single VM - metric doesn't support multi-resource)
resource "azurerm_monitor_metric_alert" "vm_network" {
  count                    = var.enable_vm_alerts ? 1 : 0
  name                     = "${var.alert_name_prefix}-vm-network-high"
  resource_group_name      = var.resource_group_name
  scopes                   = local.vm_network_scope # Network Out Total only supports single resource
  description              = "Alert when VM network outbound traffic is high"
  severity                 = 3
  frequency                = "PT5M"
  window_size              = "PT15M"
  enabled                  = var.alerts_enabled

  criteria {
    metric_namespace = "Microsoft.Compute/virtualMachines"
    metric_name      = "Network Out Total"
    aggregation      = "Total"
    operator         = "GreaterThan"
    threshold        = var.vm_network_threshold_bytes
  }

  action {
    action_group_id = var.action_group_id
  }

  tags = var.tags
}

# =============================================================================
# AKS ALERTS (4 alerts)
# =============================================================================

# 5. AKS CPU Alert - High Cluster CPU
resource "azurerm_monitor_metric_alert" "aks_cpu" {
  count               = var.enable_aks_alerts ? 1 : 0
  name                = "${var.alert_name_prefix}-aks-cpu-high"
  resource_group_name = var.resource_group_name
  scopes              = [var.aks_cluster_id]
  description         = "Alert when AKS cluster CPU usage is high"
  severity            = 2
  frequency           = "PT5M"
  window_size         = "PT15M"
  enabled             = var.alerts_enabled

  criteria {
    metric_namespace = "Microsoft.ContainerService/managedClusters"
    metric_name      = "node_cpu_usage_percentage"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = var.aks_cpu_threshold
  }

  action {
    action_group_id = var.action_group_id
  }

  tags = var.tags
}

# 6. AKS Memory Alert - High Cluster Memory
resource "azurerm_monitor_metric_alert" "aks_memory" {
  count               = var.enable_aks_alerts ? 1 : 0
  name                = "${var.alert_name_prefix}-aks-memory-high"
  resource_group_name = var.resource_group_name
  scopes              = [var.aks_cluster_id]
  description         = "Alert when AKS cluster memory usage is high"
  severity            = 2
  frequency           = "PT5M"
  window_size         = "PT15M"
  enabled             = var.alerts_enabled

  criteria {
    metric_namespace = "Microsoft.ContainerService/managedClusters"
    metric_name      = "node_memory_working_set_percentage"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = var.aks_memory_threshold
  }

  action {
    action_group_id = var.action_group_id
  }

  tags = var.tags
}

# 7. AKS Node Count Alert - Node pool scaling
resource "azurerm_monitor_metric_alert" "aks_node_count" {
  count               = var.enable_aks_alerts ? 1 : 0
  name                = "${var.alert_name_prefix}-aks-node-count-low"
  resource_group_name = var.resource_group_name
  scopes              = [var.aks_cluster_id]
  description         = "Alert when AKS ready node count is low"
  severity            = 1
  frequency           = "PT5M"
  window_size         = "PT15M"
  enabled             = var.alerts_enabled

  criteria {
    metric_namespace = "Microsoft.ContainerService/managedClusters"
    metric_name      = "kube_node_status_condition"
    aggregation      = "Total"
    operator         = "LessThan"
    threshold        = var.aks_min_node_count
  }

  action {
    action_group_id = var.action_group_id
  }

  tags = var.tags
}

# 8. AKS Pod Count Alert - Pending pods
resource "azurerm_monitor_metric_alert" "aks_pods" {
  count               = var.enable_aks_alerts ? 1 : 0
  name                = "${var.alert_name_prefix}-aks-pods-pending"
  resource_group_name = var.resource_group_name
  scopes              = [var.aks_cluster_id]
  description         = "Alert when AKS has pending pods"
  severity            = 2
  frequency           = "PT5M"
  window_size         = "PT15M"
  enabled             = var.alerts_enabled

  criteria {
    metric_namespace = "Microsoft.ContainerService/managedClusters"
    metric_name      = "kube_pod_status_phase"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = var.aks_pending_pods_threshold

    dimension {
      name     = "phase"
      operator = "Include"
      values   = ["Pending"]
    }
  }

  action {
    action_group_id = var.action_group_id
  }

  tags = var.tags
}

# =============================================================================
# SQL DATABASE ALERTS (3 alerts)
# =============================================================================

# 9. SQL DTU Alert - High DTU Usage
resource "azurerm_monitor_metric_alert" "sql_dtu" {
  count               = var.enable_sql_alerts ? 1 : 0
  name                = "${var.alert_name_prefix}-sql-dtu-high"
  resource_group_name = var.resource_group_name
  scopes              = [var.sql_database_id]
  description         = "Alert when SQL Database DTU usage is high"
  severity            = 2
  frequency           = "PT5M"
  window_size         = "PT15M"
  enabled             = var.alerts_enabled

  criteria {
    metric_namespace = "Microsoft.Sql/servers/databases"
    metric_name      = "dtu_consumption_percent"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = var.sql_dtu_threshold
  }

  action {
    action_group_id = var.action_group_id
  }

  tags = var.tags
}

# 10. SQL Storage Alert - High Storage Usage
resource "azurerm_monitor_metric_alert" "sql_storage" {
  count               = var.enable_sql_alerts ? 1 : 0
  name                = "${var.alert_name_prefix}-sql-storage-high"
  resource_group_name = var.resource_group_name
  scopes              = [var.sql_database_id]
  description         = "Alert when SQL Database storage usage is high"
  severity            = 2
  frequency           = "PT15M"
  window_size         = "PT1H"
  enabled             = var.alerts_enabled

  criteria {
    metric_namespace = "Microsoft.Sql/servers/databases"
    metric_name      = "storage_percent"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = var.sql_storage_threshold
  }

  action {
    action_group_id = var.action_group_id
  }

  tags = var.tags
}

# 11. SQL Connection Failed Alert
resource "azurerm_monitor_metric_alert" "sql_connection_failed" {
  count               = var.enable_sql_alerts ? 1 : 0
  name                = "${var.alert_name_prefix}-sql-connection-failed"
  resource_group_name = var.resource_group_name
  scopes              = [var.sql_database_id]
  description         = "Alert when SQL Database has failed connections"
  severity            = 1
  frequency           = "PT5M"
  window_size         = "PT15M"
  enabled             = var.alerts_enabled

  criteria {
    metric_namespace = "Microsoft.Sql/servers/databases"
    metric_name      = "connection_failed"
    aggregation      = "Total"
    operator         = "GreaterThan"
    threshold        = var.sql_failed_connections_threshold
  }

  action {
    action_group_id = var.action_group_id
  }

  tags = var.tags
}

# =============================================================================
# AZURE FIREWALL ALERTS (2 alerts)
# =============================================================================

# 12. Firewall Health Alert
resource "azurerm_monitor_metric_alert" "firewall_health" {
  count               = var.enable_firewall_alerts ? 1 : 0
  name                = "${var.alert_name_prefix}-firewall-health"
  resource_group_name = var.resource_group_name
  scopes              = [var.firewall_id]
  description         = "Alert when Azure Firewall health drops"
  severity            = 1
  frequency           = "PT5M"
  window_size         = "PT15M"
  enabled             = var.alerts_enabled

  criteria {
    metric_namespace = "Microsoft.Network/azureFirewalls"
    metric_name      = "FirewallHealth"
    aggregation      = "Average"
    operator         = "LessThan"
    threshold        = var.firewall_health_threshold
  }

  action {
    action_group_id = var.action_group_id
  }

  tags = var.tags
}

# 13. Firewall Throughput Alert
resource "azurerm_monitor_metric_alert" "firewall_throughput" {
  count               = var.enable_firewall_alerts ? 1 : 0
  name                = "${var.alert_name_prefix}-firewall-throughput-high"
  resource_group_name = var.resource_group_name
  scopes              = [var.firewall_id]
  description         = "Alert when Azure Firewall throughput is high"
  severity            = 3
  frequency           = "PT5M"
  window_size         = "PT15M"
  enabled             = var.alerts_enabled

  criteria {
    metric_namespace = "Microsoft.Network/azureFirewalls"
    metric_name      = "Throughput"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = var.firewall_throughput_threshold
  }

  action {
    action_group_id = var.action_group_id
  }

  tags = var.tags
}

# =============================================================================
# VPN GATEWAY ALERTS (2 alerts)
# =============================================================================

# 14. VPN Gateway Tunnel Status Alert
resource "azurerm_monitor_metric_alert" "vpn_tunnel_status" {
  count               = var.enable_vpn_alerts ? 1 : 0
  name                = "${var.alert_name_prefix}-vpn-tunnel-down"
  resource_group_name = var.resource_group_name
  scopes              = [var.vpn_gateway_id]
  description         = "Alert when VPN tunnel is disconnected"
  severity            = 1
  frequency           = "PT5M"
  window_size         = "PT15M"
  enabled             = var.alerts_enabled

  criteria {
    metric_namespace = "Microsoft.Network/virtualNetworkGateways"
    metric_name      = "TunnelIngressBytes"
    aggregation      = "Total"
    operator         = "LessThan"
    threshold        = 1
  }

  action {
    action_group_id = var.action_group_id
  }

  tags = var.tags
}

# 15. VPN Gateway Bandwidth Alert
resource "azurerm_monitor_metric_alert" "vpn_bandwidth" {
  count               = var.enable_vpn_alerts ? 1 : 0
  name                = "${var.alert_name_prefix}-vpn-bandwidth-high"
  resource_group_name = var.resource_group_name
  scopes              = [var.vpn_gateway_id]
  description         = "Alert when VPN Gateway bandwidth is high"
  severity            = 3
  frequency           = "PT5M"
  window_size         = "PT15M"
  enabled             = var.alerts_enabled

  criteria {
    metric_namespace = "Microsoft.Network/virtualNetworkGateways"
    metric_name      = "AverageBandwidth"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = var.vpn_bandwidth_threshold
  }

  action {
    action_group_id = var.action_group_id
  }

  tags = var.tags
}
