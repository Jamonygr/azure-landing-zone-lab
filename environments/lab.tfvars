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
# FEATURE TOGGLES - FULL LAB DEPLOYMENT
# =============================================================================

# Core Infrastructure
deploy_firewall            = true  # Azure Firewall             ~$300
deploy_vpn_gateway         = false # VPN Gateway                ~$140
deploy_application_gateway = true  # App Gateway + WAF          ~$20
deploy_nat_gateway         = true  # NAT Gateway                ~$5
deploy_load_balancer       = true  # Load Balancer + IIS VMs    ~$35

# Landing Zones
deploy_workload_prod     = true  # Production workload VNet   ~FREE
deploy_workload_dev      = true  # Development workload VNet  ~FREE
deploy_onprem_simulation = false # Simulated on-premises      ~$30
deploy_secondary_dc      = false # Second domain controller   ~$30

# Compute & Containers
deploy_aks            = false # Azure Kubernetes Service   ~$70+
deploy_container_apps = false # Container Apps             ~$0-20
deploy_functions      = false # Azure Functions            ~FREE

# PaaS Services
deploy_app_service    = true # App Service                ~$15
deploy_static_web_app = true # Static Web App             FREE
deploy_logic_apps     = true # Logic Apps                 ~FREE
deploy_event_grid     = true # Event Grid                 FREE
deploy_service_bus    = true # Service Bus                ~$0.05
deploy_cosmos_db      = true # Cosmos DB Serverless       ~$0-5

# Data & Security
deploy_keyvault          = true  # Key Vault                  ~FREE
deploy_storage           = true  # Storage Account            ~$1
deploy_sql               = true  # Azure SQL Database         ~$5
deploy_backup            = false # Recovery Services Vault    ~$10+
deploy_private_endpoints = true  # Private Endpoints          ~FREE
deploy_private_dns_zones = true  # Private DNS Zones          ~FREE

# Monitoring & Observability
deploy_log_analytics      = true  # Log Analytics              ~FREE(30d)
deploy_workbooks          = true  # Azure Workbooks            FREE
deploy_connection_monitor = true  # Connection Monitor         ~$1
deploy_cost_management    = true  # Budget Alerts              FREE
enable_vnet_flow_logs     = false # VNet Flow Logs             ~$1-5
enable_traffic_analytics  = false # Traffic Analytics          ~$3

# Governance & Compliance
deploy_azure_policy          = true # Azure Policy               FREE
deploy_management_groups     = true # Management Groups          FREE
deploy_rbac_custom_roles     = true # Custom RBAC Roles          FREE
deploy_regulatory_compliance = true # HIPAA/PCI-DSS Policies     FREE

# Automation
enable_auto_shutdown       = true # VM Auto-Shutdown 7PM       SAVES $$$
enable_scheduled_startstop = true # Scheduled Start/Stop       ~$1

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
