# =============================================================================
# LOAD BALANCER MODULE - Outputs
# =============================================================================

output "id" {
  description = "The ID of the load balancer"
  value       = azurerm_lb.main.id
}

output "name" {
  description = "The name of the load balancer"
  value       = azurerm_lb.main.name
}

output "frontend_ip_address" {
  description = "The frontend IP address of the load balancer"
  value       = var.type == "public" ? azurerm_public_ip.lb[0].ip_address : azurerm_lb.main.frontend_ip_configuration[0].private_ip_address
}

output "public_ip_id" {
  description = "The ID of the public IP (null if internal)"
  value       = var.type == "public" ? azurerm_public_ip.lb[0].id : null
}

output "backend_pool_id" {
  description = "The ID of the backend address pool"
  value       = azurerm_lb_backend_address_pool.main.id
}

output "backend_pool_name" {
  description = "The name of the backend address pool"
  value       = azurerm_lb_backend_address_pool.main.name
}

output "nat_rule_ids" {
  description = "Map of NAT rule names to their IDs"
  value       = { for k, v in azurerm_lb_nat_rule.nat_rules : k => v.id }
}

output "health_probe_ids" {
  description = "Map of health probe names to their IDs"
  value       = { for k, v in azurerm_lb_probe.probes : k => v.id }
}
