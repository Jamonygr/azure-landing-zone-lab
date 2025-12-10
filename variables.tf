# =============================================================================
# ROOT VARIABLES
# =============================================================================

# -----------------------------------------------------------------------------
# General Configuration
# -----------------------------------------------------------------------------

variable "subscription_id" {
  description = "Azure Subscription ID"
  type        = string
}

variable "project" {
  description = "Project name"
  type        = string
  default     = "azlab"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "lab"
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "West Europe"
}

variable "owner" {
  description = "Owner of the resources"
  type        = string
  default     = "Lab-User"
}

variable "repository_url" {
  description = "Git repository URL"
  type        = string
  default     = "https://gitlab.com/your-repo/azure-landing-zone-lab"
}

# -----------------------------------------------------------------------------
# Authentication
# -----------------------------------------------------------------------------

variable "admin_username" {
  description = "Admin username for all VMs"
  type        = string
  default     = "azureadmin"
}

variable "admin_password" {
  description = "Admin password for all VMs"
  type        = string
  sensitive   = true
}

variable "sql_admin_login" {
  description = "SQL Server admin login"
  type        = string
  default     = "sqladmin"
}

variable "sql_admin_password" {
  description = "SQL Server admin password"
  type        = string
  sensitive   = true
}

variable "vpn_shared_key" {
  description = "Shared key for VPN connections - must be provided securely via terraform.tfvars or environment variable"
  type        = string
  sensitive   = true
  # No default - must be explicitly set to avoid committing secrets
}

# -----------------------------------------------------------------------------
# Hub Network Configuration
# -----------------------------------------------------------------------------

variable "hub_address_space" {
  description = "Hub VNet address space"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "hub_gateway_subnet_prefix" {
  description = "Hub Gateway subnet prefix"
  type        = string
  default     = "10.0.0.0/24"
}

variable "hub_firewall_subnet_prefix" {
  description = "Hub Firewall subnet prefix"
  type        = string
  default     = "10.0.1.0/24"
}

variable "hub_mgmt_subnet_prefix" {
  description = "Hub Management subnet prefix"
  type        = string
  default     = "10.0.2.0/24"
}

variable "vpn_client_address_pool" {
  description = "VPN client address pool"
  type        = string
  default     = "172.16.0.0/24"
}

# -----------------------------------------------------------------------------
# Identity Network Configuration
# -----------------------------------------------------------------------------

variable "identity_address_space" {
  description = "Identity VNet address space"
  type        = list(string)
  default     = ["10.1.0.0/16"]
}

variable "identity_dc_subnet_prefix" {
  description = "Identity DC subnet prefix"
  type        = string
  default     = "10.1.1.0/24"
}

variable "dc01_ip_address" {
  description = "DC01 static IP address"
  type        = string
  default     = "10.1.1.4"
}

variable "dc02_ip_address" {
  description = "DC02 static IP address"
  type        = string
  default     = "10.1.1.5"
}

# -----------------------------------------------------------------------------
# Management Network Configuration
# -----------------------------------------------------------------------------

variable "management_address_space" {
  description = "Management VNet address space"
  type        = list(string)
  default     = ["10.2.0.0/16"]
}

variable "management_jumpbox_subnet_prefix" {
  description = "Management Jump box subnet prefix"
  type        = string
  default     = "10.2.1.0/24"
}

# -----------------------------------------------------------------------------
# Shared Services Network Configuration
# -----------------------------------------------------------------------------

variable "shared_address_space" {
  description = "Shared Services VNet address space"
  type        = list(string)
  default     = ["10.3.0.0/16"]
}

variable "shared_app_subnet_prefix" {
  description = "Shared Services App subnet prefix"
  type        = string
  default     = "10.3.1.0/24"
}

variable "shared_pe_subnet_prefix" {
  description = "Shared Services Private Endpoint subnet prefix"
  type        = string
  default     = "10.3.2.0/24"
}

# -----------------------------------------------------------------------------
# Workload Prod Network Configuration
# -----------------------------------------------------------------------------

variable "workload_prod_address_space" {
  description = "Workload Prod VNet address space"
  type        = list(string)
  default     = ["10.10.0.0/16"]
}

variable "workload_prod_web_subnet_prefix" {
  description = "Workload Prod Web subnet prefix"
  type        = string
  default     = "10.10.1.0/24"
}

variable "workload_prod_app_subnet_prefix" {
  description = "Workload Prod App subnet prefix"
  type        = string
  default     = "10.10.2.0/24"
}

variable "workload_prod_data_subnet_prefix" {
  description = "Workload Prod Data subnet prefix"
  type        = string
  default     = "10.10.3.0/24"
}

# -----------------------------------------------------------------------------
# Workload Dev Network Configuration
# -----------------------------------------------------------------------------

variable "workload_dev_address_space" {
  description = "Workload Dev VNet address space"
  type        = list(string)
  default     = ["10.11.0.0/16"]
}

variable "workload_dev_web_subnet_prefix" {
  description = "Workload Dev Web subnet prefix"
  type        = string
  default     = "10.11.1.0/24"
}

variable "workload_dev_app_subnet_prefix" {
  description = "Workload Dev App subnet prefix"
  type        = string
  default     = "10.11.2.0/24"
}

variable "workload_dev_data_subnet_prefix" {
  description = "Workload Dev Data subnet prefix"
  type        = string
  default     = "10.11.3.0/24"
}

# -----------------------------------------------------------------------------
# On-Premises (Simulated) Network Configuration
# -----------------------------------------------------------------------------

variable "onprem_address_space" {
  description = "On-Premises VNet address space"
  type        = list(string)
  default     = ["10.100.0.0/16"]
}

variable "onprem_gateway_subnet_prefix" {
  description = "On-Premises Gateway subnet prefix"
  type        = string
  default     = "10.100.0.0/24"
}

variable "onprem_servers_subnet_prefix" {
  description = "On-Premises Servers subnet prefix"
  type        = string
  default     = "10.100.1.0/24"
}

variable "onprem_bgp_asn" {
  description = "On-Premises BGP ASN"
  type        = number
  default     = 65050
}

variable "allowed_rdp_source_ips" {
  description = "List of IP addresses/CIDR ranges allowed to RDP to on-prem management VM. Set to your public IP for security."
  type        = list(string)
  default     = [] # Empty means no RDP from internet - use VPN or set explicitly
}

# -----------------------------------------------------------------------------
# Deployment Flags
# -----------------------------------------------------------------------------

variable "deploy_firewall" {
  description = "Deploy Azure Firewall"
  type        = bool
  default     = true
}

variable "firewall_sku_tier" {
  description = "Firewall SKU tier"
  type        = string
  default     = "Standard"
}

variable "deploy_vpn_gateway" {
  description = "Deploy VPN Gateway"
  type        = bool
  default     = true
}

variable "vpn_gateway_sku" {
  description = "VPN Gateway SKU"
  type        = string
  default     = "VpnGw1"
}

variable "enable_bgp" {
  description = "Enable BGP on VPN Gateways"
  type        = bool
  default     = false
}

variable "hub_bgp_asn" {
  description = "Hub BGP ASN"
  type        = number
  default     = 65515
}

variable "deploy_secondary_dc" {
  description = "Deploy secondary Domain Controller"
  type        = bool
  default     = false
}

variable "enable_jumpbox_public_ip" {
  description = "Enable public IP for jump box"
  type        = bool
  default     = false
}

variable "deploy_log_analytics" {
  description = "Deploy Log Analytics workspace"
  type        = bool
  default     = true
}

variable "log_retention_days" {
  description = "Log retention in days"
  type        = number
  default     = 30
}

variable "log_daily_quota_gb" {
  description = "Daily log quota in GB"
  type        = number
  default     = 1
}

variable "deploy_keyvault" {
  description = "Deploy Key Vault"
  type        = bool
  default     = true
}

variable "deploy_storage" {
  description = "Deploy Storage Account"
  type        = bool
  default     = true
}

variable "deploy_sql" {
  description = "Deploy Azure SQL"
  type        = bool
  default     = true
}

variable "deploy_workload_prod" {
  description = "Deploy Production workload"
  type        = bool
  default     = true
}

variable "deploy_workload_dev" {
  description = "Deploy Development workload"
  type        = bool
  default     = false
}

variable "deploy_onprem_simulation" {
  description = "Deploy simulated On-Premises environment"
  type        = bool
  default     = true
}

# -----------------------------------------------------------------------------
# VM Configuration
# -----------------------------------------------------------------------------

variable "vm_size" {
  description = "Default VM size"
  type        = string
  default     = "Standard_B2s"
}

variable "sql_vm_size" {
  description = "SQL VM size"
  type        = string
  default     = "Standard_B2s"
}

variable "enable_auto_shutdown" {
  description = "Enable auto-shutdown for VMs"
  type        = bool
  default     = true
}

# -----------------------------------------------------------------------------
# AKS Configuration
# -----------------------------------------------------------------------------

variable "deploy_aks" {
  description = "Deploy AKS cluster in workload prod"
  type        = bool
  default     = false
}

variable "aks_subnet_prefix" {
  description = "AKS subnet CIDR (needs room for nodes + pods)"
  type        = string
  default     = "10.10.16.0/20"
}

variable "aks_node_count" {
  description = "AKS node count (minimum for lab)"
  type        = number
  default     = 1
}

variable "aks_vm_size" {
  description = "AKS node VM size"
  type        = string
  default     = "Standard_B2s"
}

# -----------------------------------------------------------------------------
# Load Balancer Configuration
# -----------------------------------------------------------------------------

variable "deploy_load_balancer" {
  description = "Deploy load balancer with IIS web servers in workload prod"
  type        = bool
  default     = false
}

variable "lb_type" {
  description = "Type of load balancer: 'public' or 'internal'"
  type        = string
  default     = "public"
}

variable "lb_private_ip" {
  description = "Private IP address for internal load balancer"
  type        = string
  default     = null
}

variable "lb_web_server_count" {
  description = "Number of web servers behind the load balancer"
  type        = number
  default     = 2
}

variable "lb_web_server_size" {
  description = "VM size for web servers (2GB RAM minimum for IIS)"
  type        = string
  default     = "Standard_B1ms"
}

# -----------------------------------------------------------------------------
# PaaS Services - Tier 1 (Free)
# -----------------------------------------------------------------------------

variable "deploy_functions" {
  description = "Deploy Azure Functions (Consumption plan - FREE)"
  type        = bool
  default     = false
}

variable "deploy_static_web_app" {
  description = "Deploy Azure Static Web App (Free tier - FREE)"
  type        = bool
  default     = false
}

variable "deploy_logic_apps" {
  description = "Deploy Azure Logic Apps (Consumption - pay per execution)"
  type        = bool
  default     = false
}

variable "deploy_event_grid" {
  description = "Deploy Azure Event Grid (FREE for first 100k ops/month)"
  type        = bool
  default     = false
}

# -----------------------------------------------------------------------------
# PaaS Services - Tier 2 (Low Cost)
# -----------------------------------------------------------------------------

variable "deploy_service_bus" {
  description = "Deploy Azure Service Bus (Basic tier ~$0.05/month)"
  type        = bool
  default     = false
}

variable "deploy_app_service" {
  description = "Deploy Azure App Service (B1 Basic ~$13/month)"
  type        = bool
  default     = false
}

variable "deploy_container_apps" {
  description = "Deploy Azure Container Apps (Consumption ~$5/month)"
  type        = bool
  default     = false
}

# -----------------------------------------------------------------------------
# PaaS Services - Tier 3 (Data)
# -----------------------------------------------------------------------------

variable "deploy_cosmos_db" {
  description = "Deploy Azure Cosmos DB (Serverless ~$0-5/month based on usage)"
  type        = bool
  default     = false
}

variable "paas_alternative_location" {
  description = "Alternative Azure region for PaaS services that have quota/availability issues in primary location"
  type        = string
  default     = "westus2"
}

# -----------------------------------------------------------------------------
# PaaS Services - Tier 4 (Gateway)
# -----------------------------------------------------------------------------

variable "deploy_application_gateway" {
  description = "Deploy Azure Application Gateway (WAF_v2 ~$36/month)"
  type        = bool
  default     = false
}

# -----------------------------------------------------------------------------
# Application Gateway Configuration
# -----------------------------------------------------------------------------

variable "hub_appgw_subnet_prefix" {
  description = "Hub Application Gateway subnet prefix"
  type        = string
  default     = "10.0.3.0/24"
}

variable "appgw_waf_mode" {
  description = "WAF mode for Application Gateway (Detection or Prevention)"
  type        = string
  default     = "Detection"
}

# -----------------------------------------------------------------------------
# Container Apps Configuration
# -----------------------------------------------------------------------------

variable "workload_prod_container_apps_subnet_prefix" {
  description = "Workload Prod Container Apps subnet prefix"
  type        = string
  default     = "10.10.8.0/23"
}

# -----------------------------------------------------------------------------
# Network Extensions - Private DNS Zones
# -----------------------------------------------------------------------------

variable "deploy_private_dns_zones" {
  description = "Deploy centralized Private DNS Zones for Private Link services"
  type        = bool
  default     = false
}

# -----------------------------------------------------------------------------
# Network Extensions - NAT Gateway
# -----------------------------------------------------------------------------

variable "deploy_nat_gateway" {
  description = "Deploy NAT Gateway for explicit outbound SNAT (workload web subnet)"
  type        = bool
  default     = false
}

# -----------------------------------------------------------------------------
# Network Watcher (used by flow logs)
# -----------------------------------------------------------------------------

variable "create_network_watcher" {
  description = "Create Network Watcher/NetworkWatcherRG in the region if it does not already exist (set true for brand-new subscriptions)"
  type        = bool
  default     = false
}

# -----------------------------------------------------------------------------
# Network Extensions - VNet Flow Logs (Replaces deprecated NSG Flow Logs)
# -----------------------------------------------------------------------------

variable "enable_vnet_flow_logs" {
  description = "Enable VNet Flow Logs for traffic visibility (replaces NSG Flow Logs)"
  type        = bool
  default     = false

  validation {
    condition     = !(var.enable_vnet_flow_logs && !var.deploy_storage)
    error_message = "enable_vnet_flow_logs requires deploy_storage = true to store flow logs."
  }
}

variable "enable_nsg_flow_logs" {
  description = "DEPRECATED: Use enable_vnet_flow_logs instead. NSG Flow Logs retired June 2025."
  type        = bool
  default     = false
}

variable "enable_traffic_analytics" {
  description = "Enable Traffic Analytics (requires Log Analytics workspace)"
  type        = bool
  default     = false

  validation {
    condition     = !(var.enable_traffic_analytics && (!var.enable_vnet_flow_logs || !var.deploy_log_analytics || !var.deploy_storage))
    error_message = "enable_traffic_analytics requires enable_vnet_flow_logs, deploy_log_analytics, and deploy_storage to be true."
  }
}

variable "nsg_flow_logs_retention_days" {
  description = "Number of days to retain flow logs (used by both NSG and VNet flow logs)"
  type        = number
  default     = 7
}

# -----------------------------------------------------------------------------
# Network Extensions - Application Security Groups
# -----------------------------------------------------------------------------

variable "deploy_application_security_groups" {
  description = "Deploy Application Security Groups for workload micro-segmentation"
  type        = bool
  default     = false
}
