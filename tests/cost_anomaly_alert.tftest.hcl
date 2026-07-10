mock_provider "azurerm" {}

run "cost_anomaly_message_meets_azure_limit" {
  command = plan

  module {
    source = "./modules/cost-management"
  }

  variables {
    scope                         = "/subscriptions/11111111-1111-1111-1111-111111111111"
    environment                   = "cheap-lab"
    resource_group_name           = "rg-management-cheap-lab-wus2"
    enable_budget                 = false
    enable_action_group           = false
    enable_anomaly_alert          = true
    anomaly_alert_email_receivers = ["alerts@example.com"]
  }

  assert {
    condition     = length(trimspace(azurerm_cost_anomaly_alert.this[0].message)) > 0 && length(azurerm_cost_anomaly_alert.this[0].message) <= 100
    error_message = "The cost anomaly alert message must be non-empty and at most 100 characters."
  }
}
