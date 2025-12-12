# =============================================================================
# COST MANAGEMENT MODULE - MAIN
# Budgets, Alerts, and Cost Anomaly Detection
# =============================================================================

locals {
  # Calculate budget start date (first of current month if not provided)
  budget_start_date = var.budget_start_date != null ? var.budget_start_date : formatdate("YYYY-MM-01", timestamp())
  
  # Calculate budget end date (5 years from start if not provided)
  budget_end_date = var.budget_end_date != null ? var.budget_end_date : timeadd("${local.budget_start_date}T00:00:00Z", "43800h") # ~5 years
  
  # Extract subscription ID from scope
  subscription_id = can(regex("^/subscriptions/([^/]+)", var.scope)) ? regex("^/subscriptions/([^/]+)", var.scope)[0] : null
}

# -----------------------------------------------------------------------------
# Action Group for Cost Alerts
# -----------------------------------------------------------------------------
resource "azurerm_monitor_action_group" "cost" {
  count = var.enable_action_group && length(var.action_group_email_receivers) > 0 ? 1 : 0

  name                = "${var.action_group_name}-${var.environment}"
  resource_group_name = split("/", var.scope)[4] # Extract RG name from scope if RG scope
  short_name          = substr(var.action_group_short_name, 0, 12)
  tags                = var.tags

  dynamic "email_receiver" {
    for_each = var.action_group_email_receivers
    content {
      name          = email_receiver.value.name
      email_address = email_receiver.value.email_address
    }
  }

  dynamic "webhook_receiver" {
    for_each = var.action_group_webhook_receivers
    content {
      name        = webhook_receiver.value.name
      service_uri = webhook_receiver.value.service_uri
    }
  }
}

# -----------------------------------------------------------------------------
# Subscription Budget
# -----------------------------------------------------------------------------
resource "azurerm_consumption_budget_subscription" "this" {
  count = var.enable_budget && local.subscription_id != null ? 1 : 0

  name            = "${var.budget_name}-${var.environment}"
  subscription_id = "/subscriptions/${local.subscription_id}"
  amount          = var.budget_amount
  time_grain      = var.budget_time_grain

  time_period {
    start_date = "${local.budget_start_date}T00:00:00Z"
    end_date   = var.budget_end_date != null ? "${var.budget_end_date}T00:00:00Z" : null
  }

  # Optional resource group filter
  dynamic "filter" {
    for_each = length(var.filter_resource_groups) > 0 || length(var.filter_tags) > 0 ? [1] : []
    content {
      dynamic "dimension" {
        for_each = length(var.filter_resource_groups) > 0 ? [1] : []
        content {
          name   = "ResourceGroupName"
          values = var.filter_resource_groups
        }
      }

      dynamic "tag" {
        for_each = var.filter_tags
        content {
          name   = tag.key
          values = tag.value
        }
      }
    }
  }

  # Alert notifications
  dynamic "notification" {
    for_each = var.alert_thresholds
    content {
      enabled        = true
      threshold      = notification.value.threshold
      threshold_type = notification.value.threshold_type
      operator       = notification.value.operator

      contact_emails = notification.value.contact_emails
      contact_roles  = notification.value.contact_roles
      contact_groups = var.enable_action_group && length(var.action_group_email_receivers) > 0 ? [azurerm_monitor_action_group.cost[0].id] : notification.value.contact_groups
    }
  }
}

# -----------------------------------------------------------------------------
# Resource Group Budget (for RG-scoped deployments)
# -----------------------------------------------------------------------------
resource "azurerm_consumption_budget_resource_group" "this" {
  count = var.enable_budget && local.subscription_id == null ? 1 : 0

  name              = "${var.budget_name}-${var.environment}"
  resource_group_id = var.scope
  amount            = var.budget_amount
  time_grain        = var.budget_time_grain

  time_period {
    start_date = "${local.budget_start_date}T00:00:00Z"
    end_date   = var.budget_end_date != null ? "${var.budget_end_date}T00:00:00Z" : null
  }

  # Optional tag filter
  dynamic "filter" {
    for_each = length(var.filter_tags) > 0 ? [1] : []
    content {
      dynamic "tag" {
        for_each = var.filter_tags
        content {
          name   = tag.key
          values = tag.value
        }
      }
    }
  }

  # Alert notifications
  dynamic "notification" {
    for_each = var.alert_thresholds
    content {
      enabled        = true
      threshold      = notification.value.threshold
      threshold_type = notification.value.threshold_type
      operator       = notification.value.operator

      contact_emails = notification.value.contact_emails
      contact_roles  = notification.value.contact_roles
      contact_groups = var.enable_action_group && length(var.action_group_email_receivers) > 0 ? [azurerm_monitor_action_group.cost[0].id] : notification.value.contact_groups
    }
  }
}

# -----------------------------------------------------------------------------
# Cost Anomaly Alert (using Azure Monitor)
# -----------------------------------------------------------------------------
resource "azurerm_cost_anomaly_alert" "this" {
  count = var.enable_anomaly_alert && length(var.anomaly_alert_email_receivers) > 0 ? 1 : 0

  name            = "${var.anomaly_alert_name}-${var.environment}"
  display_name    = "Cost Anomaly Alert - ${var.environment}"
  subscription_id = local.subscription_id != null ? "/subscriptions/${local.subscription_id}" : null
  email_subject   = "Azure Cost Anomaly Detected"
  email_addresses = var.anomaly_alert_email_receivers
  message         = "An unusual spending pattern has been detected in your Azure subscription. Please review your recent resource usage."
}
