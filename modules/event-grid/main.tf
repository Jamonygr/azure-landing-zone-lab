# =============================================================================
# AZURE EVENT GRID MODULE - System Topics and Custom Topics
# =============================================================================

# Custom Event Grid Topic
resource "azurerm_eventgrid_topic" "this" {
  count               = var.create_custom_topic ? 1 : 0
  name                = "evgt-${var.name_suffix}"
  resource_group_name = var.resource_group_name
  location            = var.location

  input_schema = var.input_schema

  identity {
    type = "SystemAssigned"
  }

  public_network_access_enabled = var.public_network_access_enabled

  tags = var.tags
}

# System Topic (for Azure service events)
resource "azurerm_eventgrid_system_topic" "this" {
  count                  = var.create_system_topic ? 1 : 0
  name                   = "evgt-sys-${var.name_suffix}"
  resource_group_name    = var.resource_group_name
  location               = var.location
  source_arm_resource_id = var.source_arm_resource_id
  topic_type             = var.topic_type

  identity {
    type = "SystemAssigned"
  }

  tags = var.tags
}

# Event Subscription for Custom Topic
resource "azurerm_eventgrid_event_subscription" "custom" {
  count = var.create_custom_topic && var.webhook_endpoint_url != null ? 1 : 0
  name  = "evgs-${var.name_suffix}"
  scope = azurerm_eventgrid_topic.this[0].id

  dynamic "webhook_endpoint" {
    for_each = var.webhook_endpoint_url != null ? [1] : []
    content {
      url = var.webhook_endpoint_url
    }
  }

  dynamic "storage_queue_endpoint" {
    for_each = var.storage_queue_endpoint != null ? [var.storage_queue_endpoint] : []
    content {
      storage_account_id = storage_queue_endpoint.value.storage_account_id
      queue_name         = storage_queue_endpoint.value.queue_name
    }
  }

  included_event_types = var.included_event_types

  retry_policy {
    max_delivery_attempts = var.max_delivery_attempts
    event_time_to_live    = var.event_time_to_live
  }
}

# Event Subscription for System Topic
resource "azurerm_eventgrid_system_topic_event_subscription" "this" {
  count               = var.create_system_topic && var.webhook_endpoint_url != null ? 1 : 0
  name                = "evgs-sys-${var.name_suffix}"
  system_topic        = azurerm_eventgrid_system_topic.this[0].name
  resource_group_name = var.resource_group_name

  dynamic "webhook_endpoint" {
    for_each = var.webhook_endpoint_url != null ? [1] : []
    content {
      url = var.webhook_endpoint_url
    }
  }

  included_event_types = var.included_event_types

  retry_policy {
    max_delivery_attempts = var.max_delivery_attempts
    event_time_to_live    = var.event_time_to_live
  }
}

# Diagnostic Settings for Custom Topic
resource "azurerm_monitor_diagnostic_setting" "custom_topic" {
  count                      = var.create_custom_topic && var.enable_diagnostics ? 1 : 0
  name                       = "diag-${azurerm_eventgrid_topic.this[0].name}"
  target_resource_id         = azurerm_eventgrid_topic.this[0].id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category = "DeliveryFailures"
  }

  enabled_log {
    category = "PublishFailures"
  }

  enabled_metric {
    category = "AllMetrics"
  }
}
