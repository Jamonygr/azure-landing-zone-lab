# =============================================================================
# CHEAP LAB ENVIRONMENT CONFIGURATION
# =============================================================================
# Lowest-cost learning profile. Enable richer services explicitly when needed.
# =============================================================================

environment = "cheap-lab"
project     = "azlab"
location    = "westus2"
owner       = "Lab-User"

# Expensive edge and connectivity services are off by default.
deploy_firewall            = false
deploy_vpn_gateway         = false
deploy_application_gateway = false
deploy_nat_gateway         = false
deploy_load_balancer       = false
enable_lb_rdp_nat_rules    = false

# Keep one workload spoke for topology practice, but no web VM pool or AKS.
deploy_workload_prod     = true
deploy_workload_dev      = false
deploy_onprem_simulation = false
deploy_secondary_dc      = false
deploy_aks               = false
deploy_container_apps    = false

# Keep private-first shared services small.
deploy_keyvault          = true
deploy_storage           = true
deploy_sql               = false
deploy_private_endpoints = true
deploy_private_dns_zones = true

# PaaS bundle is opt-in for this profile.
deploy_functions      = false
deploy_static_web_app = false
deploy_logic_apps     = false
deploy_event_grid     = false
deploy_service_bus    = false
deploy_app_service    = false
deploy_cosmos_db      = false

# Monitoring and governance stay lightweight.
deploy_log_analytics         = true
deploy_workbooks             = false
deploy_connection_monitor    = false
deploy_cost_management       = true
cost_alert_emails            = ["replace-me@example.com"]
deploy_backup                = false
enable_vnet_flow_logs        = false
enable_traffic_analytics     = false
deploy_azure_policy          = false
deploy_management_groups     = false
deploy_rbac_custom_roles     = false
deploy_regulatory_compliance = false
enable_scheduled_startstop   = false
enable_auto_shutdown         = true
enable_jumpbox_public_ip     = false
allowed_jumpbox_source_ips   = []

# Small VM sizes.
vm_size     = "Standard_B2s"
sql_vm_size = "Standard_B2s"

# Addressing
hub_address_space          = ["10.0.0.0/16"]
hub_gateway_subnet_prefix  = "10.0.0.0/24"
hub_firewall_subnet_prefix = "10.0.1.0/24"
hub_mgmt_subnet_prefix     = "10.0.2.0/24"
hub_appgw_subnet_prefix    = "10.0.3.0/24"

identity_address_space    = ["10.1.0.0/16"]
identity_dc_subnet_prefix = "10.1.1.0/24"
dc01_ip_address           = "10.1.1.4"
dc02_ip_address           = "10.1.1.5"

management_address_space         = ["10.2.0.0/16"]
management_jumpbox_subnet_prefix = "10.2.1.0/24"

shared_address_space     = ["10.3.0.0/16"]
shared_app_subnet_prefix = "10.3.1.0/24"
shared_pe_subnet_prefix  = "10.3.2.0/24"

workload_prod_address_space                = ["10.10.0.0/16"]
workload_prod_web_subnet_prefix            = "10.10.1.0/24"
workload_prod_app_subnet_prefix            = "10.10.2.0/24"
workload_prod_data_subnet_prefix           = "10.10.3.0/24"
workload_prod_container_apps_subnet_prefix = "10.10.8.0/23"

workload_dev_address_space      = ["10.11.0.0/16"]
workload_dev_web_subnet_prefix  = "10.11.1.0/24"
workload_dev_app_subnet_prefix  = "10.11.2.0/24"
workload_dev_data_subnet_prefix = "10.11.3.0/24"

log_retention_days = 30
log_daily_quota_gb = 0.5

create_network_watcher = false
network_watcher_name   = "NetworkWatcher_westus2"

policy_allowed_locations = ["eastus", "eastus2", "westeurope", "northeurope", "westus2"]
