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

  location_short = lookup(local.location_short_map, lower(var.location), substr(lower(replace(var.location, " ", "")), 0, 4))

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
