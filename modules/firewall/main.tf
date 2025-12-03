# =============================================================================
# AZURE FIREWALL MODULE - MAIN
# =============================================================================

locals {
  policy_name = var.policy_name != null ? var.policy_name : "afwp-${var.name}"
}

# Public IP for Azure Firewall
resource "azurerm_public_ip" "this" {
  name                = "pip-${var.name}"
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

# Firewall Policy
resource "azurerm_firewall_policy" "this" {
  name                     = local.policy_name
  resource_group_name      = var.resource_group_name
  location                 = var.location
  sku                      = var.sku_tier
  threat_intelligence_mode = var.threat_intel_mode
  tags                     = var.tags

  dns {
    servers       = length(var.dns_servers) > 0 ? var.dns_servers : null
    proxy_enabled = var.dns_proxy_enabled
  }
}

# Azure Firewall
resource "azurerm_firewall" "this" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  sku_name            = var.sku_name
  sku_tier            = var.sku_tier
  firewall_policy_id  = azurerm_firewall_policy.this.id
  tags                = var.tags

  ip_configuration {
    name                 = "configuration"
    subnet_id            = var.subnet_id
    public_ip_address_id = azurerm_public_ip.this.id
  }
}
