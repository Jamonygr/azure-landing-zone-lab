# Action Group Outputs

output "action_group_id" {
  description = "The ID of the Action Group"
  value       = azurerm_monitor_action_group.this.id
}

output "action_group_name" {
  description = "The name of the Action Group"
  value       = azurerm_monitor_action_group.this.name
}
