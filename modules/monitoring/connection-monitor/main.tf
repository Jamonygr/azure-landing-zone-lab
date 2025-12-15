# =============================================================================
# CONNECTION MONITOR MODULE
# Network connectivity testing between endpoints
# =============================================================================

locals {
  # Use provided name or default to Azure convention
  network_watcher_name_resolved = var.network_watcher_name != null ? var.network_watcher_name : "NetworkWatcher_${replace(lower(var.location), " ", "")}"
}

# Connection Monitor uses Network Watcher
data "azurerm_network_watcher" "watcher" {
  count               = var.create_network_watcher ? 0 : 1
  name                = local.network_watcher_name_resolved
  resource_group_name = "NetworkWatcherRG"
}

resource "azurerm_network_watcher" "watcher" {
  count               = var.create_network_watcher ? 1 : 0
  name                = local.network_watcher_name_resolved
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

locals {
  network_watcher_id = var.create_network_watcher ? azurerm_network_watcher.watcher[0].id : data.azurerm_network_watcher.watcher[0].id
}

# Connection Monitor
resource "azurerm_network_connection_monitor" "monitor" {
  name               = var.monitor_name
  network_watcher_id = local.network_watcher_id
  location           = var.location
  tags               = var.tags

  # Source endpoints (VMs in the landing zone)
  dynamic "endpoint" {
    for_each = var.source_endpoints
    content {
      name               = endpoint.value.name
      target_resource_id = endpoint.value.resource_id
    }
  }

  # Destination endpoints (can be VMs, external addresses, etc.)
  dynamic "endpoint" {
    for_each = var.destination_endpoints
    content {
      name               = endpoint.value.name
      address            = lookup(endpoint.value, "address", null)
      target_resource_id = lookup(endpoint.value, "resource_id", null)
    }
  }

  # Test configurations
  dynamic "test_configuration" {
    for_each = var.test_configurations
    content {
      name                      = test_configuration.value.name
      protocol                  = test_configuration.value.protocol
      test_frequency_in_seconds = test_configuration.value.frequency_seconds

      dynamic "tcp_configuration" {
        for_each = test_configuration.value.protocol == "Tcp" ? [1] : []
        content {
          port                      = test_configuration.value.port
          trace_route_enabled       = lookup(test_configuration.value, "trace_route", true)
          destination_port_behavior = "ListenIfAvailable"
        }
      }

      dynamic "icmp_configuration" {
        for_each = test_configuration.value.protocol == "Icmp" ? [1] : []
        content {
          trace_route_enabled = lookup(test_configuration.value, "trace_route", true)
        }
      }

      dynamic "http_configuration" {
        for_each = test_configuration.value.protocol == "Http" ? [1] : []
        content {
          port                         = lookup(test_configuration.value, "port", 80)
          method                       = lookup(test_configuration.value, "method", "Get")
          prefer_https                 = lookup(test_configuration.value, "prefer_https", false)
          valid_status_code_ranges     = lookup(test_configuration.value, "valid_status_codes", ["200"])
        }
      }
    }
  }

  # Test groups - use auto-generated if none provided
  dynamic "test_group" {
    for_each = local.auto_test_groups
    content {
      name                     = test_group.value.name
      destination_endpoints    = test_group.value.destination_endpoints
      source_endpoints         = test_group.value.source_endpoints
      test_configuration_names = test_group.value.test_configuration_names
      enabled                  = lookup(test_group.value, "enabled", true)
    }
  }

  # Output to Log Analytics if specified
  output_workspace_resource_ids = var.log_analytics_workspace_id != null ? [var.log_analytics_workspace_id] : null

  depends_on = [azurerm_network_watcher.watcher]
}
