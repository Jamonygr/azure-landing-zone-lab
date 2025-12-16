# =============================================================================
# AZURE AUTOMATION MODULE
# Scheduled Start/Stop for VMs
# =============================================================================

# Calculate a future start time for schedules (tomorrow at 8AM or 7PM)
locals {
  # Get tomorrow's date at the specified time
  base_date           = formatdate("YYYY-MM-DD", timeadd(timestamp(), "24h"))
  start_schedule_time = "${local.base_date}T08:00:00Z"
  stop_schedule_time  = "${local.base_date}T19:00:00Z"
}

# Automation Account
resource "azurerm_automation_account" "automation" {
  name                = var.automation_account_name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku_name            = "Basic"
  tags                = var.tags

  identity {
    type = "SystemAssigned"
  }
}

# Role Assignment for VM Contributor (to start/stop VMs)
resource "azurerm_role_assignment" "vm_contributor" {
  scope                = "/subscriptions/${var.subscription_id}"
  role_definition_name = "Virtual Machine Contributor"
  principal_id         = azurerm_automation_account.automation.identity[0].principal_id
}

# =============================================================================
# RUNBOOKS
# =============================================================================

# Start VMs Runbook
resource "azurerm_automation_runbook" "start_vms" {
  name                    = "Start-LandingZoneVMs"
  location                = var.location
  resource_group_name     = var.resource_group_name
  automation_account_name = azurerm_automation_account.automation.name
  log_verbose             = false
  log_progress            = true
  runbook_type            = "PowerShell"
  tags                    = var.tags

  content = <<-EOT
    <#
    .SYNOPSIS
        Start VMs in specified resource groups
    .DESCRIPTION
        This runbook starts all VMs in the specified resource groups.
        Used for scheduled morning startup of lab VMs.
    #>

    param(
        [Parameter(Mandatory=$false)]
        [string[]]$ResourceGroupNames = @(${join(", ", formatlist("\"%s\"", var.resource_group_names))})
    )

    # Connect using Managed Identity
    try {
        Connect-AzAccount -Identity
    }
    catch {
        Write-Error "Failed to connect with Managed Identity: $_"
        throw
    }

    foreach ($rgName in $ResourceGroupNames) {
        Write-Output "Processing resource group: $rgName"
        
        $vms = Get-AzVM -ResourceGroupName $rgName -ErrorAction SilentlyContinue
        
        foreach ($vm in $vms) {
            $status = (Get-AzVM -ResourceGroupName $rgName -Name $vm.Name -Status).Statuses | 
                      Where-Object { $_.Code -like "PowerState/*" } | 
                      Select-Object -ExpandProperty Code
            
            if ($status -eq "PowerState/deallocated" -or $status -eq "PowerState/stopped") {
                Write-Output "Starting VM: $($vm.Name)"
                Start-AzVM -ResourceGroupName $rgName -Name $vm.Name -NoWait
            }
            else {
                Write-Output "VM $($vm.Name) is already running (Status: $status)"
            }
        }
    }

    Write-Output "VM startup process completed."
  EOT
}

# Stop VMs Runbook
resource "azurerm_automation_runbook" "stop_vms" {
  name                    = "Stop-LandingZoneVMs"
  location                = var.location
  resource_group_name     = var.resource_group_name
  automation_account_name = azurerm_automation_account.automation.name
  log_verbose             = false
  log_progress            = true
  runbook_type            = "PowerShell"
  tags                    = var.tags

  content = <<-EOT
    <#
    .SYNOPSIS
        Stop VMs in specified resource groups
    .DESCRIPTION
        This runbook stops and deallocates all VMs in the specified resource groups.
        Used for scheduled evening shutdown of lab VMs to save costs.
    .PARAMETER ExcludeVMs
        List of VM names to exclude from shutdown (e.g., domain controllers)
    #>

    param(
        [Parameter(Mandatory=$false)]
        [string[]]$ResourceGroupNames = @(${join(", ", formatlist("\"%s\"", var.resource_group_names))}),
        
        [Parameter(Mandatory=$false)]
        [string[]]$ExcludeVMs = @(${join(", ", formatlist("\"%s\"", var.exclude_vms_from_stop))})
    )

    # Connect using Managed Identity
    try {
        Connect-AzAccount -Identity
    }
    catch {
        Write-Error "Failed to connect with Managed Identity: $_"
        throw
    }

    foreach ($rgName in $ResourceGroupNames) {
        Write-Output "Processing resource group: $rgName"
        
        $vms = Get-AzVM -ResourceGroupName $rgName -ErrorAction SilentlyContinue
        
        foreach ($vm in $vms) {
            if ($ExcludeVMs -contains $vm.Name) {
                Write-Output "Skipping excluded VM: $($vm.Name)"
                continue
            }
            
            $status = (Get-AzVM -ResourceGroupName $rgName -Name $vm.Name -Status).Statuses | 
                      Where-Object { $_.Code -like "PowerState/*" } | 
                      Select-Object -ExpandProperty Code
            
            if ($status -eq "PowerState/running") {
                Write-Output "Stopping VM: $($vm.Name)"
                Stop-AzVM -ResourceGroupName $rgName -Name $vm.Name -Force -NoWait
            }
            else {
                Write-Output "VM $($vm.Name) is already stopped (Status: $status)"
            }
        }
    }

    Write-Output "VM shutdown process completed."
  EOT
}

# =============================================================================
# SCHEDULES
# =============================================================================

# Morning Start Schedule (8 AM weekdays)
resource "azurerm_automation_schedule" "start_schedule" {
  count                   = var.enable_start_schedule ? 1 : 0
  name                    = "Schedule-StartVMs-Weekday-Morning"
  resource_group_name     = var.resource_group_name
  automation_account_name = azurerm_automation_account.automation.name
  frequency               = "Week"
  interval                = 1
  timezone                = var.timezone
  start_time              = local.start_schedule_time
  week_days               = var.start_days

  description = "Start VMs every weekday morning at 08:00"

  lifecycle {
    ignore_changes = [start_time]
  }
}

# Evening Stop Schedule (7 PM weekdays)
resource "azurerm_automation_schedule" "stop_schedule" {
  count                   = var.enable_stop_schedule ? 1 : 0
  name                    = "Schedule-StopVMs-Weekday-Evening"
  resource_group_name     = var.resource_group_name
  automation_account_name = azurerm_automation_account.automation.name
  frequency               = "Week"
  interval                = 1
  timezone                = var.timezone
  start_time              = local.stop_schedule_time
  week_days               = var.stop_days

  description = "Stop VMs every weekday evening at 19:00"

  lifecycle {
    ignore_changes = [start_time]
  }
}

# =============================================================================
# SCHEDULE LINKS
# =============================================================================

resource "azurerm_automation_job_schedule" "start_job" {
  count                   = var.enable_start_schedule ? 1 : 0
  resource_group_name     = var.resource_group_name
  automation_account_name = azurerm_automation_account.automation.name
  schedule_name           = azurerm_automation_schedule.start_schedule[0].name
  runbook_name            = azurerm_automation_runbook.start_vms.name
}

resource "azurerm_automation_job_schedule" "stop_job" {
  count                   = var.enable_stop_schedule ? 1 : 0
  resource_group_name     = var.resource_group_name
  automation_account_name = azurerm_automation_account.automation.name
  schedule_name           = azurerm_automation_schedule.stop_schedule[0].name
  runbook_name            = azurerm_automation_runbook.stop_vms.name
}
