# =============================================================================
# GOVERNANCE PILLAR
# Management Groups, Azure Policy, Cost Management, Regulatory Compliance, RBAC
# =============================================================================

module "management_groups" {
  source = "../../modules/management-groups"
  count  = var.deploy_management_groups ? 1 : 0

  root_management_group_name = var.management_group_root_name
  root_management_group_id   = var.management_group_root_id
  parent_management_group_id = var.parent_management_group_id

  create_platform_mg       = true
  create_landing_zones_mg  = true
  create_sandbox_mg        = true
  create_decommissioned_mg = true

  subscription_ids_platform_identity     = var.subscription_ids_platform_identity
  subscription_ids_platform_management   = var.subscription_ids_platform_management
  subscription_ids_platform_connectivity = var.subscription_ids_platform_connectivity
  subscription_ids_landing_zones_corp    = var.subscription_ids_landing_zones_corp
  subscription_ids_landing_zones_online  = var.subscription_ids_landing_zones_online
  subscription_ids_sandbox               = var.subscription_ids_sandbox
  subscription_ids_decommissioned        = var.subscription_ids_decommissioned
  additional_management_groups           = var.additional_management_groups
}

module "azure_policy" {
  source = "../../modules/policy"
  count  = var.deploy_azure_policy ? 1 : 0

  scope       = "/subscriptions/${var.subscription_id}"
  location    = var.location
  environment = var.environment

  enable_allowed_locations_policy    = true
  allowed_locations                  = var.policy_allowed_locations
  enable_require_tag_policy          = true
  required_tags                      = var.policy_required_tags
  enable_inherit_tag_policy          = var.enable_inherit_tag_policy
  enable_audit_public_network_access = var.enable_audit_public_network_access
  enable_require_https_storage       = var.enable_require_https_storage
  enable_audit_unattached_disks      = false
  enable_require_nsg_on_subnet       = var.enable_require_nsg_on_subnet
  enable_allowed_vm_skus             = var.enable_allowed_vm_skus
  allowed_vm_skus                    = var.allowed_vm_skus
}

module "cost_management" {
  source = "../../modules/cost-management"
  count  = var.deploy_cost_management ? 1 : 0

  scope               = "/subscriptions/${var.subscription_id}"
  resource_group_name = var.cost_management_resource_group_name
  environment         = var.environment
  location            = var.location

  enable_budget = true
  budget_amount = var.cost_budget_amount
  budget_name   = "monthly-budget"

  enable_action_group = length(var.cost_alert_emails) > 0
  action_group_email_receivers = [for i, email in var.cost_alert_emails : {
    name          = "cost-alert-${i + 1}"
    email_address = email
  }]

  enable_anomaly_alert          = length(var.cost_alert_emails) > 0
  anomaly_alert_email_receivers = var.cost_alert_emails

  tags = var.tags
}

module "regulatory_compliance" {
  source = "../../modules/regulatory-compliance"
  count  = var.deploy_regulatory_compliance ? 1 : 0

  scope       = var.compliance_scope
  location    = var.location
  environment = var.environment

  enable_hipaa             = var.enable_hipaa_compliance
  hipaa_enforcement_mode   = var.compliance_enforcement_mode
  enable_pci_dss           = var.enable_pci_dss_compliance
  pci_dss_enforcement_mode = var.compliance_enforcement_mode

  log_analytics_workspace_id = var.log_analytics_workspace_id
}

module "rbac" {
  source = "../../modules/rbac"
  count  = var.deploy_rbac_custom_roles ? 1 : 0

  deploy_network_operator_role  = true
  deploy_backup_operator_role   = true
  deploy_monitoring_reader_role = true

  network_operator_principals  = var.network_operator_principals
  backup_operator_principals   = var.backup_operator_principals
  monitoring_reader_principals = var.monitoring_reader_principals
}
