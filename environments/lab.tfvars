# =============================================================================
# LAB ENVIRONMENT CONFIGURATION (EXAMPLE)
# =============================================================================
# Minimal deployment for CI/CD testing and learning
# Estimated cost: ~$100-150/month with auto-shutdown enabled
# 
# INSTRUCTIONS FOR USERS:
# 1. Copy this file or use as-is
# 2. Set your subscription_id via GitHub Secrets (AZURE_SUBSCRIPTION_ID)
# 3. Customize the feature toggles below as needed
# =============================================================================

# =============================================================================
# GENERAL SETTINGS
# =============================================================================
# NOTE: subscription_id is provided via environment variable in CI/CD
# For local use, set TF_VAR_subscription_id or add: subscription_id = "your-id"
environment = "lab"
project     = "azlab"
location    = "westus2"
owner       = "Lab-User"

# =============================================================================
# FEATURE TOGGLES - MINIMAL LAB DEPLOYMENT
# =============================================================================

# Core Infrastructure (minimal for cost savings)
deploy_firewall            = false # Save ~$300/month - use NSGs instead
deploy_vpn_gateway         = false # Save ~$140/month
deploy_application_gateway = false # Save ~$20/month
deploy_nat_gateway         = true  # Keep for outbound connectivity ~$5
deploy_load_balancer       = true  # Web server testing ~$35

# Landing Zones
deploy_workload_prod     = true  # Production workload VNet
deploy_workload_dev      = false # Skip dev in lab
deploy_onprem_simulation = false # Skip on-prem simulation
deploy_secondary_dc      = false # Single DC is sufficient

# Compute & Containers
deploy_aks            = false # Save ~$70+/month
deploy_container_apps = false # Skip for minimal lab
deploy_functions      = false # Skip for minimal lab

# PaaS Services (minimal)
deploy_app_service    = false # Skip for minimal lab
deploy_static_web_app = false # Skip for minimal lab
deploy_logic_apps     = false # Skip for minimal lab
deploy_event_grid     = false # Skip for minimal lab
deploy_service_bus    = false # Skip for minimal lab
deploy_cosmos_db      = false # Skip for minimal lab

# Data & Security
deploy_keyvault          = true  # Keep for secrets management
deploy_storage           = true  # Keep for storage testing
deploy_sql               = false # Skip for minimal lab
deploy_backup            = false # Skip for minimal lab
deploy_private_endpoints = false # Skip for minimal lab
deploy_private_dns_zones = false # Skip for minimal lab

# Monitoring & Observability
deploy_log_analytics      = true  # Keep for monitoring
deploy_workbooks          = false # Skip for minimal lab
deploy_connection_monitor = false # Skip for minimal lab
deploy_cost_management    = true  # Keep for budget tracking
enable_vnet_flow_logs     = false # Skip for minimal lab
enable_traffic_analytics  = false # Skip for minimal lab

# Governance & Compliance
deploy_azure_policy          = false # Skip for minimal lab
deploy_management_groups     = false # Skip for minimal lab
deploy_rbac_custom_roles     = false # Skip for minimal lab
deploy_regulatory_compliance = false # Skip for minimal lab

# Automation
enable_auto_shutdown       = true  # IMPORTANT: Saves money!
enable_scheduled_startstop = false # Skip for minimal lab

# =============================================================================
# NETWORK CONFIGURATION
# =============================================================================
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

workload_prod_address_space      = ["10.10.0.0/16"]
workload_prod_web_subnet_prefix  = "10.10.1.0/24"
workload_prod_app_subnet_prefix  = "10.10.2.0/24"
workload_prod_data_subnet_prefix = "10.10.3.0/24"

# =============================================================================
# VM SIZES (cost-optimized)
# =============================================================================
vm_size     = "Standard_B2s"
sql_vm_size = "Standard_B2s"

# =============================================================================
# LOGGING (minimal retention)
# =============================================================================
log_retention_days = 30
log_daily_quota_gb = 0.5
