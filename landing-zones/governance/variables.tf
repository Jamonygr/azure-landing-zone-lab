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

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
