# =============================================================================
# LOCAL VALUES
# =============================================================================

locals {
  # Environment configuration
  environment = var.environment
  project     = var.project

  # Location short codes
  location_short_map = {
    "westeurope"         = "weu"
    "northeurope"        = "neu"
    "eastus"             = "eus"
    "eastus2"            = "eus2"
    "westus"             = "wus"
    "westus2"            = "wus2"
    "centralus"          = "cus"
    "uksouth"            = "uks"
    "ukwest"             = "ukw"
    "germanywestcentral" = "gwc"
  }

  # Normalize region names so values like "West Europe" resolve to expected short codes
  normalized_location = lower(replace(var.location, " ", ""))
  location_short      = lookup(local.location_short_map, local.normalized_location, substr(local.normalized_location, 0, 4))

  # Common tags applied to all resources
  common_tags = {
    Environment = var.environment
    Project     = var.project
    ManagedBy   = "Terraform"
    Purpose     = "Azure Landing Zone Lab"
    Owner       = var.owner
    CostCenter  = "Learning"
    Repository  = var.repository_url
  }
}
