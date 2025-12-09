# =============================================================================
# WORKLOAD LANDING ZONE - VARIABLES
# =============================================================================

variable "workload_name" {
  description = "Workload name (e.g., prod, dev)"
  type        = string
}

variable "workload_short" {
  description = "Short workload name for VM naming (max 4 chars)"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "location_short" {
  description = "Short location code"
  type        = string
}

variable "resource_group_name" {
  description = "Resource group name"
  type        = string
}

variable "tags" {
  description = "Tags to apply"
  type        = map(string)
  default     = {}
}

variable "workload_address_space" {
  description = "Workload VNet address space"
  type        = list(string)
}

variable "web_subnet_prefix" {
  description = "Web tier subnet prefix"
  type        = string
}

variable "app_subnet_prefix" {
  description = "App tier subnet prefix"
  type        = string
}

variable "data_subnet_prefix" {
  description = "Data tier subnet prefix"
  type        = string
}

variable "dns_servers" {
  description = "Custom DNS servers"
  type        = list(string)
  default     = []
}

variable "hub_address_prefix" {
  description = "Hub VNet address prefix"
  type        = string
  default     = "10.0.0.0/16"
}

variable "firewall_private_ip" {
  description = "Azure Firewall private IP"
  type        = string
  default     = null
}

variable "deploy_route_table" {
  description = "Deploy route table via firewall"
  type        = bool
  default     = false
}

# AKS Variables
variable "deploy_aks" {
  description = "Deploy AKS cluster"
  type        = bool
  default     = false
}

variable "aks_subnet_prefix" {
  description = "AKS subnet CIDR"
  type        = string
  default     = ""
}

variable "aks_node_count" {
  description = "AKS node count"
  type        = number
  default     = 1
}

variable "aks_vm_size" {
  description = "AKS node VM size"
  type        = string
  default     = "Standard_B2s"
}

variable "log_analytics_workspace_id" {
  description = "Log Analytics workspace ID for AKS monitoring"
  type        = string
  default     = null
}

variable "enable_diagnostics" {
  description = "Enable diagnostic settings (must be known at plan time)"
  type        = bool
  default     = false
}

# =============================================================================
# LOAD BALANCER VARIABLES
# =============================================================================

variable "deploy_load_balancer" {
  description = "Deploy load balancer with web servers"
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
  description = "VM size for web servers"
  type        = string
  default     = "Standard_B1ms"
}

variable "admin_username" {
  description = "Admin username for VMs"
  type        = string
  default     = "azureadmin"
}

variable "admin_password" {
  description = "Admin password for VMs"
  type        = string
  sensitive   = true
  default     = null
}

# =============================================================================
# PAAS SERVICES - TIER 1 (FREE)
# =============================================================================

variable "deploy_functions" {
  description = "Deploy Azure Functions (Consumption - FREE)"
  type        = bool
  default     = false
}

variable "deploy_static_web_app" {
  description = "Deploy Static Web App (Free tier)"
  type        = bool
  default     = false
}

variable "deploy_logic_apps" {
  description = "Deploy Logic Apps (Consumption)"
  type        = bool
  default     = false
}

variable "deploy_event_grid" {
  description = "Deploy Event Grid custom topic"
  type        = bool
  default     = false
}

# =============================================================================
# PAAS SERVICES - TIER 2 (LOW COST)
# =============================================================================

variable "deploy_service_bus" {
  description = "Deploy Service Bus (Basic tier)"
  type        = bool
  default     = false
}

variable "deploy_app_service" {
  description = "Deploy App Service (B1)"
  type        = bool
  default     = false
}

# =============================================================================
# PAAS SERVICES - TIER 3 (DATA)
# =============================================================================

variable "deploy_cosmos_db" {
  description = "Deploy Cosmos DB (Serverless)"
  type        = bool
  default     = false
}

variable "paas_alternative_location" {
  description = "Alternative Azure region for PaaS services with quota/availability issues"
  type        = string
  default     = "westus2"
}
