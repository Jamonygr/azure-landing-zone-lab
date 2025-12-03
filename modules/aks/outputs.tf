# =============================================================================
# AKS MODULE - OUTPUTS
# =============================================================================

output "id" {
  description = "The ID of the AKS cluster"
  value       = azurerm_kubernetes_cluster.this.id
}

output "name" {
  description = "The name of the AKS cluster"
  value       = azurerm_kubernetes_cluster.this.name
}

output "fqdn" {
  description = "The FQDN of the AKS cluster"
  value       = azurerm_kubernetes_cluster.this.fqdn
}

output "private_fqdn" {
  description = "The private FQDN of the AKS cluster"
  value       = azurerm_kubernetes_cluster.this.private_fqdn
}

output "kube_config" {
  description = "The Kubernetes config for the cluster"
  value       = azurerm_kubernetes_cluster.this.kube_config_raw
  sensitive   = true
}

output "kubelet_identity" {
  description = "The kubelet identity of the AKS cluster"
  value       = azurerm_kubernetes_cluster.this.kubelet_identity
}

output "node_resource_group" {
  description = "The node resource group name"
  value       = azurerm_kubernetes_cluster.this.node_resource_group
}

output "oidc_issuer_url" {
  description = "The OIDC issuer URL"
  value       = azurerm_kubernetes_cluster.this.oidc_issuer_url
}
