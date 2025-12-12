# =============================================================================
# COST MANAGEMENT MODULE - OUTPUTS
# =============================================================================

output "budget_id" {
  description = "The ID of the consumption budget"
  value       = var.enable_budget ? (local.subscription_id != null ? azurerm_consumption_budget_subscription.this[0].id : azurerm_consumption_budget_resource_group.this[0].id) : null
}

output "budget_name" {
  description = "The name of the consumption budget"
  value       = var.enable_budget ? "${var.budget_name}-${var.environment}" : null
}

output "budget_amount" {
  description = "The budget amount"
  value       = var.budget_amount
}

output "action_group_id" {
  description = "The ID of the action group for cost alerts"
  value       = var.enable_action_group && length(var.action_group_email_receivers) > 0 ? azurerm_monitor_action_group.cost[0].id : null
}

output "anomaly_alert_id" {
  description = "The ID of the cost anomaly alert"
  value       = var.enable_anomaly_alert && length(var.anomaly_alert_email_receivers) > 0 ? azurerm_cost_anomaly_alert.this[0].id : null
}

output "alert_thresholds" {
  description = "Configured alert thresholds"
  value       = var.alert_thresholds
}
