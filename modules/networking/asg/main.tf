# =============================================================================
# APPLICATION SECURITY GROUP MODULE - MAIN
# Zero Trust micro-segmentation by application role
# =============================================================================

resource "azurerm_application_security_group" "this" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags
}
