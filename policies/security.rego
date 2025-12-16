# Security policies for Terraform

package terraform.security

# Deny Key Vaults without soft delete
deny[msg] {
    resource := input.resource_changes[_]
    resource.type == "azurerm_key_vault"
    resource.change.actions[_] == "create"
    resource.change.after.soft_delete_retention_days == null
    msg := sprintf("Key Vault '%s' must have soft delete enabled", [resource.address])
}

# Deny Key Vaults without purge protection in prod
deny[msg] {
    resource := input.resource_changes[_]
    resource.type == "azurerm_key_vault"
    resource.change.actions[_] == "create"
    contains(resource.address, "prod")
    resource.change.after.purge_protection_enabled != true
    msg := sprintf("Production Key Vault '%s' must have purge protection enabled", [resource.address])
}

# Warn on NSG rules allowing all inbound
warn[msg] {
    resource := input.resource_changes[_]
    resource.type == "azurerm_network_security_rule"
    resource.change.actions[_] == "create"
    resource.change.after.direction == "Inbound"
    resource.change.after.source_address_prefix == "*"
    resource.change.after.access == "Allow"
    msg := sprintf("NSG rule '%s' allows inbound from any source", [resource.address])
}

# Deny SQL servers with public network access
deny[msg] {
    resource := input.resource_changes[_]
    resource.type == "azurerm_mssql_server"
    resource.change.actions[_] == "create"
    resource.change.after.public_network_access_enabled == true
    msg := sprintf("SQL Server '%s' should not have public network access", [resource.address])
}

# Warn on VMs without encryption at host
warn[msg] {
    resource := input.resource_changes[_]
    resource.type == "azurerm_windows_virtual_machine"
    resource.change.actions[_] == "create"
    resource.change.after.encryption_at_host_enabled != true
    msg := sprintf("VM '%s' should have encryption at host enabled", [resource.address])
}
