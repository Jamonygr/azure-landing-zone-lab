# =============================================================================
# WEB SERVER MODULE - Outputs
# =============================================================================

output "id" {
  description = "The ID of the virtual machine"
  value       = azurerm_windows_virtual_machine.main.id
}

output "name" {
  description = "The name of the virtual machine"
  value       = azurerm_windows_virtual_machine.main.name
}

output "private_ip_address" {
  description = "The private IP address of the VM"
  value       = azurerm_network_interface.main.private_ip_address
}

output "network_interface_id" {
  description = "The ID of the network interface"
  value       = azurerm_network_interface.main.id
}

output "computer_name" {
  description = "The computer name of the VM"
  value       = azurerm_windows_virtual_machine.main.computer_name
}
