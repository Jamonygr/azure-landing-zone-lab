# =============================================================================
# NAMING CONVENTION MODULE - VARIABLES
# =============================================================================

variable "project" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Environment (lab, dev, prod)"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "instance" {
  description = "Instance number"
  type        = string
  default     = "001"
}
