# Alerts Module Variables

variable "resource_group_name" {
  description = "The name of the resource group for the alerts"
  type        = string
}

variable "location" {
  description = "The location/region for the alerts (required for multi-resource alerts)"
  type        = string
  default     = "East US"
}

variable "alert_name_prefix" {
  description = "Prefix for alert names"
  type        = string
  default     = "alert"
}

variable "action_group_id" {
  description = "The ID of the Action Group to send alerts to"
  type        = string
}

variable "alerts_enabled" {
  description = "Whether the alerts are enabled"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags to apply to the alerts"
  type        = map(string)
  default     = {}
}

# =============================================================================
# VM Variables
# =============================================================================

variable "vm_ids" {
  description = "List of VM resource IDs to monitor"
  type        = list(string)
  default     = []
}

variable "enable_vm_alerts" {
  description = "Whether to create VM alerts (avoids unknown count from computed IDs)"
  type        = bool
  default     = false
}

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

# =============================================================================
# AKS Variables
# =============================================================================

variable "aks_cluster_id" {
  description = "AKS cluster resource ID to monitor"
  type        = string
  default     = ""
}

variable "enable_aks_alerts" {
  description = "Whether to create AKS alerts (prevents unknown count errors)"
  type        = bool
  default     = false
}

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

# =============================================================================
# SQL Database Variables
# =============================================================================

variable "sql_database_id" {
  description = "SQL Database resource ID to monitor"
  type        = string
  default     = ""
}

variable "enable_sql_alerts" {
  description = "Whether to create SQL alerts"
  type        = bool
  default     = false
}

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

# =============================================================================
# Firewall Variables
# =============================================================================

variable "firewall_id" {
  description = "Azure Firewall resource ID to monitor"
  type        = string
  default     = ""
}

variable "enable_firewall_alerts" {
  description = "Whether to create Firewall alerts"
  type        = bool
  default     = false
}

variable "firewall_health_threshold" {
  description = "Health percentage threshold for Firewall alert (default 90%)"
  type        = number
  default     = 90
}

variable "firewall_throughput_threshold" {
  description = "Throughput threshold in bytes/sec for Firewall alert (default 1GB/s)"
  type        = number
  default     = 1073741824
}

# =============================================================================
# VPN Gateway Variables
# =============================================================================

variable "vpn_gateway_id" {
  description = "VPN Gateway resource ID to monitor"
  type        = string
  default     = ""
}

variable "enable_vpn_alerts" {
  description = "Whether to create VPN alerts"
  type        = bool
  default     = false
}

variable "vpn_bandwidth_threshold" {
  description = "Bandwidth threshold in bytes/sec for VPN alert (default 100MB/s)"
  type        = number
  default     = 104857600
}
