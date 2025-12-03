# =============================================================================
# AKS MODULE - MAIN
# =============================================================================

# Get current Kubernetes version if not specified
data "azurerm_kubernetes_service_versions" "current" {
  location        = var.location
  include_preview = false
}

# AKS Cluster
resource "azurerm_kubernetes_cluster" "this" {
  name                      = var.name
  resource_group_name       = var.resource_group_name
  location                  = var.location
  dns_prefix                = var.dns_prefix
  kubernetes_version        = var.kubernetes_version != null ? var.kubernetes_version : data.azurerm_kubernetes_service_versions.current.latest_version
  sku_tier                  = var.sku_tier
  private_cluster_enabled   = var.private_cluster_enabled
  local_account_disabled    = var.local_account_disabled
  workload_identity_enabled = var.workload_identity_enabled
  oidc_issuer_enabled       = var.oidc_issuer_enabled
  azure_policy_enabled      = var.azure_policy_enabled
  tags                      = var.tags

  # System node pool - smallest possible
  default_node_pool {
    name                 = "system"
    node_count           = var.enable_auto_scaling ? null : var.node_count
    vm_size              = var.vm_size
    os_disk_size_gb      = var.os_disk_size_gb
    vnet_subnet_id       = var.subnet_id
    max_pods             = var.max_pods
    auto_scaling_enabled = var.enable_auto_scaling
    min_count            = var.enable_auto_scaling ? var.min_count : null
    max_count            = var.enable_auto_scaling ? var.max_count : null

    # Cost optimization
    only_critical_addons_enabled = false
  }

  # Use system-assigned managed identity (CAF recommendation)
  identity {
    type = "SystemAssigned"
  }

  # Azure CNI networking (CAF recommendation)
  network_profile {
    network_plugin    = var.network_plugin
    network_policy    = var.network_policy
    service_cidr      = var.service_cidr
    dns_service_ip    = var.dns_service_ip
    load_balancer_sku = "standard"
  }

  # Container Insights (if Log Analytics provided)
  dynamic "oms_agent" {
    for_each = var.log_analytics_workspace_id != null ? [1] : []
    content {
      log_analytics_workspace_id = var.log_analytics_workspace_id
    }
  }

  lifecycle {
    ignore_changes = [
      kubernetes_version,                    # Prevent unintended upgrades
      default_node_pool[0].upgrade_settings, # Provider adds defaults
    ]
  }
}
