# =============================================================================
# AZURE APPLICATION GATEWAY MODULE - WAF_v2
# =============================================================================

# Public IP for Application Gateway
resource "azurerm_public_ip" "this" {
  name                = "pip-agw-${var.name_suffix}"
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = var.zones

  tags = var.tags
}

# User-assigned Managed Identity for Key Vault integration
resource "azurerm_user_assigned_identity" "this" {
  count               = var.enable_key_vault_integration ? 1 : 0
  name                = "id-agw-${var.name_suffix}"
  resource_group_name = var.resource_group_name
  location            = var.location

  tags = var.tags
}

# Application Gateway
resource "azurerm_application_gateway" "this" {
  name                = "agw-${var.name_suffix}"
  resource_group_name = var.resource_group_name
  location            = var.location
  zones               = var.zones
  enable_http2        = true

  sku {
    name     = var.sku_name
    tier     = var.sku_tier
    capacity = var.autoscale_configuration == null ? var.capacity : null
  }

  dynamic "autoscale_configuration" {
    for_each = var.autoscale_configuration != null ? [var.autoscale_configuration] : []
    content {
      min_capacity = autoscale_configuration.value.min_capacity
      max_capacity = autoscale_configuration.value.max_capacity
    }
  }

  gateway_ip_configuration {
    name      = "gateway-ip-config"
    subnet_id = var.subnet_id
  }

  frontend_ip_configuration {
    name                 = "frontend-ip-public"
    public_ip_address_id = azurerm_public_ip.this.id
  }

  dynamic "frontend_ip_configuration" {
    for_each = var.private_ip_address != null ? [1] : []
    content {
      name                          = "frontend-ip-private"
      subnet_id                     = var.subnet_id
      private_ip_address            = var.private_ip_address
      private_ip_address_allocation = "Static"
    }
  }

  frontend_port {
    name = "port-80"
    port = 80
  }

  frontend_port {
    name = "port-443"
    port = 443
  }

  # Default backend pool
  backend_address_pool {
    name = "default-backend-pool"
  }

  # Dynamic backend pools
  dynamic "backend_address_pool" {
    for_each = var.backend_pools
    content {
      name         = backend_address_pool.key
      fqdns        = lookup(backend_address_pool.value, "fqdns", null)
      ip_addresses = lookup(backend_address_pool.value, "ip_addresses", null)
    }
  }

  # Default backend HTTP settings
  backend_http_settings {
    name                  = "default-http-settings"
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 30
  }

  # Dynamic backend HTTP settings
  dynamic "backend_http_settings" {
    for_each = var.backend_http_settings
    content {
      name                                = backend_http_settings.key
      cookie_based_affinity               = lookup(backend_http_settings.value, "cookie_based_affinity", "Disabled")
      port                                = backend_http_settings.value.port
      protocol                            = backend_http_settings.value.protocol
      request_timeout                     = lookup(backend_http_settings.value, "request_timeout", 30)
      probe_name                          = lookup(backend_http_settings.value, "probe_name", null)
      pick_host_name_from_backend_address = lookup(backend_http_settings.value, "pick_host_name_from_backend_address", false)
    }
  }

  # Default HTTP listener
  http_listener {
    name                           = "default-http-listener"
    frontend_ip_configuration_name = "frontend-ip-public"
    frontend_port_name             = "port-80"
    protocol                       = "Http"
  }

  # Dynamic HTTP listeners
  dynamic "http_listener" {
    for_each = var.http_listeners
    content {
      name                           = http_listener.key
      frontend_ip_configuration_name = lookup(http_listener.value, "frontend_ip_configuration_name", "frontend-ip-public")
      frontend_port_name             = http_listener.value.frontend_port_name
      protocol                       = http_listener.value.protocol
      host_name                      = lookup(http_listener.value, "host_name", null)
      ssl_certificate_name           = lookup(http_listener.value, "ssl_certificate_name", null)
    }
  }

  # Default routing rule
  request_routing_rule {
    name                       = "default-routing-rule"
    priority                   = 100
    rule_type                  = "Basic"
    http_listener_name         = "default-http-listener"
    backend_address_pool_name  = var.default_backend_pool_name
    backend_http_settings_name = var.default_backend_http_settings_name
  }

  # Dynamic routing rules
  dynamic "request_routing_rule" {
    for_each = var.routing_rules
    content {
      name                       = request_routing_rule.key
      priority                   = request_routing_rule.value.priority
      rule_type                  = request_routing_rule.value.rule_type
      http_listener_name         = request_routing_rule.value.http_listener_name
      backend_address_pool_name  = lookup(request_routing_rule.value, "backend_address_pool_name", null)
      backend_http_settings_name = lookup(request_routing_rule.value, "backend_http_settings_name", null)
      url_path_map_name          = lookup(request_routing_rule.value, "url_path_map_name", null)
      redirect_configuration_name = lookup(request_routing_rule.value, "redirect_configuration_name", null)
    }
  }

  # Health probes
  dynamic "probe" {
    for_each = var.health_probes
    content {
      name                                      = probe.key
      protocol                                  = probe.value.protocol
      path                                      = probe.value.path
      host                                      = lookup(probe.value, "host", null)
      interval                                  = lookup(probe.value, "interval", 30)
      timeout                                   = lookup(probe.value, "timeout", 30)
      unhealthy_threshold                       = lookup(probe.value, "unhealthy_threshold", 3)
      pick_host_name_from_backend_http_settings = lookup(probe.value, "pick_host_name_from_backend_http_settings", false)
      minimum_servers                           = lookup(probe.value, "minimum_servers", 0)

      dynamic "match" {
        for_each = lookup(probe.value, "match", null) != null ? [probe.value.match] : []
        content {
          status_code = match.value.status_code
          body        = lookup(match.value, "body", null)
        }
      }
    }
  }

  # WAF configuration (for WAF_v2 SKU)
  dynamic "waf_configuration" {
    for_each = var.sku_tier == "WAF_v2" && var.waf_configuration != null ? [var.waf_configuration] : []
    content {
      enabled                  = waf_configuration.value.enabled
      firewall_mode            = waf_configuration.value.firewall_mode
      rule_set_type            = waf_configuration.value.rule_set_type
      rule_set_version         = waf_configuration.value.rule_set_version
      file_upload_limit_mb     = lookup(waf_configuration.value, "file_upload_limit_mb", 100)
      max_request_body_size_kb = lookup(waf_configuration.value, "max_request_body_size_kb", 128)
    }
  }

  # Identity for Key Vault integration
  dynamic "identity" {
    for_each = var.enable_key_vault_integration ? [1] : []
    content {
      type         = "UserAssigned"
      identity_ids = [azurerm_user_assigned_identity.this[0].id]
    }
  }

  tags = var.tags

  # Ignore Azure-side drift for probe configuration (Azure adds port=0 which can't be set explicitly)
  lifecycle {
    ignore_changes = [
      probe
    ]
  }
}

# Diagnostic Settings
resource "azurerm_monitor_diagnostic_setting" "this" {
  count                      = var.enable_diagnostics ? 1 : 0
  name                       = "diag-${azurerm_application_gateway.this.name}"
  target_resource_id         = azurerm_application_gateway.this.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category = "ApplicationGatewayAccessLog"
  }

  enabled_log {
    category = "ApplicationGatewayPerformanceLog"
  }

  enabled_log {
    category = "ApplicationGatewayFirewallLog"
  }

  enabled_metric {
    category = "AllMetrics"
  }
}
