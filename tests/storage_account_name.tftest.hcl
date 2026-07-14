mock_provider "azurerm" {
  mock_data "azurerm_client_config" {
    defaults = {
      client_id       = "22222222-2222-2222-2222-222222222222"
      object_id       = "33333333-3333-3333-3333-333333333333"
      subscription_id = "11111111-1111-4111-8111-111111111111"
      tenant_id       = "44444444-4444-4444-4444-444444444444"
    }
  }

  mock_data "azurerm_subscription" {
    defaults = {
      display_name    = "Mock Subscription"
      id              = "/subscriptions/11111111-1111-4111-8111-111111111111"
      subscription_id = "11111111-1111-4111-8111-111111111111"
      tenant_id       = "44444444-4444-4444-4444-444444444444"
    }
  }
}
mock_provider "azapi" {}
mock_provider "random" {}
mock_provider "time" {}

variables {
  subscription_id = "11111111-1111-4111-8111-111111111111"
  project         = "azlab"

  allowed_jumpbox_source_ips = []

  deploy_firewall            = false
  deploy_vpn_gateway         = false
  deploy_application_gateway = false
  deploy_nat_gateway         = false
  deploy_load_balancer       = false

  deploy_workload_prod     = false
  deploy_workload_dev      = false
  deploy_onprem_simulation = false
  deploy_secondary_dc      = false
  deploy_aks               = false
  deploy_container_apps    = false

  deploy_keyvault          = false
  deploy_storage           = false
  deploy_sql               = false
  deploy_private_endpoints = false
  deploy_private_dns_zones = false

  deploy_functions      = false
  deploy_static_web_app = false
  deploy_logic_apps     = false
  deploy_event_grid     = false
  deploy_service_bus    = false
  deploy_app_service    = false
  deploy_cosmos_db      = false

  deploy_log_analytics      = false
  deploy_workbooks          = false
  deploy_connection_monitor = false
  deploy_cost_management    = false
  deploy_backup             = false
  enable_vnet_flow_logs     = false
  enable_traffic_analytics  = false

  deploy_azure_policy          = false
  deploy_management_groups     = false
  deploy_rbac_custom_roles     = false
  deploy_regulatory_compliance = false
  enable_scheduled_startstop   = false
}

run "cheap_lab_storage_name_is_sanitized" {
  command = plan

  variables {
    environment = "cheap-lab"
  }

  assert {
    condition     = local.storage_account_name_prefix == "stazlabcheaplab"
    error_message = "The cheap-lab storage account prefix must remove the environment hyphen before appending the suffix."
  }

  assert {
    condition     = random_string.suffix.length == 4 && !random_string.suffix.special && !random_string.suffix.upper
    error_message = "The storage account suffix must remain four lowercase alphanumeric characters."
  }
}

run "lab_storage_name_is_stable" {
  command = plan

  variables {
    environment = "lab"
  }

  assert {
    condition     = local.storage_account_name_prefix == "stazlablab"
    error_message = "The existing lab storage account naming pattern must remain unchanged."
  }

  assert {
    condition     = !contains(keys(local.common_tags), "Repository")
    error_message = "The Repository tag must be omitted when repository_url is null."
  }
}

run "private_endpoints_require_private_dns" {
  command = plan

  variables {
    environment              = "lab"
    deploy_private_endpoints = true
    deploy_private_dns_zones = false
  }

  expect_failures = [var.deploy_private_endpoints]
}

run "environment_profile_is_validated" {
  command = plan

  variables {
    environment = "production"
  }

  expect_failures = [var.environment]
}

run "waf_mode_is_validated" {
  command = plan

  variables {
    environment    = "lab"
    appgw_waf_mode = "Monitor"
  }

  expect_failures = [var.appgw_waf_mode]
}
