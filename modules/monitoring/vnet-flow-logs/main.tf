# =============================================================================
# VIRTUAL NETWORK FLOW LOGS MODULE - MAIN
# Modern replacement for NSG Flow Logs (NSG Flow Logs deprecated June 2025)
# Uses AzAPI provider for Azure Virtual Network Flow Logs
# =============================================================================

terraform {
  required_providers {
    azapi = {
      source = "Azure/azapi"
    }
    azurerm = {
      source = "hashicorp/azurerm"
    }
  }
}

# Azure automatically creates NetworkWatcherRG and NetworkWatcher_<region>
# when Network Watcher is first accessed. We use data sources to reference them.
data "azurerm_network_watcher" "this" {
  name                = var.network_watcher_name
  resource_group_name = var.network_watcher_resource_group_name
}

locals {
  network_watcher_id = data.azurerm_network_watcher.this.id
}

# VNet Flow Log using AzAPI (not yet available in AzureRM as native resource)
resource "azapi_resource" "vnet_flow_log" {
  type      = "Microsoft.Network/networkWatchers/flowLogs@2024-01-01"
  name      = var.name
  parent_id = local.network_watcher_id
  location  = var.location

  body = {
    properties = {
      targetResourceId = var.virtual_network_id
      storageId        = var.storage_account_id
      enabled          = var.enabled
      flowAnalyticsConfiguration = var.enable_traffic_analytics ? {
        networkWatcherFlowAnalyticsConfiguration = {
          enabled                  = true
          workspaceId              = var.log_analytics_workspace_guid
          workspaceRegion          = var.location
          workspaceResourceId      = var.log_analytics_workspace_resource_id
          trafficAnalyticsInterval = var.traffic_analytics_interval
        }
      } : null
      retentionPolicy = {
        days    = var.retention_days
        enabled = var.retention_enabled
      }
      format = {
        type    = "JSON"
        version = var.flow_log_version
      }
    }
  }

  tags = var.tags

  lifecycle {
    ignore_changes = [
      tags["CreatedDate"]
    ]
  }
}
