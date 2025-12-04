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
location       = "East US"
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
deploy_vpn_gateway = false # DISABLED - takes too long to provision (~$140/month)
vpn_gateway_sku    = "VpnGw1"
enable_bgp         = false # Disabled with VPN
hub_bgp_asn        = 65515

# Identity
deploy_secondary_dc = false # Save ~$30/month

# Management
enable_jumpbox_public_ip = false # Recommended: Use VPN instead
deploy_log_analytics     = true
log_retention_days       = 30 # Free tier
log_daily_quota_gb       = 1  # Limit ingestion

# Shared Services
deploy_keyvault = true
deploy_storage  = true
deploy_sql      = false # Disabled - East US has provisioning restrictions

# Workloads
deploy_workload_prod = true  # Re-enabled for AKS
deploy_workload_dev  = false # Enable if needed

# On-Premises Simulation - DISABLED - VPN takes too long
deploy_onprem_simulation = false # Disabled with VPN

# AKS Cluster
deploy_aks        = false           # DISABLED - takes too long to provision
aks_subnet_prefix = "10.10.16.0/20" # /20 = 4094 IPs for pods
aks_node_count    = 1               # Minimum nodes
aks_vm_size       = "Standard_B2s"  # Smallest practical size

# -----------------------------------------------------------------------------
# VM Configuration
# -----------------------------------------------------------------------------
vm_size              = "Standard_B2s" # 2 vCPU, 4 GB RAM, ~$30/month
sql_vm_size          = "Standard_B2s" # Same for SQL VM
enable_auto_shutdown = true           # Shutdown at 7 PM to save costs