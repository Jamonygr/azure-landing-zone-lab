# =============================================================================
# LOAD BALANCER MODULE - Main Configuration
# =============================================================================

# Public IP for Load Balancer (only if type = public)
resource "azurerm_public_ip" "lb" {
  count               = var.type == "public" ? 1 : 0
  name                = "pip-${var.name}"
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = "Static"
  sku                 = var.sku

  tags = var.tags
}

# Load Balancer
resource "azurerm_lb" "main" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = var.sku

  frontend_ip_configuration {
    name                          = "frontend-ip"
    public_ip_address_id          = var.type == "public" ? azurerm_public_ip.lb[0].id : null
    subnet_id                     = var.type == "internal" ? var.subnet_id : null
    private_ip_address            = var.type == "internal" ? var.private_ip_address : null
    private_ip_address_allocation = var.type == "internal" ? (var.private_ip_address != null ? "Static" : "Dynamic") : null
  }

  tags = var.tags
}

# Backend Address Pool
resource "azurerm_lb_backend_address_pool" "main" {
  name            = var.backend_pool_name
  loadbalancer_id = azurerm_lb.main.id
}

# Health Probes
resource "azurerm_lb_probe" "probes" {
  for_each = var.health_probes

  name                = each.key
  loadbalancer_id     = azurerm_lb.main.id
  protocol            = each.value.protocol
  port                = each.value.port
  request_path        = each.value.protocol == "Http" || each.value.protocol == "Https" ? each.value.request_path : null
  interval_in_seconds = 5
  number_of_probes    = 2
}

# Load Balancing Rules
resource "azurerm_lb_rule" "rules" {
  for_each = var.lb_rules

  name                           = each.key
  loadbalancer_id                = azurerm_lb.main.id
  frontend_ip_configuration_name = "frontend-ip"
  protocol                       = each.value.protocol
  frontend_port                  = each.value.frontend_port
  backend_port                   = each.value.backend_port
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.main.id]
  probe_id                       = azurerm_lb_probe.probes[each.value.probe_name].id
  load_distribution              = each.value.load_distribution
  idle_timeout_in_minutes        = each.value.idle_timeout_in_minutes
  floating_ip_enabled            = false
  disable_outbound_snat          = var.enable_outbound_rule # Disable SNAT when using outbound rules
}

# NAT Rules
resource "azurerm_lb_nat_rule" "nat_rules" {
  for_each = var.nat_rules

  name                           = each.key
  resource_group_name            = var.resource_group_name
  loadbalancer_id                = azurerm_lb.main.id
  frontend_ip_configuration_name = "frontend-ip"
  protocol                       = each.value.protocol
  frontend_port                  = each.value.frontend_port
  backend_port                   = each.value.backend_port
}

# Outbound Rule (for SNAT - only for public LB)
resource "azurerm_lb_outbound_rule" "outbound" {
  count = var.type == "public" && var.enable_outbound_rule ? 1 : 0

  name                     = "outbound-snat"
  loadbalancer_id          = azurerm_lb.main.id
  protocol                 = "All"
  backend_address_pool_id  = azurerm_lb_backend_address_pool.main.id
  allocated_outbound_ports = 1024

  frontend_ip_configuration {
    name = "frontend-ip"
  }
}
