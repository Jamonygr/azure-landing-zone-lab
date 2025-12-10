# =============================================================================
# NSG FLOW LOGS MODULE - MAIN
# Traffic visibility with optional Traffic Analytics
# =============================================================================

# Network Watcher (uses existing or creates if needed)
data "azurerm_network_watcher" "this" {
  count               = var.create_network_watcher ? 0 : 1
  name                = var.network_watcher_name
  resource_group_name = var.network_watcher_resource_group_name
}

resource "azurerm_network_watcher" "this" {
  count               = var.create_network_watcher ? 1 : 0
  name                = var.network_watcher_name
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags
}

locals {
  network_watcher_id = var.create_network_watcher ? azurerm_network_watcher.this[0].id : data.azurerm_network_watcher.this[0].id
}

# NSG Flow Log
resource "azurerm_network_watcher_flow_log" "this" {
  name                 = var.name
  network_watcher_name = var.network_watcher_name
  resource_group_name  = var.create_network_watcher ? var.resource_group_name : var.network_watcher_resource_group_name

  network_security_group_id = var.network_security_group_id
  storage_account_id        = var.storage_account_id
  enabled                   = var.enabled
  version                   = var.flow_log_version

  retention_policy {
    enabled = var.retention_enabled
    days    = var.retention_days
  }

  dynamic "traffic_analytics" {
    for_each = var.enable_traffic_analytics ? [1] : []
    content {
      enabled               = true
      workspace_id          = var.log_analytics_workspace_id
      workspace_region      = var.location
      workspace_resource_id = var.log_analytics_workspace_resource_id
      interval_in_minutes   = var.traffic_analytics_interval
    }
  }

  tags = var.tags

  depends_on = [azurerm_network_watcher.this]
}
