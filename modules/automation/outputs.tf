# =============================================================================
# AZURE AUTOMATION MODULE - OUTPUTS
# =============================================================================

output "automation_account_id" {
  description = "Automation Account ID"
  value       = azurerm_automation_account.automation.id
}

output "automation_account_name" {
  description = "Automation Account name"
  value       = azurerm_automation_account.automation.name
}

output "automation_identity_principal_id" {
  description = "Automation Account Managed Identity Principal ID"
  value       = azurerm_automation_account.automation.identity[0].principal_id
}

output "start_runbook_name" {
  description = "Start VMs Runbook name"
  value       = azurerm_automation_runbook.start_vms.name
}

output "stop_runbook_name" {
  description = "Stop VMs Runbook name"
  value       = azurerm_automation_runbook.stop_vms.name
}

output "start_schedule_id" {
  description = "Start schedule ID"
  value       = var.enable_start_schedule ? azurerm_automation_schedule.start_schedule[0].id : null
}

output "stop_schedule_id" {
  description = "Stop schedule ID"
  value       = var.enable_stop_schedule ? azurerm_automation_schedule.stop_schedule[0].id : null
}
