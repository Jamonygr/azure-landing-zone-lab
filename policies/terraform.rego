# OPA Policies for Terraform
# These policies are evaluated against terraform plan JSON output

package terraform

# Deny resources without required tags
deny[msg] {
    resource := input.resource_changes[_]
    resource.change.actions[_] == "create"
    not resource.change.after.tags
    msg := sprintf("Resource '%s' must have tags", [resource.address])
}

# Warn on public IP creation
warn[msg] {
    resource := input.resource_changes[_]
    resource.type == "azurerm_public_ip"
    resource.change.actions[_] == "create"
    msg := sprintf("Public IP '%s' is being created - ensure this is intentional", [resource.address])
}

# Deny storage accounts with public access
deny[msg] {
    resource := input.resource_changes[_]
    resource.type == "azurerm_storage_account"
    resource.change.actions[_] == "create"
    resource.change.after.allow_nested_items_to_be_public == true
    msg := sprintf("Storage account '%s' should not allow public access to blobs", [resource.address])
}

# Warn on large VM sizes (cost control)
warn[msg] {
    resource := input.resource_changes[_]
    resource.type == "azurerm_virtual_machine"
    resource.change.actions[_] == "create"
    contains(resource.change.after.vm_size, "Standard_D")
    not contains(resource.change.after.vm_size, "s_v")
    msg := sprintf("VM '%s' uses size '%s' - consider a smaller size for lab", [resource.address, resource.change.after.vm_size])
}

# Deny resources in non-approved regions
approved_regions := ["westus2", "eastus", "eastus2", "centralus"]

deny[msg] {
    resource := input.resource_changes[_]
    resource.change.actions[_] == "create"
    location := resource.change.after.location
    location != null
    not array_contains(approved_regions, location)
    msg := sprintf("Resource '%s' in region '%s' - only %v are approved", [resource.address, location, approved_regions])
}

# Helper function
array_contains(arr, elem) {
    arr[_] == elem
}
