# =============================================================================
# AZURE APP SERVICE MODULE - B1 Basic Plan
# =============================================================================

# App Service Plan
resource "azurerm_service_plan" "this" {
  name                = "asp-${var.name_suffix}"
  resource_group_name = var.resource_group_name
  location            = var.location
  os_type             = var.os_type
  sku_name            = var.sku_name

  tags = var.tags
}

# Application Insights
resource "azurerm_application_insights" "this" {
  count               = var.enable_app_insights ? 1 : 0
  name                = "appi-${var.name_suffix}"
  resource_group_name = var.resource_group_name
  location            = var.location
  application_type    = var.os_type == "Windows" ? "web" : "other"
  workspace_id        = var.log_analytics_workspace_id

  tags = var.tags
}

# Linux Web App
resource "azurerm_linux_web_app" "this" {
  count               = var.os_type == "Linux" ? 1 : 0
  name                = "app-${var.name_suffix}"
  resource_group_name = var.resource_group_name
  location            = var.location
  service_plan_id     = azurerm_service_plan.this.id

  https_only = true

  site_config {
    always_on        = var.sku_name != "F1" && var.sku_name != "D1"
    ftps_state       = "Disabled"
    http2_enabled    = true
    minimum_tls_version = "1.2"

    application_stack {
      dotnet_version = var.runtime == "dotnet" ? var.runtime_version : null
      node_version   = var.runtime == "node" ? var.runtime_version : null
      python_version = var.runtime == "python" ? var.runtime_version : null
      java_version   = var.runtime == "java" ? var.runtime_version : null
    }

    cors {
      allowed_origins = var.cors_allowed_origins
    }
  }

  app_settings = merge(
    var.enable_app_insights ? {
      "APPINSIGHTS_INSTRUMENTATIONKEY"        = azurerm_application_insights.this[0].instrumentation_key
      "APPLICATIONINSIGHTS_CONNECTION_STRING" = azurerm_application_insights.this[0].connection_string
    } : {},
    var.app_settings
  )

  identity {
    type = "SystemAssigned"
  }

  tags = var.tags
}

# Windows Web App
resource "azurerm_windows_web_app" "this" {
  count               = var.os_type == "Windows" ? 1 : 0
  name                = "app-${var.name_suffix}"
  resource_group_name = var.resource_group_name
  location            = var.location
  service_plan_id     = azurerm_service_plan.this.id

  https_only = true

  site_config {
    always_on        = var.sku_name != "F1" && var.sku_name != "D1"
    ftps_state       = "Disabled"
    http2_enabled    = true
    minimum_tls_version = "1.2"

    application_stack {
      dotnet_version = var.runtime == "dotnet" ? var.runtime_version : null
      node_version   = var.runtime == "node" ? var.runtime_version : null
    }

    cors {
      allowed_origins = var.cors_allowed_origins
    }
  }

  app_settings = merge(
    var.enable_app_insights ? {
      "APPINSIGHTS_INSTRUMENTATIONKEY"        = azurerm_application_insights.this[0].instrumentation_key
      "APPLICATIONINSIGHTS_CONNECTION_STRING" = azurerm_application_insights.this[0].connection_string
    } : {},
    var.app_settings
  )

  identity {
    type = "SystemAssigned"
  }

  tags = var.tags
}

# Diagnostic Settings
resource "azurerm_monitor_diagnostic_setting" "this" {
  count                      = var.enable_diagnostics ? 1 : 0
  name                       = "diag-app-${var.name_suffix}"
  target_resource_id         = var.os_type == "Linux" ? azurerm_linux_web_app.this[0].id : azurerm_windows_web_app.this[0].id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category = "AppServiceHTTPLogs"
  }

  enabled_log {
    category = "AppServiceConsoleLogs"
  }

  enabled_log {
    category = "AppServiceAppLogs"
  }

  enabled_metric {
    category = "AllMetrics"
  }
}
