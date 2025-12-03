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
