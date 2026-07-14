mock_provider "azurerm" {
  mock_data "azurerm_client_config" {
    defaults = {
      object_id = "33333333-3333-4333-8333-333333333333"
    }
  }
}
mock_provider "time" {}

run "automation_uses_configured_times" {
  command = plan

  module {
    source = "./modules/automation"
  }

  variables {
    automation_account_name = "aa-test"
    location                = "West Europe"
    resource_group_name     = "rg-test"
    subscription_id         = "11111111-1111-4111-8111-111111111111"
    start_time              = "06:30"
    stop_time               = "21:15"
  }

  override_resource {
    target          = time_static.schedule_anchor
    override_during = plan
    values = {
      rfc3339 = "2026-07-14T00:00:00Z"
    }
  }

  assert {
    condition     = azurerm_automation_schedule.start_schedule[0].start_time == "2026-07-15T06:30:00Z"
    error_message = "The start schedule must use the configured start_time."
  }

  assert {
    condition     = azurerm_automation_schedule.stop_schedule[0].start_time == "2026-07-15T21:15:00Z"
    error_message = "The stop schedule must use the configured stop_time."
  }
}

run "route_table_honors_bgp_switch" {
  command = plan

  module {
    source = "./modules/networking/route-table"
  }

  variables {
    name                          = "rt-test"
    resource_group_name           = "rg-test"
    location                      = "West Europe"
    disable_bgp_route_propagation = true
  }

  assert {
    condition     = !azurerm_route_table.this.bgp_route_propagation_enabled
    error_message = "disable_bgp_route_propagation must disable Azure BGP route propagation."
  }
}

run "subnet_honors_private_endpoint_policy_switch" {
  command = plan

  module {
    source = "./modules/networking/subnet"
  }

  variables {
    name                                      = "snet-test"
    resource_group_name                       = "rg-test"
    virtual_network_name                      = "vnet-test"
    address_prefixes                          = ["10.0.1.0/24"]
    private_endpoint_network_policies_enabled = false
  }

  assert {
    condition     = azurerm_subnet.this.private_endpoint_network_policies == "Disabled"
    error_message = "The subnet module must map the compatibility boolean to the provider policy value."
  }
}

run "keyvault_role_is_created_only_for_managed_secrets" {
  command = plan

  module {
    source = "./modules/keyvault"
  }

  variables {
    name                = "kv-test"
    resource_group_name = "rg-test"
    location            = "West Europe"
    tenant_id           = "44444444-4444-4444-8444-444444444444"
    create_secrets      = true
    secrets = {
      sample = {
        value = "test-only"
      }
    }
  }

  assert {
    condition     = length(azurerm_role_assignment.keyvault_admin) == 1
    error_message = "A Secrets Officer role is required when Terraform manages Key Vault secrets."
  }
}

run "regulatory_remediation_roles_default_to_none" {
  command = plan

  module {
    source = "./modules/regulatory-compliance"
  }

  variables {
    scope        = "/subscriptions/11111111-1111-4111-8111-111111111111/resourceGroups/rg-test"
    location     = "West Europe"
    environment  = "lab"
    enable_hipaa = true
  }

  assert {
    condition     = length(azurerm_role_assignment.hipaa_remediation) == 0
    error_message = "Regulatory initiatives must not receive broad remediation roles by default."
  }
}
