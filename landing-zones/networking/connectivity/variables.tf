# =============================================================================
# NETWORKING CONNECTIVITY (Phase 2)
# Peering, flow logs, NAT, ASGs, App Gateway diagnostics/backends
# =============================================================================

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "location_short" {
  description = "Region short code"
  type        = string
}

variable "tags" {
  description = "Common tags"
  type        = map(string)
}

variable "hub_resource_group_name" {
  description = "Hub resource group name"
  type        = string
}

variable "hub_vnet_id" {
  description = "Hub VNet ID"
  type        = string
}

variable "hub_vnet_name" {
  description = "Hub VNet name"
  type        = string
}

variable "deploy_vpn_gateway" {
  description = "Deploy VPN gateway (controls gateway transit flags)"
  type        = bool
}

variable "identity_vnet_id" {
  description = "Identity VNet ID"
  type        = string
}

variable "identity_vnet_name" {
  description = "Identity VNet name"
  type        = string
}

variable "identity_resource_group_name" {
  description = "Identity resource group name"
  type        = string
}

variable "management_vnet_id" {
  description = "Management VNet ID"
  type        = string
}

variable "management_vnet_name" {
  description = "Management VNet name"
  type        = string
}

variable "management_resource_group_name" {
  description = "Management resource group name"
  type        = string
}

variable "shared_vnet_id" {
  description = "Shared services VNet ID"
  type        = string
}

variable "shared_vnet_name" {
  description = "Shared services VNet name"
  type        = string
}

variable "shared_resource_group_name" {
  description = "Shared services resource group name"
  type        = string
}

variable "workload_prod_vnet_id" {
  description = "Workload prod VNet ID"
  type        = string
  default     = null
}

variable "workload_prod_vnet_name" {
  description = "Workload prod VNet name"
  type        = string
  default     = null
}

variable "workload_prod_resource_group_name" {
  description = "Workload prod resource group name"
  type        = string
  default     = null
}

variable "workload_dev_vnet_id" {
  description = "Workload dev VNet ID"
  type        = string
  default     = null
}

variable "workload_dev_vnet_name" {
  description = "Workload dev VNet name"
  type        = string
  default     = null
}

variable "workload_dev_resource_group_name" {
  description = "Workload dev resource group name"
  type        = string
  default     = null
}

variable "deploy_workload_prod" {
  description = "Whether prod workload is deployed"
  type        = bool
}

variable "deploy_workload_dev" {
  description = "Whether dev workload is deployed"
  type        = bool
}

# -----------------------------------------------------------------------------
# Flow logs
# -----------------------------------------------------------------------------

variable "enable_vnet_flow_logs" {
  description = "Enable VNet flow logs"
  type        = bool
}

variable "storage_account_id" {
  description = "Storage account ID for flow logs"
  type        = string
}

variable "create_network_watcher" {
  description = "Create Network Watcher if missing"
  type        = bool
}

variable "network_watcher_name" {
  description = "Existing Network Watcher name (optional)"
  type        = string
  default     = null
}

variable "nsg_flow_logs_retention_days" {
  description = "Flow logs retention days"
  type        = number
}

variable "enable_traffic_analytics" {
  description = "Enable traffic analytics"
  type        = bool
}

variable "log_analytics_workspace_id" {
  description = "Log Analytics workspace ID"
  type        = string
  default     = null
}

variable "log_analytics_workspace_guid" {
  description = "Log Analytics workspace GUID"
  type        = string
  default     = null
}

# -----------------------------------------------------------------------------
# NAT and ASGs (workload)
# -----------------------------------------------------------------------------

variable "deploy_nat_gateway" {
  description = "Deploy NAT gateway for workload web subnet"
  type        = bool
}

variable "workload_web_subnet_id" {
  description = "Workload web subnet ID"
  type        = string
  default     = null
}

variable "workload_resource_group_name" {
  description = "Workload resource group name (prod)"
  type        = string
  default     = null
}

variable "deploy_application_security_groups" {
  description = "Deploy ASGs for workload tiers"
  type        = bool
}

# -----------------------------------------------------------------------------
# App Gateway integration
# -----------------------------------------------------------------------------

variable "deploy_application_gateway" {
  description = "Whether app gateway is deployed"
  type        = bool
}

variable "enable_appgw_diagnostics" {
  description = "Enable App Gateway diagnostics (use boolean instead of checking workspace_id)"
  type        = bool
  default     = false
}

variable "application_gateway_name" {
  description = "Application gateway name"
  type        = string
  default     = null
}

variable "application_gateway_id" {
  description = "Application gateway ID"
  type        = string
  default     = null
}

variable "appgw_backend_ips" {
  description = "Backend IPs for app gateway pool"
  type        = list(string)
  default     = []
}
