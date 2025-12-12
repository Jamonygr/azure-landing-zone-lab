# =============================================================================
# MANAGEMENT GROUPS MODULE - MAIN
# Creates CAF-aligned management group hierarchy
# =============================================================================
#
# Hierarchy Structure:
#   Tenant Root Group
#   └── Organization (Root)
#       ├── Platform
#       │   ├── Identity
#       │   ├── Management  
#       │   └── Connectivity
#       ├── Landing Zones
#       │   ├── Corp
#       │   └── Online
#       ├── Sandbox
#       └── Decommissioned
#
# =============================================================================

# -----------------------------------------------------------------------------
# Root Management Group
# -----------------------------------------------------------------------------
resource "azurerm_management_group" "root" {
  name                       = var.root_management_group_id
  display_name               = var.root_management_group_name
  parent_management_group_id = var.parent_management_group_id
}

# -----------------------------------------------------------------------------
# Platform Management Group (L2)
# -----------------------------------------------------------------------------
resource "azurerm_management_group" "platform" {
  count = var.create_platform_mg ? 1 : 0

  name                       = "${var.root_management_group_id}-platform"
  display_name               = "Platform"
  parent_management_group_id = azurerm_management_group.root.id
}

# Platform > Identity
resource "azurerm_management_group" "platform_identity" {
  count = var.create_platform_mg ? 1 : 0

  name                       = "${var.root_management_group_id}-platform-identity"
  display_name               = "Identity"
  parent_management_group_id = azurerm_management_group.platform[0].id
}

# Platform > Management
resource "azurerm_management_group" "platform_management" {
  count = var.create_platform_mg ? 1 : 0

  name                       = "${var.root_management_group_id}-platform-management"
  display_name               = "Management"
  parent_management_group_id = azurerm_management_group.platform[0].id
}

# Platform > Connectivity
resource "azurerm_management_group" "platform_connectivity" {
  count = var.create_platform_mg ? 1 : 0

  name                       = "${var.root_management_group_id}-platform-connectivity"
  display_name               = "Connectivity"
  parent_management_group_id = azurerm_management_group.platform[0].id
}

# -----------------------------------------------------------------------------
# Landing Zones Management Group (L2)
# -----------------------------------------------------------------------------
resource "azurerm_management_group" "landing_zones" {
  count = var.create_landing_zones_mg ? 1 : 0

  name                       = "${var.root_management_group_id}-landing-zones"
  display_name               = "Landing Zones"
  parent_management_group_id = azurerm_management_group.root.id
}

# Landing Zones > Corp (internal/private workloads)
resource "azurerm_management_group" "landing_zones_corp" {
  count = var.create_landing_zones_mg ? 1 : 0

  name                       = "${var.root_management_group_id}-landing-zones-corp"
  display_name               = "Corp"
  parent_management_group_id = azurerm_management_group.landing_zones[0].id
}

# Landing Zones > Online (public-facing workloads)
resource "azurerm_management_group" "landing_zones_online" {
  count = var.create_landing_zones_mg ? 1 : 0

  name                       = "${var.root_management_group_id}-landing-zones-online"
  display_name               = "Online"
  parent_management_group_id = azurerm_management_group.landing_zones[0].id
}

# -----------------------------------------------------------------------------
# Sandbox Management Group (L2)
# -----------------------------------------------------------------------------
resource "azurerm_management_group" "sandbox" {
  count = var.create_sandbox_mg ? 1 : 0

  name                       = "${var.root_management_group_id}-sandbox"
  display_name               = "Sandbox"
  parent_management_group_id = azurerm_management_group.root.id
}

# -----------------------------------------------------------------------------
# Decommissioned Management Group (L2)
# -----------------------------------------------------------------------------
resource "azurerm_management_group" "decommissioned" {
  count = var.create_decommissioned_mg ? 1 : 0

  name                       = "${var.root_management_group_id}-decommissioned"
  display_name               = "Decommissioned"
  parent_management_group_id = azurerm_management_group.root.id
}

# -----------------------------------------------------------------------------
# Additional Custom Management Groups
# -----------------------------------------------------------------------------
resource "azurerm_management_group" "additional" {
  for_each = { for mg in var.additional_management_groups : mg.name => mg }

  name                       = each.value.name
  display_name               = each.value.display_name
  parent_management_group_id = azurerm_management_group.root.id
}

# -----------------------------------------------------------------------------
# Subscription Associations - Platform
# -----------------------------------------------------------------------------
resource "azurerm_management_group_subscription_association" "platform_identity" {
  for_each = var.create_platform_mg ? toset(var.subscription_ids_platform_identity) : toset([])

  management_group_id = azurerm_management_group.platform_identity[0].id
  subscription_id     = "/subscriptions/${each.value}"
}

resource "azurerm_management_group_subscription_association" "platform_management" {
  for_each = var.create_platform_mg ? toset(var.subscription_ids_platform_management) : toset([])

  management_group_id = azurerm_management_group.platform_management[0].id
  subscription_id     = "/subscriptions/${each.value}"
}

resource "azurerm_management_group_subscription_association" "platform_connectivity" {
  for_each = var.create_platform_mg ? toset(var.subscription_ids_platform_connectivity) : toset([])

  management_group_id = azurerm_management_group.platform_connectivity[0].id
  subscription_id     = "/subscriptions/${each.value}"
}

# -----------------------------------------------------------------------------
# Subscription Associations - Landing Zones
# -----------------------------------------------------------------------------
resource "azurerm_management_group_subscription_association" "landing_zones_corp" {
  for_each = var.create_landing_zones_mg ? toset(var.subscription_ids_landing_zones_corp) : toset([])

  management_group_id = azurerm_management_group.landing_zones_corp[0].id
  subscription_id     = "/subscriptions/${each.value}"
}

resource "azurerm_management_group_subscription_association" "landing_zones_online" {
  for_each = var.create_landing_zones_mg ? toset(var.subscription_ids_landing_zones_online) : toset([])

  management_group_id = azurerm_management_group.landing_zones_online[0].id
  subscription_id     = "/subscriptions/${each.value}"
}

# -----------------------------------------------------------------------------
# Subscription Associations - Sandbox & Decommissioned
# -----------------------------------------------------------------------------
resource "azurerm_management_group_subscription_association" "sandbox" {
  for_each = var.create_sandbox_mg ? toset(var.subscription_ids_sandbox) : toset([])

  management_group_id = azurerm_management_group.sandbox[0].id
  subscription_id     = "/subscriptions/${each.value}"
}

resource "azurerm_management_group_subscription_association" "decommissioned" {
  for_each = var.create_decommissioned_mg ? toset(var.subscription_ids_decommissioned) : toset([])

  management_group_id = azurerm_management_group.decommissioned[0].id
  subscription_id     = "/subscriptions/${each.value}"
}

# Subscription associations for additional management groups
resource "azurerm_management_group_subscription_association" "additional" {
  for_each = merge([
    for mg in var.additional_management_groups : {
      for sub_id in mg.subscription_ids : "${mg.name}-${sub_id}" => {
        mg_name = mg.name
        sub_id  = sub_id
      }
    }
  ]...)

  management_group_id = azurerm_management_group.additional[each.value.mg_name].id
  subscription_id     = "/subscriptions/${each.value.sub_id}"
}
