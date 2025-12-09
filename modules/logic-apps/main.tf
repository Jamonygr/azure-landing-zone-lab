# =============================================================================
# AZURE LOGIC APPS MODULE - Consumption (Pay-per-execution)
# =============================================================================

# Logic App Workflow (Consumption)
resource "azurerm_logic_app_workflow" "this" {
  name                = "logic-${var.name_suffix}"
  resource_group_name = var.resource_group_name
  location            = var.location

  identity {
    type = "SystemAssigned"
  }

  workflow_parameters = var.workflow_parameters

  parameters = var.parameters

  tags = var.tags
}

# Trigger - HTTP (optional, commonly used)
resource "azurerm_logic_app_trigger_http_request" "this" {
  count        = var.enable_http_trigger ? 1 : 0
  name         = "http-trigger"
  logic_app_id = azurerm_logic_app_workflow.this.id

  schema = var.http_trigger_schema
}

# Action - HTTP (optional, commonly used)
resource "azurerm_logic_app_action_http" "this" {
  count        = var.enable_http_action ? 1 : 0
  name         = "http-action"
  logic_app_id = azurerm_logic_app_workflow.this.id

  method = var.http_action_method
  uri    = var.http_action_uri

  headers = var.http_action_headers
  body    = var.http_action_body
}

# Diagnostic Settings
resource "azurerm_monitor_diagnostic_setting" "this" {
  count                      = var.enable_diagnostics ? 1 : 0
  name                       = "diag-${azurerm_logic_app_workflow.this.name}"
  target_resource_id         = azurerm_logic_app_workflow.this.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category = "WorkflowRuntime"
  }

  enabled_metric {
    category = "AllMetrics"
  }
}
