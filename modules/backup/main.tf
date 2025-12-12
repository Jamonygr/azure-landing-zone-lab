# =============================================================================
# AZURE BACKUP MODULE
# Recovery Services Vault with backup policies
# =============================================================================

resource "azurerm_recovery_services_vault" "vault" {
  name                = var.vault_name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "Standard"
  soft_delete_enabled = var.soft_delete_enabled
  storage_mode_type   = var.storage_mode_type
  tags                = var.tags
}

# =============================================================================
# BACKUP POLICIES
# =============================================================================

# Standard VM Backup Policy (Daily with 7 day retention)
resource "azurerm_backup_policy_vm" "daily" {
  name                = "${var.policy_name_prefix}-daily"
  resource_group_name = var.resource_group_name
  recovery_vault_name = azurerm_recovery_services_vault.vault.name

  timezone = var.timezone

  backup {
    frequency = "Daily"
    time      = var.backup_time
  }

  retention_daily {
    count = var.daily_retention_days
  }

  retention_weekly {
    count    = var.weekly_retention_weeks
    weekdays = ["Sunday"]
  }

  retention_monthly {
    count    = var.monthly_retention_months
    weekdays = ["Sunday"]
    weeks    = ["First"]
  }
}

# Critical VM Backup Policy (Daily with longer retention)
resource "azurerm_backup_policy_vm" "critical" {
  name                = "${var.policy_name_prefix}-critical"
  resource_group_name = var.resource_group_name
  recovery_vault_name = azurerm_recovery_services_vault.vault.name

  timezone = var.timezone

  backup {
    frequency = "Daily"
    time      = var.backup_time
  }

  retention_daily {
    count = 14
  }

  retention_weekly {
    count    = 4
    weekdays = ["Sunday"]
  }

  retention_monthly {
    count    = 6
    weekdays = ["Sunday"]
    weeks    = ["First"]
  }

  retention_yearly {
    count    = 1
    weekdays = ["Sunday"]
    weeks    = ["First"]
    months   = ["January"]
  }
}

# =============================================================================
# VM BACKUP PROTECTION
# =============================================================================

resource "azurerm_backup_protected_vm" "protected_vms" {
  for_each = { for vm in var.protected_vms : vm.name => vm }

  resource_group_name = var.resource_group_name
  recovery_vault_name = azurerm_recovery_services_vault.vault.name
  source_vm_id        = each.value.id
  backup_policy_id    = each.value.critical ? azurerm_backup_policy_vm.critical.id : azurerm_backup_policy_vm.daily.id
}
