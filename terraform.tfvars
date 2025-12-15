# =============================================================================
# TERRAFORM.TFVARS - LAB ENVIRONMENT CONFIGURATION
# =============================================================================

# -----------------------------------------------------------------------------
# Azure Subscription
# -----------------------------------------------------------------------------
subscription_id = "97386c43-2906-40dc-9493-4e82e13b31bf"

# -----------------------------------------------------------------------------
# General Configuration
# -----------------------------------------------------------------------------
project        = "azlab"
environment    = "lab"
location       = "westus2"
owner          = "Lab-User"
repository_url = "https://gitlab.com/your-repo/azure-landing-zone-lab"

# -----------------------------------------------------------------------------
# Authentication (CHANGE THESE!)
# -----------------------------------------------------------------------------
admin_username     = "azureadmin"
admin_password     = "P@ssw0rd123!Lab" # Change this!
sql_admin_login    = "sqladmin"
sql_admin_password = "SqlP@ssw0rd123!"           # Change this!
vpn_shared_key     = "AzureLabVPN2024!SecureKey" # Change this!

# -----------------------------------------------------------------------------
# Network Configuration
# IP Address Scheme:
#   Hub:            10.0.0.0/16
#   Identity:       10.1.0.0/16
#   Management:     10.2.0.0/16
#   Shared:         10.3.0.0/16
#   Workload Prod:  10.10.0.0/16
#   Workload Dev:   10.11.0.0/16
#   On-Premises:    10.100.0.0/16
#   VPN Clients:    172.16.0.0/24
# -----------------------------------------------------------------------------

# Hub
hub_address_space          = ["10.0.0.0/16"]
hub_gateway_subnet_prefix  = "10.0.0.0/24"
hub_firewall_subnet_prefix = "10.0.1.0/24"
hub_mgmt_subnet_prefix     = "10.0.2.0/24"
vpn_client_address_pool    = "172.16.0.0/24"

# Identity
identity_address_space    = ["10.1.0.0/16"]
identity_dc_subnet_prefix = "10.1.1.0/24"
dc01_ip_address           = "10.1.1.4"
dc02_ip_address           = "10.1.1.5"

# Management
management_address_space         = ["10.2.0.0/16"]
management_jumpbox_subnet_prefix = "10.2.1.0/24"

# Shared Services
shared_address_space     = ["10.3.0.0/16"]
shared_app_subnet_prefix = "10.3.1.0/24"
shared_pe_subnet_prefix  = "10.3.2.0/24"

# Workload Prod
workload_prod_address_space      = ["10.10.0.0/16"]
workload_prod_web_subnet_prefix  = "10.10.1.0/24"
workload_prod_app_subnet_prefix  = "10.10.2.0/24"
workload_prod_data_subnet_prefix = "10.10.3.0/24"

# Workload Dev
workload_dev_address_space      = ["10.11.0.0/16"]
workload_dev_web_subnet_prefix  = "10.11.1.0/24"
workload_dev_app_subnet_prefix  = "10.11.2.0/24"
workload_dev_data_subnet_prefix = "10.11.3.0/24"

# On-Premises (Simulated)
onprem_address_space         = ["10.100.0.0/16"]
onprem_gateway_subnet_prefix = "10.100.0.0/24"
onprem_servers_subnet_prefix = "10.100.1.0/24"
onprem_bgp_asn               = 65050

# -----------------------------------------------------------------------------
# Deployment Flags (Enable/Disable Components)
# Set to false to reduce costs or simplify the lab
# -----------------------------------------------------------------------------

# Core Infrastructure
deploy_firewall    = true # ~$300/month
firewall_sku_tier  = "Standard"
deploy_vpn_gateway = false # Disabled per request to avoid VPN deployment
vpn_gateway_sku    = "VpnGw1"
enable_bgp         = false # Disabled with VPN
hub_bgp_asn        = 65515

# Identity
deploy_secondary_dc = false # Save ~$30/month

# Management
enable_jumpbox_public_ip = true  # Enable public RDP to jumpbox
allowed_jumpbox_source_ips = ["0.0.0.0/0"] # TODO: tighten to your public IP/CIDR
deploy_log_analytics     = true
log_retention_days       = 30 # Free tier
log_daily_quota_gb       = 2  # Increased for flow logs + diagnostics

# Shared Services
deploy_keyvault = true
deploy_storage  = true
deploy_sql      = true # Enabled per request

# Workloads
deploy_workload_prod = true  # Re-enabled for AKS
deploy_workload_dev  = true  # Enabled - FREE dev/prod separation

# On-Premises Simulation - DISABLED - VPN takes too long
deploy_onprem_simulation = false # Disabled with VPN

# AKS Cluster
deploy_aks        = false           # DISABLED - takes too long to provision
aks_subnet_prefix = "10.10.16.0/20" # /20 = 4094 IPs for pods
aks_node_count    = 1               # Minimum nodes
aks_vm_size       = "Standard_B2s"  # Smallest practical size

# Load Balancer with IIS Web Servers
deploy_load_balancer = true            # Enable for LB lab
lb_type              = "public"        # Public LB (separate from firewall)
lb_private_ip        = null            # Not used for public LB
lb_web_server_count  = 2               # Number of IIS web servers
lb_web_server_size   = "Standard_B1ms" # 2GB RAM for IIS

# -----------------------------------------------------------------------------
# PaaS Services - Tier 1 (FREE)
# These services cost nothing or almost nothing
# -----------------------------------------------------------------------------
deploy_functions      = false # Disabled: Azure doesn't allow mixing Dynamic Linux Functions with Windows App Service in same RG
deploy_static_web_app = true # Static Web Apps Free tier - FREE
deploy_logic_apps     = true # Logic Apps Consumption - ~$0 (pay per execution)
deploy_event_grid     = true # Event Grid - FREE (first 100k ops/month)

# -----------------------------------------------------------------------------
# PaaS Services - Tier 2 (Low Cost)
# ~$15-20/month combined
# -----------------------------------------------------------------------------
deploy_service_bus    = true  # Service Bus Basic - ~$0.05/month
deploy_app_service    = true  # Testing with westeurope location
deploy_container_apps = false # DELETED - Module removed from codebase

# -----------------------------------------------------------------------------
# PaaS Services - Tier 3 (Data)
# Pay-per-use, typically ~$0-5/month for lab usage
# -----------------------------------------------------------------------------
deploy_cosmos_db = true # Cosmos DB Serverless - ~$0-5/month

# -----------------------------------------------------------------------------
# Alternative Location for PaaS Services with quota issues
# US regions have 0 quota for App Service/Functions - use Canada Central
# -----------------------------------------------------------------------------
paas_alternative_location = "canadacentral"
cosmos_location           = "northeurope"

# -----------------------------------------------------------------------------
# PaaS Services - Tier 4 (Gateway)
# Higher fixed cost but provides enterprise features
# -----------------------------------------------------------------------------
deploy_application_gateway = true # Enabled per request
hub_appgw_subnet_prefix    = "10.0.3.0/24"
appgw_waf_mode             = "Detection" # Use Prevention in production

# Container Apps Subnet
workload_prod_container_apps_subnet_prefix = "10.10.8.0/23" # /23 for Container Apps

# -----------------------------------------------------------------------------
# VM Configuration
# -----------------------------------------------------------------------------
vm_size              = "Standard_B2s" # 2 vCPU, 4 GB RAM, ~$30/month
sql_vm_size          = "Standard_B2s" # Same for SQL VM
enable_auto_shutdown = true           # Shutdown at 7 PM to save costs

# -----------------------------------------------------------------------------
# Automation (Scheduled Start/Stop)
# -----------------------------------------------------------------------------
enable_scheduled_startstop = true
startstop_timezone         = "America/New_York"
startstop_start_time       = "08:00"
startstop_stop_time        = "19:00"

# -----------------------------------------------------------------------------
# Network Add-ons & Observability (FREE)
# -----------------------------------------------------------------------------
create_network_watcher             = false # Use existing Network Watcher (westus2-watcher)
network_watcher_name               = "westus2-watcher"  # Actual name in subscription
enable_vnet_flow_logs              = false # Disabled: BadRequest error needs investigation
enable_traffic_analytics           = false # Disabled: Requires VNet Flow Logs to be enabled
deploy_application_security_groups = true  # Micro-segmentation (FREE)
deploy_nat_gateway                 = true  # Fixed outbound IPs (~$4-5/mo)

# -----------------------------------------------------------------------------
# Monitoring & Observability (FREE/Low Cost)
# -----------------------------------------------------------------------------
deploy_workbooks          = true  # Azure Monitor Workbooks (FREE)
deploy_connection_monitor = true # Enabled per request
deploy_cost_management    = true  # Budget alerts (FREE)
cost_budget_amount        = 500   # Monthly budget in USD
cost_alert_emails         = ["your-email@example.com"]  # Change to your email

# -----------------------------------------------------------------------------
# Azure Backup
# -----------------------------------------------------------------------------
deploy_backup              = true
backup_storage_redundancy  = "LocallyRedundant"

# -----------------------------------------------------------------------------
# Private Endpoints Configuration
# -----------------------------------------------------------------------------
deploy_private_dns_zones = true  # Required for private endpoints
deploy_private_endpoints = true  # Private Endpoints for Key Vault, Storage, SQL

# -----------------------------------------------------------------------------
# Governance & Policy
# -----------------------------------------------------------------------------
deploy_azure_policy       = true
policy_allowed_locations  = ["eastus", "eastus2", "westeurope", "northeurope", "westus2", "canadacentral"]
policy_required_tags = {
  Environment = "lab"
  Owner       = "Lab-User"
  Project     = "azlab"
}
deploy_management_groups  = true
deploy_rbac_custom_roles  = true

# -----------------------------------------------------------------------------
# Regulatory Compliance (Workload RGs Only - Audit Mode)
# -----------------------------------------------------------------------------
deploy_regulatory_compliance = true  # Enabled per request
enable_hipaa_compliance      = true
enable_pci_dss_compliance    = true
compliance_enforcement_mode  = "DoNotEnforce"
