# =============================================================================
# MANAGEMENT PILLAR - VARIABLES
# Wraps management landing zone (jumpbox, Log Analytics) plus monitoring,
# diagnostics, backup, workbooks, connection monitor, and automation.
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
  description = "Short code for Azure region"
  type        = string
}

variable "resource_group_name" {
  description = "Resource group for management resources"
  type        = string
}

variable "tags" {
  description = "Common tags"
  type        = map(string)
}

# -----------------------------------------------------------------------------
# Networking
# -----------------------------------------------------------------------------

variable "mgmt_address_space" {
  description = "Management VNet address space"
  type        = list(string)
}

variable "jumpbox_subnet_prefix" {
  description = "Jumpbox subnet prefix"
  type        = string
}

variable "dns_servers" {
  description = "DNS servers for management VNet"
  type        = list(string)
  default     = []
}

variable "hub_address_prefix" {
  description = "Hub address prefix for NSG rules"
  type        = string
}

variable "vpn_client_address_pool" {
  description = "VPN client address pool"
  type        = string
}

variable "onprem_address_prefix" {
  description = "On-premises address prefix"
  type        = string
}

variable "allowed_jumpbox_source_ips" {
  description = "Allowed public IPs for jumpbox RDP"
  type        = list(string)
  default     = []
}

variable "firewall_private_ip" {
  description = "Firewall private IP for route table next hop"
  type        = string
  default     = null
}

variable "deploy_route_table" {
  description = "Deploy route table for management subnet"
  type        = bool
}

# -----------------------------------------------------------------------------
# Jumpbox/VM
# -----------------------------------------------------------------------------

variable "vm_size" {
  description = "Jumpbox VM size"
  type        = string
}

variable "admin_username" {
  description = "Admin username"
  type        = string
}

variable "admin_password" {
  description = "Admin password"
  type        = string
  sensitive   = true
}

variable "enable_jumpbox_public_ip" {
  description = "Enable public IP for jumpbox"
  type        = bool
}

variable "enable_auto_shutdown" {
  description = "Enable auto shutdown"
  type        = bool
}

# -----------------------------------------------------------------------------
# Log Analytics
# -----------------------------------------------------------------------------

variable "deploy_log_analytics" {
  description = "Deploy Log Analytics workspace"
  type        = bool
}

variable "log_retention_days" {
  description = "Log retention days"
  type        = number
}

variable "log_daily_quota_gb" {
  description = "Log Analytics daily quota GB"
  type        = number
}

# -----------------------------------------------------------------------------
# Monitoring and diagnostics
# -----------------------------------------------------------------------------

variable "deploy_monitoring" {
  description = "Deploy monitoring action group/alerts/diagnostics"
  type        = bool
  default     = true
}

variable "alert_email_receivers" {
  description = "Email receivers for alerts"
  type = list(object({
    name          = string
    email_address = string
  }))
  default = [
    {
      name          = "admin"
      email_address = "admin@example.com"
    }
  ]
}

variable "monitored_vm_ids" {
  description = "VM IDs to monitor"
  type        = list(string)
  default     = []
}

variable "monitored_aks_cluster_id" {
  description = "AKS cluster ID to monitor"
  type        = string
  default     = ""
}

variable "monitored_firewall_id" {
  description = "Firewall ID to monitor"
  type        = string
  default     = ""
}

variable "monitored_vpn_gateway_id" {
  description = "VPN gateway ID to monitor"
  type        = string
  default     = ""
}

variable "monitored_sql_database_id" {
  description = "SQL database ID to monitor"
  type        = string
  default     = ""
}

variable "monitored_sql_server_id" {
  description = "SQL server ID to monitor"
  type        = string
  default     = ""
}

variable "monitored_keyvault_id" {
  description = "Key Vault ID to monitor"
  type        = string
  default     = ""
}

variable "monitored_storage_account_id" {
  description = "Storage Account ID to monitor"
  type        = string
  default     = ""
}

variable "monitored_nsg_ids" {
  description = "NSG IDs to monitor"
  type        = list(string)
  default     = []
}

# -----------------------------------------------------------------------------
# Monitoring Enable Flags (use these instead of checking IDs at plan time)
# -----------------------------------------------------------------------------

variable "enable_firewall_monitoring" {
  description = "Enable firewall monitoring (use static boolean instead of checking ID)"
  type        = bool
  default     = false
}

variable "enable_vpn_monitoring" {
  description = "Enable VPN gateway monitoring (use static boolean instead of checking ID)"
  type        = bool
  default     = false
}

# -----------------------------------------------------------------------------
# Alert thresholds
# -----------------------------------------------------------------------------

variable "vm_cpu_threshold" {
  description = "CPU percentage threshold for VM alerts"
  type        = number
  default     = 80
}

variable "vm_memory_threshold_bytes" {
  description = "Available memory threshold (bytes) for VM alerts"
  type        = number
  default     = 1073741824
}

variable "vm_disk_iops_threshold" {
  description = "Disk IOPS threshold for VM alerts"
  type        = number
  default     = 500
}

variable "vm_network_threshold_bytes" {
  description = "Network throughput threshold (bytes) for VM alerts"
  type        = number
  default     = 1073741824
}

variable "aks_cpu_threshold" {
  description = "CPU percentage threshold for AKS alerts"
  type        = number
  default     = 80
}

variable "aks_memory_threshold" {
  description = "Memory percentage threshold for AKS alerts"
  type        = number
  default     = 80
}

variable "aks_min_node_count" {
  description = "Minimum node count threshold for AKS alerts"
  type        = number
  default     = 1
}

variable "aks_pending_pods_threshold" {
  description = "Pending pods threshold for AKS alerts"
  type        = number
  default     = 5
}

variable "sql_dtu_threshold" {
  description = "DTU percentage threshold for SQL alerts"
  type        = number
  default     = 80
}

variable "sql_storage_threshold" {
  description = "Storage percentage threshold for SQL alerts"
  type        = number
  default     = 80
}

variable "sql_failed_connections_threshold" {
  description = "Failed connections threshold for SQL alerts"
  type        = number
  default     = 5
}

variable "firewall_health_threshold" {
  description = "Health percentage threshold for Firewall alerts"
  type        = number
  default     = 90
}

variable "firewall_throughput_threshold" {
  description = "Throughput threshold (bytes/sec) for Firewall alerts"
  type        = number
  default     = 1073741824
}

variable "vpn_bandwidth_threshold" {
  description = "Bandwidth threshold (bytes/sec) for VPN alerts"
  type        = number
  default     = 104857600
}

# -----------------------------------------------------------------------------
# Backup
# -----------------------------------------------------------------------------

variable "deploy_backup" {
  description = "Deploy Recovery Services Vault and protect VMs"
  type        = bool
}

variable "backup_storage_redundancy" {
  description = "Backup storage redundancy"
  type        = string
}

variable "enable_soft_delete" {
  description = "Enable soft delete on the vault"
  type        = bool
}

variable "backup_protected_vms" {
  description = "List of VMs to protect (name, id, critical)"
  type = list(object({
    name     = string
    id       = string
    critical = bool
  }))
  default = []
}

# -----------------------------------------------------------------------------
# Workbooks and Connection Monitor
# -----------------------------------------------------------------------------

variable "deploy_workbooks" {
  description = "Deploy Azure Workbooks"
  type        = bool
}

variable "deploy_connection_monitor" {
  description = "Deploy Connection Monitor"
  type        = bool
}

variable "create_network_watcher" {
  description = "Create Network Watcher if missing"
  type        = bool
}

variable "network_watcher_name" {
  description = "Existing Network Watcher name (optional)"
  type        = string
  default     = null
}

# -----------------------------------------------------------------------------
# Automation (Scheduled start/stop)
# -----------------------------------------------------------------------------

variable "enable_scheduled_startstop" {
  description = "Deploy Automation Account for start/stop"
  type        = bool
}

variable "subscription_id" {
  description = "Subscription ID"
  type        = string
}

variable "startstop_timezone" {
  description = "Timezone for schedules"
  type        = string
}

variable "startstop_start_time" {
  description = "Start time (HH:MM)"
  type        = string
}

variable "startstop_stop_time" {
  description = "Stop time (HH:MM)"
  type        = string
}

variable "resource_group_names_for_automation" {
  description = "Resource groups managed by automation start/stop"
  type        = list(string)
  default     = []
}
