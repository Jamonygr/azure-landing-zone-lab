# =============================================================================
# AZURE FUNCTIONS MODULE - Consumption Plan (Free Tier)
# =============================================================================

# Storage Account for Function App
resource "azurerm_storage_account" "function" {
  name                     = "stfunc${replace(replace(var.name_suffix, "-", ""), "_", "")}"
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  min_tls_version          = "TLS1_2"

  tags = var.tags
}

# App Service Plan - configurable SKU (default Y1 Consumption)
resource "azurerm_service_plan" "function" {
  name                = "asp-func-${var.name_suffix}"
  resource_group_name = var.resource_group_name
  location            = var.location
  os_type             = var.os_type
  sku_name            = var.sku_name

  tags = var.tags
}

# Application Insights for monitoring
resource "azurerm_application_insights" "function" {
  count               = var.enable_app_insights ? 1 : 0
  name                = "appi-func-${var.name_suffix}"
  resource_group_name = var.resource_group_name
  location            = var.location
  application_type    = var.os_type == "Windows" ? "web" : "other"
  workspace_id        = var.log_analytics_workspace_id

  tags = var.tags
}

# Function App
resource "azurerm_linux_function_app" "this" {
  count               = var.os_type == "Linux" ? 1 : 0
  name                = "func-${var.name_suffix}"
  resource_group_name = var.resource_group_name
  location            = var.location
  service_plan_id     = azurerm_service_plan.function.id

  storage_account_name       = azurerm_storage_account.function.name
  storage_account_access_key = azurerm_storage_account.function.primary_access_key

  https_only = true

  site_config {
    application_insights_key             = var.enable_app_insights ? azurerm_application_insights.function[0].instrumentation_key : null
    application_insights_connection_string = var.enable_app_insights ? azurerm_application_insights.function[0].connection_string : null

    application_stack {
      dotnet_version              = var.runtime == "dotnet" ? var.runtime_version : null
      node_version                = var.runtime == "node" ? var.runtime_version : null
      python_version              = var.runtime == "python" ? var.runtime_version : null
      use_dotnet_isolated_runtime = var.runtime == "dotnet" ? true : null
    }

    cors {
      allowed_origins = var.cors_allowed_origins
    }
  }

  app_settings = merge(
    {
      "FUNCTIONS_WORKER_RUNTIME" = var.runtime
    },
    var.app_settings
  )

  identity {
    type = "SystemAssigned"
  }

  tags = var.tags
}

resource "azurerm_windows_function_app" "this" {
  count               = var.os_type == "Windows" ? 1 : 0
  name                = "func-${var.name_suffix}"
  resource_group_name = var.resource_group_name
  location            = var.location
  service_plan_id     = azurerm_service_plan.function.id

  storage_account_name       = azurerm_storage_account.function.name
  storage_account_access_key = azurerm_storage_account.function.primary_access_key

  https_only = true

  site_config {
    application_insights_key             = var.enable_app_insights ? azurerm_application_insights.function[0].instrumentation_key : null
    application_insights_connection_string = var.enable_app_insights ? azurerm_application_insights.function[0].connection_string : null

    application_stack {
      dotnet_version              = var.runtime == "dotnet" ? "v${var.runtime_version}" : null
      node_version                = var.runtime == "node" ? var.runtime_version : null
      use_dotnet_isolated_runtime = var.runtime == "dotnet" ? true : null
    }

    cors {
      allowed_origins = var.cors_allowed_origins
    }
  }

  app_settings = merge(
    {
      "FUNCTIONS_WORKER_RUNTIME" = var.runtime
    },
    var.app_settings
  )

  identity {
    type = "SystemAssigned"
  }

  tags = var.tags

  # Ignore Azure-side drift for use_dotnet_isolated_runtime
  lifecycle {
    ignore_changes = [
      site_config[0].application_stack[0].use_dotnet_isolated_runtime
    ]
  }
}
