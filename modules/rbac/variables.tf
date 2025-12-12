# =============================================================================
# RBAC CUSTOM ROLES MODULE - VARIABLES
# =============================================================================

variable "deploy_network_operator_role" {
  description = "Deploy Network Operator custom role"
  type        = bool
  default     = true
}

variable "deploy_backup_operator_role" {
  description = "Deploy Backup Operator custom role"
  type        = bool
  default     = true
}

variable "deploy_monitoring_reader_role" {
  description = "Deploy Monitoring Reader custom role"
  type        = bool
  default     = true
}

# -----------------------------------------------------------------------------
# Role Assignments (Optional)
# -----------------------------------------------------------------------------

variable "network_operator_principals" {
  description = "List of principal IDs to assign Network Operator role"
  type        = list(string)
  default     = []
}

variable "backup_operator_principals" {
  description = "List of principal IDs to assign Backup Operator role"
  type        = list(string)
  default     = []
}

variable "monitoring_reader_principals" {
  description = "List of principal IDs to assign Monitoring Reader role"
  type        = list(string)
  default     = []
}
