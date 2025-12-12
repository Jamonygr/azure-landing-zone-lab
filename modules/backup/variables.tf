# =============================================================================
# AZURE BACKUP MODULE - VARIABLES
# =============================================================================

variable "vault_name" {
  description = "Name of the Recovery Services Vault"
  type        = string
}

variable "location" {
  description = "Azure region"
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

variable "soft_delete_enabled" {
  description = "Enable soft delete for backup items"
  type        = bool
  default     = true
}

variable "storage_mode_type" {
  description = "Storage replication type (GeoRedundant, LocallyRedundant, ZoneRedundant)"
  type        = string
  default     = "LocallyRedundant"
}

variable "policy_name_prefix" {
  description = "Prefix for backup policy names"
  type        = string
  default     = "policy"
}

variable "timezone" {
  description = "Timezone for backup schedule"
  type        = string
  default     = "UTC"
}

variable "backup_time" {
  description = "Time of day for backups (HH:MM format)"
  type        = string
  default     = "02:00"
}

variable "daily_retention_days" {
  description = "Number of days to retain daily backups"
  type        = number
  default     = 7
}

variable "weekly_retention_weeks" {
  description = "Number of weeks to retain weekly backups"
  type        = number
  default     = 4
}

variable "monthly_retention_months" {
  description = "Number of months to retain monthly backups"
  type        = number
  default     = 3
}

variable "protected_vms" {
  description = "List of VMs to protect with backup"
  type = list(object({
    name     = string
    id       = string
    critical = optional(bool, false)
  }))
  default = []
}
