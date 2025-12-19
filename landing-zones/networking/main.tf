# =============================================================================
# NETWORKING PILLAR
# Hub VNet, Firewall, VPN Gateway, Application Gateway, Firewall Rules
# =============================================================================

module "hub" {
  source = "./core"

  environment         = var.environment
  location            = var.location
  location_short      = var.location_short
  resource_group_name = var.resource_group_name
  tags                = var.tags

  hub_address_space      = var.hub_address_space
  gateway_subnet_prefix  = var.gateway_subnet_prefix
  firewall_subnet_prefix = var.firewall_subnet_prefix
  hub_mgmt_subnet_prefix = var.hub_mgmt_subnet_prefix

  deploy_firewall         = var.deploy_firewall
  firewall_sku_tier       = var.firewall_sku_tier
  deploy_vpn_gateway      = var.deploy_vpn_gateway
  vpn_gateway_sku         = var.vpn_gateway_sku
  enable_bgp              = var.enable_bgp
  hub_bgp_asn             = var.hub_bgp_asn
  vpn_client_address_pool = var.vpn_client_address_pool

  identity_address_space        = var.identity_address_space[0]
  management_address_space      = var.management_address_space[0]
  shared_services_address_space = var.shared_address_space[0]
  workload_address_space        = var.workload_address_space[0]

  deploy_application_gateway = var.deploy_application_gateway
  appgw_subnet_prefix        = var.hub_appgw_subnet_prefix
  appgw_waf_mode             = var.appgw_waf_mode

  # Avoid circular dependencies; diagnostics and backend IPs are set later
  log_analytics_workspace_id = null
  enable_diagnostics         = false
  lb_backend_ips             = var.lb_backend_ips
}

# -----------------------------------------------------------------------------
# FIREWALL RULE COLLECTIONS (base + PaaS)
# -----------------------------------------------------------------------------

module "firewall_rules_base" {
  source = "../../modules/firewall-rules"
  count  = var.deploy_firewall ? 1 : 0

  name               = "rcg-base-rules"
  firewall_policy_id = module.hub.firewall_policy_id
  priority           = 100

  network_rule_collections = [
    {
      name     = "allow-dns"
      priority = 100
      action   = "Allow"
      rules = [
        {
          name                  = "allow-dns-to-dc"
          protocols             = ["UDP", "TCP"]
          source_addresses      = ["10.0.0.0/8"]
          destination_addresses = [var.dc01_ip_address, var.dc02_ip_address]
          destination_ports     = ["53"]
        }
      ]
    },
    {
      name     = "allow-rdp"
      priority = 200
      action   = "Allow"
      rules = [
        {
          name                  = "allow-rdp-from-hub"
          protocols             = ["TCP"]
          source_addresses      = var.hub_address_space
          destination_addresses = ["10.0.0.0/8"]
          destination_ports     = ["3389"]
        },
        {
          name                  = "allow-rdp-from-vpn"
          protocols             = ["TCP"]
          source_addresses      = [var.vpn_client_address_pool]
          destination_addresses = ["10.0.0.0/8"]
          destination_ports     = ["3389"]
        }
      ]
    },
    {
      name     = "allow-inter-spoke"
      priority = 300
      action   = "Allow"
      rules = [
        {
          name                  = "allow-spoke-to-spoke"
          protocols             = ["Any"]
          source_addresses      = ["10.0.0.0/8"]
          destination_addresses = ["10.0.0.0/8"]
          destination_ports     = ["*"]
        }
      ]
    },
    {
      name     = "allow-onprem"
      priority = 400
      action   = "Allow"
      rules = [
        {
          name                  = "allow-onprem-to-azure"
          protocols             = ["Any"]
          source_addresses      = var.workload_address_space
          destination_addresses = ["10.0.0.0/8"]
          destination_ports     = ["*"]
        },
        {
          name                  = "allow-azure-to-onprem"
          protocols             = ["Any"]
          source_addresses      = ["10.0.0.0/8"]
          destination_addresses = var.workload_address_space
          destination_ports     = ["*"]
        }
      ]
    }
  ]

  application_rule_collections = [
    {
      name     = "allow-internet"
      priority = 500
      action   = "Allow"
      rules = [
        {
          name              = "allow-windows-update"
          source_addresses  = ["10.0.0.0/8"]
          destination_fqdns = ["*.windowsupdate.microsoft.com", "*.update.microsoft.com", "*.windowsupdate.com"]
          protocols = [
            { type = "Https", port = 443 }
          ]
        },
        {
          name              = "allow-azure-services"
          source_addresses  = ["10.0.0.0/8"]
          destination_fqdns = ["*.azure.com", "*.microsoft.com", "*.windows.net", "*.azure-automation.net"]
          protocols = [
            { type = "Https", port = 443 }
          ]
        }
      ]
    }
  ]

  nat_rule_collections = []
}

module "firewall_rules_paas" {
  source = "../../modules/firewall-rules"
  count  = var.deploy_firewall ? 1 : 0

  name               = "rcg-paas-rules"
  firewall_policy_id = module.hub.firewall_policy_id
  priority           = 200

  network_rule_collections = []

  application_rule_collections = [
    {
      name     = "allow-paas-services"
      priority = 100
      action   = "Allow"
      rules = [
        {
          name              = "allow-azure-functions"
          source_addresses  = ["10.0.0.0/8"]
          destination_fqdns = ["*.azurewebsites.net", "*.scm.azurewebsites.net"]
          protocols = [
            { type = "Https", port = 443 }
          ]
        },
        {
          name              = "allow-static-web-apps"
          source_addresses  = ["10.0.0.0/8"]
          destination_fqdns = ["*.azurestaticapps.net", "*.swa.microsoft.com"]
          protocols = [
            { type = "Https", port = 443 }
          ]
        },
        {
          name              = "allow-logic-apps"
          source_addresses  = ["10.0.0.0/8"]
          destination_fqdns = ["*.logic.azure.com", "*.azure-api.net"]
          protocols = [
            { type = "Https", port = 443 }
          ]
        },
        {
          name              = "allow-event-grid"
          source_addresses  = ["10.0.0.0/8"]
          destination_fqdns = ["*.eventgrid.azure.net"]
          protocols = [
            { type = "Https", port = 443 }
          ]
        },
        {
          name              = "allow-service-bus"
          source_addresses  = ["10.0.0.0/8"]
          destination_fqdns = ["*.servicebus.windows.net"]
          protocols = [
            { type = "Https", port = 443 }
          ]
        },
        {
          name              = "allow-cosmos-db"
          source_addresses  = ["10.0.0.0/8"]
          destination_fqdns = ["*.documents.azure.com", "*.cosmos.azure.com"]
          protocols = [
            { type = "Https", port = 443 }
          ]
        },
        {
          name              = "allow-app-insights"
          source_addresses  = ["10.0.0.0/8"]
          destination_fqdns = ["*.applicationinsights.azure.com", "*.in.applicationinsights.azure.com", "*.live.applicationinsights.azure.com"]
          protocols = [
            { type = "Https", port = 443 }
          ]
        }
      ]
    }
  ]

  nat_rule_collections = []

  depends_on = [module.firewall_rules_base]
}
