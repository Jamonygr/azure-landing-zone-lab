# =============================================================================
# GOVERNANCE PILLAR - VARIABLES
# Management groups, policy, cost management, regulatory compliance, RBAC
# =============================================================================

variable "subscription_id" {
  description = "Subscription ID"
  type        = string
}

variable "location" {
  description = "Azure region for policy assignments"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

# -----------------------------------------------------------------------------
# Management Groups
# -----------------------------------------------------------------------------

variable "deploy_management_groups" {
  description = "Deploy management groups hierarchy"
  type        = bool
}

variable "management_group_root_name" {
  description = "Root management group display name"
  type        = string
}

variable "management_group_root_id" {
  description = "Root management group ID"
  type        = string
}

variable "parent_management_group_id" {
  description = "Parent management group ID (optional)"
  type        = string
  default     = null
}

variable "subscription_ids_platform_identity" {
  description = "Subscriptions under Platform > Identity"
  type        = list(string)
  default     = []
}

variable "subscription_ids_platform_management" {
  description = "Subscriptions under Platform > Management"
  type        = list(string)
  default     = []
}

variable "subscription_ids_platform_connectivity" {
  description = "Subscriptions under Platform > Connectivity"
  type        = list(string)
  default     = []
}

variable "subscription_ids_landing_zones_corp" {
  description = "Subscriptions under Landing Zones > Corp"
  type        = list(string)
  default     = []
}

variable "subscription_ids_landing_zones_online" {
  description = "Subscriptions under Landing Zones > Online"
  type        = list(string)
  default     = []
}

variable "subscription_ids_sandbox" {
  description = "Subscriptions under Sandbox"
  type        = list(string)
  default     = []
}

variable "subscription_ids_decommissioned" {
  description = "Subscriptions under Decommissioned"
  type        = list(string)
  default     = []
}

variable "additional_management_groups" {
  description = "Additional management groups definitions"
  type = list(object({
    name             = string
    display_name     = string
    subscription_ids = optional(list(string), [])
  }))
  default = []
}

# -----------------------------------------------------------------------------
# Policy
# -----------------------------------------------------------------------------

variable "deploy_azure_policy" {
  description = "Deploy Azure Policy assignments"
  type        = bool
}

variable "policy_allowed_locations" {
  description = "Allowed locations for policy"
  type        = list(string)
}

variable "policy_required_tags" {
  description = "Required tags map"
  type        = map(string)
}

variable "enable_inherit_tag_policy" {
  description = "Enable inherit tag policy"
  type        = bool
  default     = false
}

variable "enable_audit_public_network_access" {
  description = "Enable audit public network access policy"
  type        = bool
}

variable "enable_require_https_storage" {
  description = "Enable HTTPS required for storage policy"
  type        = bool
}

variable "enable_require_nsg_on_subnet" {
  description = "Enable NSG required on subnet policy"
  type        = bool
}

variable "enable_allowed_vm_skus" {
  description = "Enable allowed VM SKUs policy"
  type        = bool
  default     = false
}

variable "allowed_vm_skus" {
  description = "List of allowed VM SKUs"
  type        = list(string)
  default     = []
}

# -----------------------------------------------------------------------------
# Cost Management
# -----------------------------------------------------------------------------

variable "deploy_cost_management" {
  description = "Deploy cost management budget/alerts"
  type        = bool
}

variable "cost_management_resource_group_name" {
  description = "Resource group for cost management action group"
  type        = string
}

variable "cost_budget_amount" {
  description = "Monthly budget amount (USD)"
  type        = number
}

variable "cost_alert_emails" {
  description = "Emails for cost alerts"
  type        = list(string)
}

# -----------------------------------------------------------------------------
# Regulatory Compliance
# -----------------------------------------------------------------------------

variable "deploy_regulatory_compliance" {
  description = "Deploy regulatory compliance initiatives"
  type        = bool
}

variable "enable_hipaa_compliance" {
  description = "Enable HIPAA policy initiative"
  type        = bool
}

variable "enable_pci_dss_compliance" {
  description = "Enable PCI-DSS policy initiative"
  type        = bool
}

variable "compliance_enforcement_mode" {
  description = "Enforcement mode for compliance policies"
  type        = string
}

variable "log_analytics_workspace_id" {
  description = "Log Analytics workspace ID (for compliance logging)"
  type        = string
  default     = null
}

variable "compliance_scope" {
  description = "Scope for compliance initiatives (e.g., workload RG ID)"
  type        = string
}

# -----------------------------------------------------------------------------
# RBAC custom roles
# -----------------------------------------------------------------------------

variable "deploy_rbac_custom_roles" {
  description = "Deploy custom RBAC roles"
  type        = bool
}

variable "network_operator_principals" {
  description = "Principal IDs for Network Operator role assignment"
  type        = list(string)
  default     = []
}

variable "backup_operator_principals" {
  description = "Principal IDs for Backup Operator role assignment"
  type        = list(string)
  default     = []
}

variable "monitoring_reader_principals" {
  description = "Principal IDs for Monitoring Reader role assignment"
  type        = list(string)
  default     = []
}

# -----------------------------------------------------------------------------
# Monitoring
# -----------------------------------------------------------------------------

variable "deploy_monitoring" {
  description = "Deploy monitoring resources (Log Analytics, Action Groups, Alerts, etc.)"
  type        = bool
  default     = false
}

variable "monitoring_resource_group_name" {
  description = "Resource group for monitoring resources"
  type        = string
  default     = ""
}

variable "log_analytics_workspace_name" {
  description = "Name for the Log Analytics Workspace"
  type        = string
  default     = "law-governance"
}

variable "log_analytics_sku" {
  description = "SKU for Log Analytics Workspace"
  type        = string
  default     = "PerGB2018"
}

variable "log_analytics_retention_days" {
  description = "Log Analytics data retention in days"
  type        = number
  default     = 30
}

variable "log_analytics_daily_quota_gb" {
  description = "Daily ingestion quota in GB (-1 for unlimited)"
  type        = number
  default     = 1
}

variable "monitoring_alert_emails" {
  description = "Email addresses for monitoring alerts"
  type        = list(string)
  default     = []
}

variable "monitoring_sms_receivers" {
  description = "SMS receivers for alerts"
  type = list(object({
    name         = string
    country_code = string
    phone_number = string
  }))
  default = []
}

variable "monitoring_webhook_receivers" {
  description = "Webhook receivers for alerts"
  type = list(object({
    name                    = string
    service_uri             = string
    use_common_alert_schema = optional(bool, true)
  }))
  default = []
}

variable "deploy_monitoring_alerts" {
  description = "Deploy metric alerts"
  type        = bool
  default     = false
}

variable "monitoring_alerts_enabled" {
  description = "Whether monitoring alerts are enabled"
  type        = bool
  default     = true
}

variable "external_action_group_id" {
  description = "External action group ID (if not creating one)"
  type        = string
  default     = ""
}

variable "external_log_analytics_workspace_id" {
  description = "External Log Analytics Workspace ID (if not creating one)"
  type        = string
  default     = ""
}

# VM Monitoring
variable "enable_vm_alerts" {
  description = "Enable VM metric alerts"
  type        = bool
  default     = false
}

variable "monitored_vm_ids" {
  description = "List of VM resource IDs to monitor"
  type        = list(string)
  default     = []
}

variable "vm_cpu_alert_threshold" {
  description = "CPU percentage threshold for VM alerts"
  type        = number
  default     = 80
}

variable "vm_memory_alert_threshold_bytes" {
  description = "Memory threshold in bytes for VM alerts"
  type        = number
  default     = 1073741824
}

variable "vm_disk_iops_threshold" {
  description = "Disk IOPS threshold for VM alerts"
  type        = number
  default     = 500
}

variable "vm_network_threshold_bytes" {
  description = "Network threshold in bytes for VM alerts"
  type        = number
  default     = 1073741824
}

# AKS Monitoring
variable "enable_aks_alerts" {
  description = "Enable AKS metric alerts"
  type        = bool
  default     = false
}

variable "monitored_aks_cluster_id" {
  description = "AKS cluster resource ID to monitor"
  type        = string
  default     = ""
}

variable "aks_cpu_alert_threshold" {
  description = "CPU percentage threshold for AKS alerts"
  type        = number
  default     = 80
}

variable "aks_memory_alert_threshold" {
  description = "Memory percentage threshold for AKS alerts"
  type        = number
  default     = 80
}

variable "aks_min_node_count" {
  description = "Minimum node count threshold for AKS alerts"
  type        = number
  default     = 1
}

variable "aks_pending_pods_threshold" {
  description = "Pending pods threshold for AKS alerts"
  type        = number
  default     = 5
}

# SQL Monitoring
variable "enable_sql_alerts" {
  description = "Enable SQL metric alerts"
  type        = bool
  default     = false
}

variable "monitored_sql_database_id" {
  description = "SQL Database resource ID to monitor"
  type        = string
  default     = ""
}

variable "sql_dtu_alert_threshold" {
  description = "DTU percentage threshold for SQL alerts"
  type        = number
  default     = 80
}

variable "sql_storage_alert_threshold" {
  description = "Storage percentage threshold for SQL alerts"
  type        = number
  default     = 80
}

variable "sql_failed_connections_threshold" {
  description = "Failed connections threshold for SQL alerts"
  type        = number
  default     = 5
}

# Firewall Monitoring
variable "enable_firewall_alerts" {
  description = "Enable Firewall metric alerts"
  type        = bool
  default     = false
}

variable "monitored_firewall_id" {
  description = "Azure Firewall resource ID to monitor"
  type        = string
  default     = ""
}

variable "firewall_health_threshold" {
  description = "Health percentage threshold for Firewall alerts"
  type        = number
  default     = 90
}

variable "firewall_throughput_threshold" {
  description = "Throughput threshold in bytes/sec for Firewall alerts"
  type        = number
  default     = 1073741824
}

# VPN Gateway Monitoring
variable "enable_vpn_alerts" {
  description = "Enable VPN Gateway metric alerts"
  type        = bool
  default     = false
}

variable "monitored_vpn_gateway_id" {
  description = "VPN Gateway resource ID to monitor"
  type        = string
  default     = ""
}

variable "vpn_bandwidth_threshold" {
  description = "Bandwidth threshold in bytes/sec for VPN alerts"
  type        = number
  default     = 104857600
}

# Diagnostic Settings
variable "deploy_diagnostic_settings" {
  description = "Deploy diagnostic settings"
  type        = bool
  default     = false
}

variable "enable_firewall_diagnostics" {
  description = "Enable Firewall diagnostic settings"
  type        = bool
  default     = false
}

variable "enable_vpn_diagnostics" {
  description = "Enable VPN Gateway diagnostic settings"
  type        = bool
  default     = false
}

variable "enable_aks_diagnostics" {
  description = "Enable AKS diagnostic settings"
  type        = bool
  default     = false
}

variable "enable_sql_diagnostics" {
  description = "Enable SQL diagnostic settings"
  type        = bool
  default     = false
}

variable "monitored_sql_server_id" {
  description = "SQL Server resource ID for diagnostics"
  type        = string
  default     = ""
}

variable "enable_keyvault_diagnostics" {
  description = "Enable Key Vault diagnostic settings"
  type        = bool
  default     = false
}

variable "monitored_keyvault_id" {
  description = "Key Vault resource ID for diagnostics"
  type        = string
  default     = ""
}

variable "enable_storage_diagnostics" {
  description = "Enable Storage Account diagnostic settings"
  type        = bool
  default     = false
}

variable "monitored_storage_account_id" {
  description = "Storage Account resource ID for diagnostics"
  type        = string
  default     = ""
}

variable "enable_nsg_diagnostics" {
  description = "Enable NSG diagnostic settings"
  type        = bool
  default     = false
}

variable "monitored_nsg_ids" {
  description = "List of NSG resource IDs for diagnostics"
  type        = list(string)
  default     = []
}

# Workbooks
variable "deploy_workbooks" {
  description = "Deploy Azure Monitor Workbooks"
  type        = bool
  default     = false
}

variable "deploy_vm_workbook" {
  description = "Deploy VM Performance workbook"
  type        = bool
  default     = true
}

variable "deploy_network_workbook" {
  description = "Deploy Network Traffic workbook"
  type        = bool
  default     = true
}

variable "deploy_firewall_workbook" {
  description = "Deploy Firewall Analytics workbook"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
