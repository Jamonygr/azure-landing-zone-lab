# =============================================================================
# TERRAFORM BACKEND CONFIGURATION
# =============================================================================
# Azure Storage backend for remote state management
# Configure via -backend-config flags in CI/CD.
# =============================================================================

# NOTE:
# - CI/CD uses the Azure Storage backend and supplies values via -backend-config.
# - Local development can still run `terraform init -backend=false` for validate,
#   or provide matching -backend-config values when applying.

terraform {
  backend "azurerm" {}
}

# The hardened bootstrap, OIDC subjects, recovery procedure, and required
# GitHub secrets are documented in .github/SETUP.md.
