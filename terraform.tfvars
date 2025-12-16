# =============================================================================
# TERRAFORM.TFVARS - LAB ENVIRONMENT CONFIGURATION
# =============================================================================
# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║                                                                           ║
# ║                    🎛️  MASTER CONTROL PANEL                               ║
# ║                                                                           ║
# ║     All feature toggles in ONE place. Change true/false to deploy!       ║
# ║                                                                           ║
# ╚═══════════════════════════════════════════════════════════════════════════╝

# ┌───────────────────────────────────────────────────────────────────────────┐
# │ CORE INFRASTRUCTURE                                      Est. Cost/Month │
# ├───────────────────────────────────────────────────────────────────────────┤
deploy_firewall            = true  # Azure Firewall             ~$300
deploy_vpn_gateway         = false # VPN Gateway                ~$140
deploy_application_gateway = true  # App Gateway + WAF          ~$20
deploy_nat_gateway         = true  # NAT Gateway                ~$5
deploy_load_balancer       = true  # Load Balancer + IIS VMs    ~$35
# └───────────────────────────────────────────────────────────────────────────┘

# ┌───────────────────────────────────────────────────────────────────────────┐
# │ LANDING ZONES                                                             │
# ├───────────────────────────────────────────────────────────────────────────┤
deploy_workload_prod     = true  # Production workload VNet   ~FREE
deploy_workload_dev      = true  # Development workload VNet  ~FREE
deploy_onprem_simulation = false # Simulated on-premises      ~$30
deploy_secondary_dc      = false # Second domain controller   ~$30
# └───────────────────────────────────────────────────────────────────────────┘

# ┌───────────────────────────────────────────────────────────────────────────┐
# │ COMPUTE & CONTAINERS                                                      │
# ├───────────────────────────────────────────────────────────────────────────┤
deploy_aks            = false # Azure Kubernetes Service   ~$70+
deploy_container_apps = false # Container Apps             ~$0-20
deploy_functions      = false # Azure Functions            ~FREE
# └───────────────────────────────────────────────────────────────────────────┘

# ┌───────────────────────────────────────────────────────────────────────────┐
# │ PAAS SERVICES                                                             │
# ├───────────────────────────────────────────────────────────────────────────┤
deploy_app_service    = true # App Service                ~$15
deploy_static_web_app = true # Static Web App             FREE
deploy_logic_apps     = true # Logic Apps                 ~FREE
deploy_event_grid     = true # Event Grid                 FREE
deploy_service_bus    = true # Service Bus                ~$0.05
deploy_cosmos_db      = true # Cosmos DB Serverless       ~$0-5
# └───────────────────────────────────────────────────────────────────────────┘

# ┌───────────────────────────────────────────────────────────────────────────┐
# │ DATA & SECURITY                                                           │
# ├───────────────────────────────────────────────────────────────────────────┤
deploy_keyvault          = true  # Key Vault                  ~FREE
deploy_storage           = true  # Storage Account            ~$1
deploy_sql               = true  # Azure SQL Database         ~$5
deploy_backup            = false # Recovery Services Vault    ~$10+
deploy_private_endpoints = true  # Private Endpoints          ~FREE
deploy_private_dns_zones = true  # Private DNS Zones          ~FREE
# └───────────────────────────────────────────────────────────────────────────┘

# ┌───────────────────────────────────────────────────────────────────────────┐
# │ MONITORING & OBSERVABILITY                                                │
# ├───────────────────────────────────────────────────────────────────────────┤
deploy_log_analytics      = true  # Log Analytics              ~FREE(30d)
deploy_workbooks          = true  # Azure Workbooks            FREE
deploy_connection_monitor = true  # Connection Monitor         ~$1
deploy_cost_management    = true  # Budget Alerts              FREE
enable_vnet_flow_logs     = false # VNet Flow Logs             ~$1-5
enable_traffic_analytics  = false # Traffic Analytics          ~$3
# └───────────────────────────────────────────────────────────────────────────┘

# ┌───────────────────────────────────────────────────────────────────────────┐
# │ GOVERNANCE & COMPLIANCE                                                   │
# ├───────────────────────────────────────────────────────────────────────────┤
deploy_azure_policy          = true # Azure Policy               FREE
deploy_management_groups     = true # Management Groups          FREE
deploy_rbac_custom_roles     = true # Custom RBAC Roles          FREE
deploy_regulatory_compliance = true # HIPAA/PCI-DSS Policies     FREE
# └───────────────────────────────────────────────────────────────────────────┘

# ┌───────────────────────────────────────────────────────────────────────────┐
# │ AUTOMATION                                                                │
# ├───────────────────────────────────────────────────────────────────────────┤
enable_auto_shutdown       = true # VM Auto-Shutdown 7PM       SAVES $$$
enable_scheduled_startstop = true # Scheduled Start/Stop       ~$1
# └───────────────────────────────────────────────────────────────────────────┘

# ═══════════════════════════════════════════════════════════════════════════
#                        END OF FEATURE TOGGLES
#            (Configuration details below - rarely need to change)
# ═══════════════════════════════════════════════════════════════════════════


# =============================================================================
# SUBSCRIPTION & GENERAL
# =============================================================================
subscription_id = "97386c43-2906-40dc-9493-4e82e13b31bf"
project         = "azlab"
environment     = "lab"
location        = "westus2"
owner           = "Lab-User"
repository_url  = "https://gitlab.com/your-repo/azure-landing-zone-lab"

# =============================================================================
# AUTHENTICATION (CHANGE THESE!)
# =============================================================================
admin_username     = "azureadmin"
admin_password     = "P@ssw0rd123!Lab" # Change this!
sql_admin_login    = "sqladmin"
sql_admin_password = "SqlP@ssw0rd123!"           # Change this!
vpn_shared_key     = "AzureLabVPN2024!SecureKey" # Change this!

# =============================================================================
# NETWORK ADDRESS SCHEME
# =============================================================================
#   Hub:            10.0.0.0/16      On-Premises:    10.100.0.0/16
#   Identity:       10.1.0.0/16      VPN Clients:    172.16.0.0/24
#   Management:     10.2.0.0/16
#   Shared:         10.3.0.0/16
#   Workload Prod:  10.10.0.0/16
#   Workload Dev:   10.11.0.0/16
# -----------------------------------------------------------------------------

# Hub Network
hub_address_space          = ["10.0.0.0/16"]
hub_gateway_subnet_prefix  = "10.0.0.0/24"
hub_firewall_subnet_prefix = "10.0.1.0/24"
hub_mgmt_subnet_prefix     = "10.0.2.0/24"
hub_appgw_subnet_prefix    = "10.0.3.0/24"
vpn_client_address_pool    = "172.16.0.0/24"

# Identity Network
identity_address_space    = ["10.1.0.0/16"]
identity_dc_subnet_prefix = "10.1.1.0/24"
dc01_ip_address           = "10.1.1.4"
dc02_ip_address           = "10.1.1.5"

# Management Network
management_address_space         = ["10.2.0.0/16"]
management_jumpbox_subnet_prefix = "10.2.1.0/24"

# Shared Services Network
shared_address_space     = ["10.3.0.0/16"]
shared_app_subnet_prefix = "10.3.1.0/24"
shared_pe_subnet_prefix  = "10.3.2.0/24"

# Workload Prod Network
workload_prod_address_space                = ["10.10.0.0/16"]
workload_prod_web_subnet_prefix            = "10.10.1.0/24"
workload_prod_app_subnet_prefix            = "10.10.2.0/24"
workload_prod_data_subnet_prefix           = "10.10.3.0/24"
workload_prod_container_apps_subnet_prefix = "10.10.8.0/23"

# Workload Dev Network
workload_dev_address_space      = ["10.11.0.0/16"]
workload_dev_web_subnet_prefix  = "10.11.1.0/24"
workload_dev_app_subnet_prefix  = "10.11.2.0/24"
workload_dev_data_subnet_prefix = "10.11.3.0/24"

# On-Premises (Simulated) Network
onprem_address_space         = ["10.100.0.0/16"]
onprem_gateway_subnet_prefix = "10.100.0.0/24"
onprem_servers_subnet_prefix = "10.100.1.0/24"
onprem_bgp_asn               = 65050

# =============================================================================
# COMPONENT SETTINGS (Details for enabled features)
# =============================================================================

# Firewall Settings
firewall_sku_tier = "Standard"

# VPN Gateway Settings
vpn_gateway_sku = "VpnGw1"
enable_bgp      = false
hub_bgp_asn     = 65515

# Application Gateway Settings
appgw_waf_mode = "Detection" # Use "Prevention" in production

# Load Balancer Settings
lb_type             = "public"
lb_private_ip       = null
lb_web_server_count = 2
lb_web_server_size  = "Standard_B1ms"

# AKS Settings
aks_subnet_prefix = "10.10.16.0/20"
aks_node_count    = 1
aks_vm_size       = "Standard_B2s"

# VM Settings
vm_size     = "Standard_B2s"
sql_vm_size = "Standard_B2s"

# Jumpbox Settings
enable_jumpbox_public_ip   = true
allowed_jumpbox_source_ips = ["0.0.0.0/0"] # Tighten to your IP!

# Log Analytics Settings
log_retention_days = 30
log_daily_quota_gb = 2

# Backup Settings
backup_storage_redundancy = "LocallyRedundant"

# Automation Schedule Settings
startstop_timezone   = "America/New_York"
startstop_start_time = "08:00"
startstop_stop_time  = "19:00"

# Network Watcher (use existing)
create_network_watcher             = false
network_watcher_name               = "westus2-watcher"
deploy_application_security_groups = true

# Cost Management Settings
cost_budget_amount = 500
cost_alert_emails  = ["your-email@example.com"]

# PaaS Alternative Locations (for quota issues)
paas_alternative_location = "canadacentral"
cosmos_location           = "northeurope"

# =============================================================================
# GOVERNANCE SETTINGS
# =============================================================================
policy_allowed_locations = ["eastus", "eastus2", "westeurope", "northeurope", "westus2", "canadacentral"]
policy_required_tags = {
  Environment = "lab"
  Owner       = "Lab-User"
  Project     = "azlab"
}

# Regulatory Compliance
enable_hipaa_compliance     = true
enable_pci_dss_compliance   = true
compliance_enforcement_mode = "DoNotEnforce" # Audit mode only
