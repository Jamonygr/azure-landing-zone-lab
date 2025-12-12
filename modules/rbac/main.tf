# =============================================================================
# RBAC CUSTOM ROLES MODULE
# Custom role definitions for landing zone management
# =============================================================================

data "azurerm_subscription" "current" {}

# =============================================================================
# NETWORK OPERATOR ROLE
# Read VNets, manage NSGs and Route Tables
# =============================================================================

resource "azurerm_role_definition" "network_operator" {
  count       = var.deploy_network_operator_role ? 1 : 0
  name        = "Landing Zone Network Operator"
  scope       = data.azurerm_subscription.current.id
  description = "Can view networks and manage NSGs/Route Tables in the landing zone"

  permissions {
    actions = [
      # Read networking resources
      "Microsoft.Network/virtualNetworks/read",
      "Microsoft.Network/virtualNetworks/subnets/read",
      "Microsoft.Network/virtualNetworks/virtualNetworkPeerings/read",
      "Microsoft.Network/networkInterfaces/read",
      "Microsoft.Network/publicIPAddresses/read",
      "Microsoft.Network/loadBalancers/read",
      "Microsoft.Network/applicationGateways/read",
      "Microsoft.Network/azureFirewalls/read",
      "Microsoft.Network/vpnGateways/read",
      "Microsoft.Network/connections/read",
      
      # Manage NSGs
      "Microsoft.Network/networkSecurityGroups/*",
      
      # Manage Route Tables
      "Microsoft.Network/routeTables/*",
      
      # View Network Watcher and diagnostics
      "Microsoft.Network/networkWatchers/read",
      "Microsoft.Network/networkWatchers/connectionMonitors/read",
      "Microsoft.Network/networkWatchers/flowLogs/read",
      
      # Resource group read
      "Microsoft.Resources/subscriptions/resourceGroups/read"
    ]
    not_actions = []
  }

  assignable_scopes = [data.azurerm_subscription.current.id]
}

# =============================================================================
# BACKUP OPERATOR ROLE
# Manage backup policies and protected items
# =============================================================================

resource "azurerm_role_definition" "backup_operator" {
  count       = var.deploy_backup_operator_role ? 1 : 0
  name        = "Landing Zone Backup Operator"
  scope       = data.azurerm_subscription.current.id
  description = "Can manage backup policies and trigger backup/restore operations"

  permissions {
    actions = [
      # Recovery Services Vault
      "Microsoft.RecoveryServices/Vaults/read",
      "Microsoft.RecoveryServices/Vaults/backupFabrics/protectionContainers/read",
      "Microsoft.RecoveryServices/Vaults/backupFabrics/protectionContainers/protectedItems/*",
      "Microsoft.RecoveryServices/Vaults/backupPolicies/*",
      "Microsoft.RecoveryServices/Vaults/backupJobs/*",
      "Microsoft.RecoveryServices/Vaults/backupUsageSummaries/read",
      "Microsoft.RecoveryServices/Vaults/usages/read",
      
      # Trigger backups
      "Microsoft.RecoveryServices/Vaults/backupFabrics/protectionContainers/protectedItems/backup/action",
      "Microsoft.RecoveryServices/Vaults/backupFabrics/protectionContainers/protectedItems/recoveryPoints/read",
      "Microsoft.RecoveryServices/Vaults/backupFabrics/protectionContainers/protectedItems/recoveryPoints/restore/action",
      
      # Read VMs (for backup association)
      "Microsoft.Compute/virtualMachines/read",
      
      # Resource group read
      "Microsoft.Resources/subscriptions/resourceGroups/read"
    ]
    not_actions = [
      # Cannot delete the vault itself
      "Microsoft.RecoveryServices/Vaults/delete"
    ]
  }

  assignable_scopes = [data.azurerm_subscription.current.id]
}

# =============================================================================
# MONITORING READER ROLE
# View logs, metrics, alerts - no modifications
# =============================================================================

resource "azurerm_role_definition" "monitoring_reader" {
  count       = var.deploy_monitoring_reader_role ? 1 : 0
  name        = "Landing Zone Monitoring Reader"
  scope       = data.azurerm_subscription.current.id
  description = "Can view all monitoring data including logs, metrics, and alerts"

  permissions {
    actions = [
      # Log Analytics
      "Microsoft.OperationalInsights/workspaces/read",
      "Microsoft.OperationalInsights/workspaces/query/read",
      "Microsoft.OperationalInsights/workspaces/analytics/query/action",
      "Microsoft.OperationalInsights/workspaces/search/action",
      
      # Metrics
      "Microsoft.Insights/metrics/read",
      "Microsoft.Insights/metricDefinitions/read",
      "Microsoft.Insights/metricNamespaces/read",
      
      # Alerts
      "Microsoft.Insights/alertRules/read",
      "Microsoft.Insights/scheduledQueryRules/read",
      "Microsoft.Insights/actionGroups/read",
      "Microsoft.AlertsManagement/alerts/read",
      
      # Diagnostic Settings
      "Microsoft.Insights/diagnosticSettings/read",
      "Microsoft.Insights/diagnosticSettingsCategories/read",
      
      # Activity Log
      "Microsoft.Insights/eventtypes/values/read",
      "Microsoft.Insights/activityLogAlerts/read",
      
      # Workbooks
      "Microsoft.Insights/workbooks/read",
      
      # Application Insights (if used)
      "Microsoft.Insights/components/read",
      
      # Resource health
      "Microsoft.ResourceHealth/availabilityStatuses/read",
      
      # Resource group read
      "Microsoft.Resources/subscriptions/resourceGroups/read"
    ]
    not_actions = []
  }

  assignable_scopes = [data.azurerm_subscription.current.id]
}

# =============================================================================
# ROLE ASSIGNMENTS (Optional)
# =============================================================================

resource "azurerm_role_assignment" "network_operator" {
  for_each             = var.deploy_network_operator_role ? toset(var.network_operator_principals) : []
  scope                = data.azurerm_subscription.current.id
  role_definition_id   = azurerm_role_definition.network_operator[0].role_definition_resource_id
  principal_id         = each.value
}

resource "azurerm_role_assignment" "backup_operator" {
  for_each             = var.deploy_backup_operator_role ? toset(var.backup_operator_principals) : []
  scope                = data.azurerm_subscription.current.id
  role_definition_id   = azurerm_role_definition.backup_operator[0].role_definition_resource_id
  principal_id         = each.value
}

resource "azurerm_role_assignment" "monitoring_reader" {
  for_each             = var.deploy_monitoring_reader_role ? toset(var.monitoring_reader_principals) : []
  scope                = data.azurerm_subscription.current.id
  role_definition_id   = azurerm_role_definition.monitoring_reader[0].role_definition_resource_id
  principal_id         = each.value
}
