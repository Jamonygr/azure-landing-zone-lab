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


