# =============================================================================
# AZURE SERVICE BUS MODULE - Basic Tier
# =============================================================================

# Service Bus Namespace
resource "azurerm_servicebus_namespace" "this" {
  name                = "sb-${var.name_suffix}"
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = var.sku

  local_auth_enabled            = var.local_auth_enabled
  public_network_access_enabled = var.public_network_access_enabled
  minimum_tls_version           = "1.2"

  identity {
    type = "SystemAssigned"
  }

  tags = var.tags
}

# Queues
resource "azurerm_servicebus_queue" "this" {
  for_each     = var.queues
  name         = each.key
  namespace_id = azurerm_servicebus_namespace.this.id

  max_delivery_count                   = lookup(each.value, "max_delivery_count", 10)
  max_size_in_megabytes                = lookup(each.value, "max_size_in_megabytes", 1024)
  default_message_ttl                  = lookup(each.value, "default_message_ttl", null)
  lock_duration                        = lookup(each.value, "lock_duration", "PT1M")
  dead_lettering_on_message_expiration = lookup(each.value, "dead_lettering_on_message_expiration", false)
  partitioning_enabled                 = var.sku != "Premium" ? lookup(each.value, "enable_partitioning", false) : false
}

# Topics (Standard/Premium only)
resource "azurerm_servicebus_topic" "this" {
  for_each     = var.sku != "Basic" ? var.topics : {}
  name         = each.key
  namespace_id = azurerm_servicebus_namespace.this.id

  max_size_in_megabytes   = lookup(each.value, "max_size_in_megabytes", 1024)
  default_message_ttl     = lookup(each.value, "default_message_ttl", null)
  partitioning_enabled    = var.sku != "Premium" ? lookup(each.value, "enable_partitioning", false) : false
  support_ordering        = lookup(each.value, "support_ordering", false)
  max_message_size_in_kilobytes = var.sku == "Premium" ? lookup(each.value, "max_message_size_in_kilobytes", 1024) : null
}

# Subscriptions for Topics
resource "azurerm_servicebus_subscription" "this" {
  for_each = var.sku != "Basic" ? var.subscriptions : {}
  name     = each.value.name
  topic_id = azurerm_servicebus_topic.this[each.value.topic_name].id

  max_delivery_count                   = lookup(each.value, "max_delivery_count", 10)
  default_message_ttl                  = lookup(each.value, "default_message_ttl", null)
  lock_duration                        = lookup(each.value, "lock_duration", "PT1M")
  dead_lettering_on_message_expiration = lookup(each.value, "dead_lettering_on_message_expiration", false)
}

# Diagnostic Settings
resource "azurerm_monitor_diagnostic_setting" "this" {
  count                      = var.enable_diagnostics ? 1 : 0
  name                       = "diag-${azurerm_servicebus_namespace.this.name}"
  target_resource_id         = azurerm_servicebus_namespace.this.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category = "OperationalLogs"
  }

  enabled_log {
    category = "VNetAndIPFilteringLogs"
  }

  enabled_metric {
    category = "AllMetrics"
  }
}
