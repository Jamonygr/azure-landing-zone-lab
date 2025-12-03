# =============================================================================
# AKS MODULE - VARIABLES
# =============================================================================

variable "name" {
  description = "AKS cluster name"
  type        = string
}

variable "resource_group_name" {
  description = "Resource group name"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "dns_prefix" {
  description = "DNS prefix for the cluster"
  type        = string
}

variable "kubernetes_version" {
  description = "Kubernetes version"
  type        = string
  default     = null # Uses latest stable if not specified
}

variable "sku_tier" {
  description = "AKS SKU tier (Free or Standard)"
  type        = string
  default     = "Free"
}

variable "private_cluster_enabled" {
  description = "Enable private cluster"
  type        = bool
  default     = false
}

variable "subnet_id" {
  description = "Subnet ID for AKS nodes"
  type        = string
}

variable "node_count" {
  description = "Number of nodes in system pool"
  type        = number
  default     = 1
}

variable "vm_size" {
  description = "VM size for system node pool"
  type        = string
  default     = "Standard_B2s"
}

variable "os_disk_size_gb" {
  description = "OS disk size in GB"
  type        = number
  default     = 30
}

variable "max_pods" {
  description = "Maximum pods per node"
  type        = number
  default     = 30
}

variable "enable_auto_scaling" {
  description = "Enable auto-scaling"
  type        = bool
  default     = false
}

variable "min_count" {
  description = "Minimum node count for auto-scaling"
  type        = number
  default     = 1
}

variable "max_count" {
  description = "Maximum node count for auto-scaling"
  type        = number
  default     = 3
}

variable "network_plugin" {
  description = "Network plugin (azure or kubenet)"
  type        = string
  default     = "azure"
}

variable "network_policy" {
  description = "Network policy (azure, calico, or null)"
  type        = string
  default     = "azure"
}

variable "service_cidr" {
  description = "Service CIDR for Kubernetes services"
  type        = string
  default     = "172.16.0.0/16"
}

variable "dns_service_ip" {
  description = "DNS service IP (must be within service_cidr)"
  type        = string
  default     = "172.16.0.10"
}

variable "log_analytics_workspace_id" {
  description = "Log Analytics workspace ID for Container Insights"
  type        = string
  default     = null
}

variable "azure_policy_enabled" {
  description = "Enable Azure Policy add-on"
  type        = bool
  default     = false
}

variable "local_account_disabled" {
  description = "Disable local Kubernetes accounts"
  type        = bool
  default     = false # Set to true for production
}

variable "workload_identity_enabled" {
  description = "Enable workload identity"
  type        = bool
  default     = true
}

variable "oidc_issuer_enabled" {
  description = "Enable OIDC issuer for workload identity"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags to apply"
  type        = map(string)
  default     = {}
}
