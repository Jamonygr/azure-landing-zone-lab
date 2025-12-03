# =============================================================================
# NAMING CONVENTION MODULE - MAIN
# Azure CAF Naming Standards
# =============================================================================

locals {
  # Location short codes
  location_short = {
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

  loc = lookup(local.location_short, lower(var.location), substr(lower(replace(var.location, " ", "")), 0, 4))

  # Base prefix for naming
  prefix = "${var.project}-${var.environment}-${local.loc}"
}
