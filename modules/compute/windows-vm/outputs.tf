# =============================================================================
# WINDOWS VIRTUAL MACHINE MODULE - OUTPUTS
# =============================================================================

output "id" {
  description = "The ID of the virtual machine"
  value       = azurerm_windows_virtual_machine.this.id
}

output "name" {
  description = "The name of the virtual machine"
  value       = azurerm_windows_virtual_machine.this.name
}

output "private_ip_address" {
  description = "The private IP address of the VM"
  value       = azurerm_network_interface.this.private_ip_address
}

output "public_ip_address" {
  description = "The public IP address of the VM (if enabled)"
  value       = var.enable_public_ip ? azurerm_public_ip.this[0].ip_address : null
}

output "nic_id" {
  description = "The ID of the network interface"
  value       = azurerm_network_interface.this.id
}

output "identity_principal_id" {
  description = "The principal ID of the VM's managed identity"
  value       = azurerm_windows_virtual_machine.this.identity[0].principal_id
}

output "computer_name" {
  description = "The computer name of the VM"
  value       = azurerm_windows_virtual_machine.this.computer_name
}
