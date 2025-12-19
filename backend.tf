# =============================================================================
# TERRAFORM BACKEND CONFIGURATION
# =============================================================================
# Azure Storage backend for remote state management
# Configure via -backend-config flags in CI/CD or uncomment and fill values
# Updated: 2025-12-16 - Pipeline trigger
# =============================================================================

# NOTE: For local development, use local backend (comment out the azurerm block below)
# For CI/CD or remote state, uncomment and configure the azurerm backend

# terraform {
#   backend "azurerm" {
#     # These values are provided via -backend-config in CI/CD pipeline
#     # resource_group_name  = "rg-terraform-state"
#     # storage_account_name = "stterraformstateXXXX"
#     # container_name       = "tfstate"
#     # key                  = "lab.terraform.tfstate"
#     # use_azuread_auth = true
#   }
# }

# =============================================================================
# BACKEND SETUP INSTRUCTIONS
# =============================================================================
# 
# 1. Create the storage account for Terraform state:
#
#    # PowerShell
#    $RESOURCE_GROUP = "rg-terraform-state"
#    $LOCATION = "westus2"
#    $STORAGE_ACCOUNT = "stterraformstate$(Get-Random -Maximum 9999)"
#    
#    az group create --name $RESOURCE_GROUP --location $LOCATION
#    
#    az storage account create `
#      --name $STORAGE_ACCOUNT `
#      --resource-group $RESOURCE_GROUP `
#      --sku Standard_LRS `
#      --encryption-services blob `
#      --min-tls-version TLS1_2
#    
#    az storage container create `
#      --name tfstate `
#      --account-name $STORAGE_ACCOUNT
#
# 2. Add these GitHub Secrets:
#    - TF_STATE_RG: rg-terraform-state
#    - TF_STATE_SA: <your-storage-account-name>
#
# 3. The CI/CD pipeline will configure the backend automatically using:
#    terraform init \
#      -backend-config="resource_group_name=$TF_STATE_RG" \
#      -backend-config="storage_account_name=$TF_STATE_SA" \
#      -backend-config="container_name=tfstate" \
#      -backend-config="key=<environment>.terraform.tfstate"
#
# =============================================================================
