# =============================================================================
# MANAGEMENT LANDING ZONE - VARIABLES
# =============================================================================

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

variable "mgmt_address_space" {
  description = "Management VNet address space"
  type        = list(string)
  default     = ["10.2.0.0/16"]
}

variable "jumpbox_subnet_prefix" {
  description = "Jump box subnet prefix"
  type        = string
  default     = "10.2.1.0/24"
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

variable "vpn_client_address_pool" {
  description = "VPN client address pool"
  type        = string
  default     = "172.16.0.0/24"
}

variable "onprem_address_prefix" {
  description = "On-premises address prefix for NSG rules"
  type        = string
  default     = "10.100.0.0/16"
}

variable "vm_size" {
  description = "VM size"
  type        = string
  default     = "Standard_B2s"
}

variable "admin_username" {
  description = "Admin username"
  type        = string
  default     = "azureadmin"
}

variable "admin_password" {
  description = "Admin password"
  type        = string
  sensitive   = true
}

variable "enable_jumpbox_public_ip" {
  description = "Enable public IP for jump box"
  type        = bool
  default     = false
}

variable "enable_auto_shutdown" {
  description = "Enable auto-shutdown"
  type        = bool
  default     = true
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

# =============================================================================
# MONITORING VARIABLES
# =============================================================================

variable "deploy_monitoring" {
  description = "Deploy monitoring resources (action group, alerts)"
  type        = bool
  default     = true
}

variable "alerts_enabled" {
  description = "Enable metric alerts"
  type        = bool
  default     = true
}

variable "alert_email_receivers" {
  description = "List of email receivers for alerts"
  type = list(object({
    name                    = string
    email_address           = string
    use_common_alert_schema = optional(bool, true)
  }))
  default = []
}

# Resource IDs to monitor
variable "monitored_vm_ids" {
  description = "List of VM resource IDs to monitor"
  type        = list(string)
  default     = []
}

variable "monitored_aks_cluster_id" {
  description = "AKS cluster resource ID to monitor"
  type        = string
  default     = ""
}

variable "monitored_sql_server_id" {
  description = "SQL Server resource ID to monitor"
  type        = string
  default     = ""
}

variable "monitored_sql_database_id" {
  description = "SQL Database resource ID to monitor"
  type        = string
  default     = ""
}

variable "monitored_firewall_id" {
  description = "Azure Firewall resource ID to monitor"
  type        = string
  default     = ""
}

variable "monitored_vpn_gateway_id" {
  description = "VPN Gateway resource ID to monitor"
  type        = string
  default     = ""
}

variable "monitored_keyvault_id" {
  description = "Key Vault resource ID to monitor"
  type        = string
  default     = ""
}

variable "monitored_storage_account_id" {
  description = "Storage Account resource ID to monitor"
  type        = string
  default     = ""
}

variable "monitored_nsg_ids" {
  description = "List of NSG resource IDs to monitor"
  type        = list(string)
  default     = []
}

# =============================================================================
# ALERT THRESHOLDS
# =============================================================================

# VM Thresholds
variable "vm_cpu_threshold" {
  description = "CPU percentage threshold for VM alert"
  type        = number
  default     = 80
}

variable "vm_memory_threshold_bytes" {
  description = "Available memory threshold in bytes for VM alert (default 1GB)"
  type        = number
  default     = 1073741824
}

variable "vm_disk_iops_threshold" {
  description = "Disk IOPS threshold for VM alert"
  type        = number
  default     = 500
}

variable "vm_network_threshold_bytes" {
  description = "Network out threshold in bytes for VM alert (default 1GB)"
  type        = number
  default     = 1073741824
}

# AKS Thresholds
variable "aks_cpu_threshold" {
  description = "CPU percentage threshold for AKS alert"
  type        = number
  default     = 80
}

variable "aks_memory_threshold" {
  description = "Memory percentage threshold for AKS alert"
  type        = number
  default     = 80
}

variable "aks_min_node_count" {
  description = "Minimum node count threshold for AKS alert"
  type        = number
  default     = 1
}

variable "aks_pending_pods_threshold" {
  description = "Pending pods threshold for AKS alert"
  type        = number
  default     = 5
}

# SQL Thresholds
variable "sql_dtu_threshold" {
  description = "DTU percentage threshold for SQL alert"
  type        = number
  default     = 80
}

variable "sql_storage_threshold" {
  description = "Storage percentage threshold for SQL alert"
  type        = number
  default     = 80
}

variable "sql_failed_connections_threshold" {
  description = "Failed connections threshold for SQL alert"
  type        = number
  default     = 5
}

# Firewall Thresholds
variable "firewall_health_threshold" {
  description = "Health percentage threshold for Firewall alert"
  type        = number
  default     = 90
}

variable "firewall_throughput_threshold" {
  description = "Throughput threshold in bytes/sec for Firewall alert"
  type        = number
  default     = 1073741824
}

# VPN Gateway Thresholds
variable "vpn_bandwidth_threshold" {
  description = "Bandwidth threshold in bytes/sec for VPN alert"
  type        = number
  default     = 104857600
}
