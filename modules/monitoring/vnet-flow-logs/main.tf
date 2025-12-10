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

# Ensure Network Watcher exists in the target region (create if missing)
resource "azurerm_resource_group" "network_watcher_rg" {
  count = var.create_network_watcher ? 1 : 0

  name     = var.network_watcher_resource_group_name
  location = var.location
  tags     = var.tags
}

data "azurerm_network_watcher" "this" {
  count = var.create_network_watcher ? 0 : 1

  name                = var.network_watcher_name
  resource_group_name = var.network_watcher_resource_group_name
}

resource "azurerm_network_watcher" "this" {
  count = var.create_network_watcher ? 1 : 0

  name                = var.network_watcher_name
  resource_group_name = var.network_watcher_resource_group_name
  location            = var.location
  tags                = var.tags

  depends_on = [azurerm_resource_group.network_watcher_rg]
}

locals {
  network_watcher_id = var.create_network_watcher ? azurerm_network_watcher.this[0].id : data.azurerm_network_watcher.this[0].id
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
