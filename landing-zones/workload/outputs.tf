# =============================================================================
# WORKLOAD LANDING ZONE - OUTPUTS
# =============================================================================

output "vnet_id" {
  description = "Workload VNet ID"
  value       = module.workload_vnet.id
}

output "vnet_name" {
  description = "Workload VNet name"
  value       = module.workload_vnet.name
}

output "web_subnet_id" {
  description = "Web tier subnet ID"
  value       = module.web_subnet.id
}

output "app_subnet_id" {
  description = "App tier subnet ID"
  value       = module.app_subnet.id
}

output "data_subnet_id" {
  description = "Data tier subnet ID"
  value       = module.data_subnet.id
}

output "web_nsg_id" {
  description = "Web tier NSG ID"
  value       = module.web_nsg.id
}

output "app_nsg_id" {
  description = "App tier NSG ID"
  value       = module.app_nsg.id
}

output "data_nsg_id" {
  description = "Data tier NSG ID"
  value       = module.data_nsg.id
}

# AKS NSG (only when AKS is deployed)
output "aks_nsg_id" {
  description = "AKS subnet NSG ID"
  value       = var.deploy_aks ? module.aks[0].nsg_id : null
}

# AKS Outputs
output "aks_id" {
  description = "AKS cluster ID"
  value       = var.deploy_aks ? module.aks[0].id : null
}

output "aks_name" {
  description = "AKS cluster name"
  value       = var.deploy_aks ? module.aks[0].name : null
}

output "aks_fqdn" {
  description = "AKS cluster FQDN"
  value       = var.deploy_aks ? module.aks[0].fqdn : null
}

output "aks_kube_config" {
  description = "AKS kubeconfig"
  value       = var.deploy_aks ? module.aks[0].kube_config : null
  sensitive   = true
}

# =============================================================================
# LOAD BALANCER OUTPUTS
# =============================================================================

output "lb_id" {
  description = "Load Balancer ID"
  value       = var.deploy_load_balancer ? module.load_balancer[0].id : null
}

output "lb_frontend_ip" {
  description = "Load Balancer frontend IP address"
  value       = var.deploy_load_balancer ? module.load_balancer[0].frontend_ip_address : null
}

output "lb_backend_pool_id" {
  description = "Load Balancer backend pool ID"
  value       = var.deploy_load_balancer ? module.load_balancer[0].backend_pool_id : null
}

output "web_server_ips" {
  description = "Private IP addresses of web servers"
  value       = var.deploy_load_balancer ? [for ws in module.web_servers : ws.private_ip_address] : []
}

output "web_server_vm_ids" {
  description = "IDs of web server virtual machines"
  value       = var.deploy_load_balancer ? [for ws in module.web_servers : ws.id] : []
}

# =============================================================================
# PAAS SERVICES OUTPUTS
# =============================================================================

# Functions
output "function_app_url" {
  description = "Azure Function App URL"
  value       = var.deploy_functions ? "https://${module.functions[0].function_app_default_hostname}" : null
}

output "function_app_name" {
  description = "Azure Function App name"
  value       = var.deploy_functions ? module.functions[0].function_app_name : null
}

# Static Web App
output "static_web_app_url" {
  description = "Static Web App URL"
  value       = var.deploy_static_web_app ? "https://${module.static_web_app[0].static_web_app_default_hostname}" : null
}

# Logic Apps
output "logic_app_endpoint" {
  description = "Logic App access endpoint"
  value       = var.deploy_logic_apps ? module.logic_apps[0].logic_app_access_endpoint : null
}

# Event Grid
output "event_grid_topic_endpoint" {
  description = "Event Grid topic endpoint"
  value       = var.deploy_event_grid ? module.event_grid[0].custom_topic_endpoint : null
}

# Service Bus
output "service_bus_namespace" {
  description = "Service Bus namespace name"
  value       = var.deploy_service_bus ? module.service_bus[0].namespace_name : null
}

output "service_bus_endpoint" {
  description = "Service Bus endpoint"
  value       = var.deploy_service_bus ? module.service_bus[0].namespace_endpoint : null
}

# App Service
output "app_service_url" {
  description = "App Service URL"
  value       = var.deploy_app_service ? "https://${module.app_service[0].web_app_default_hostname}" : null
}

output "app_service_name" {
  description = "App Service name"
  value       = var.deploy_app_service ? module.app_service[0].web_app_name : null
}

# Cosmos DB
output "cosmos_db_endpoint" {
  description = "Cosmos DB account endpoint"
  value       = var.deploy_cosmos_db ? module.cosmos_db[0].account_endpoint : null
}

output "cosmos_db_name" {
  description = "Cosmos DB account name"
  value       = var.deploy_cosmos_db ? module.cosmos_db[0].account_name : null
}
