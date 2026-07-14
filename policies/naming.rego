# Naming convention policies

package terraform.naming

# Check naming convention for resource groups
warn contains msg if {
    resource := input.resource_changes[_]
    resource.type == "azurerm_resource_group"
    resource.change.actions[_] == "create"
    name := resource.change.after.name
    not startswith(name, "rg-")
    msg := sprintf("Resource group '%s' should start with 'rg-'", [name])
}

# Check naming convention for VNets
warn contains msg if {
    resource := input.resource_changes[_]
    resource.type == "azurerm_virtual_network"
    resource.change.actions[_] == "create"
    name := resource.change.after.name
    not startswith(name, "vnet-")
    msg := sprintf("VNet '%s' should start with 'vnet-'", [name])
}

# Check naming convention for subnets
warn contains msg if {
    resource := input.resource_changes[_]
    resource.type == "azurerm_subnet"
    resource.change.actions[_] == "create"
    name := resource.change.after.name
    not startswith(name, "snet-")
    not name == "GatewaySubnet"
    not name == "AzureFirewallSubnet"
    not name == "AzureBastionSubnet"
    msg := sprintf("Subnet '%s' should start with 'snet-' (except reserved names)", [name])
}

# Check naming convention for Key Vaults
warn contains msg if {
    resource := input.resource_changes[_]
    resource.type == "azurerm_key_vault"
    resource.change.actions[_] == "create"
    name := resource.change.after.name
    not startswith(name, "kv-")
    msg := sprintf("Key Vault '%s' should start with 'kv-'", [name])
}
