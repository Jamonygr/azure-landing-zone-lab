# =============================================================================
# MANAGEMENT GROUPS MODULE - OUTPUTS
# =============================================================================

# -----------------------------------------------------------------------------
# Root Management Group
# -----------------------------------------------------------------------------
output "root_management_group_id" {
  description = "The ID of the root management group"
  value       = azurerm_management_group.root.id
}

output "root_management_group_name" {
  description = "The name of the root management group"
  value       = azurerm_management_group.root.name
}

# -----------------------------------------------------------------------------
# Platform Management Groups
# -----------------------------------------------------------------------------
output "platform_management_group_id" {
  description = "The ID of the Platform management group"
  value       = var.create_platform_mg ? azurerm_management_group.platform[0].id : null
}

output "platform_identity_management_group_id" {
  description = "The ID of the Platform > Identity management group"
  value       = var.create_platform_mg ? azurerm_management_group.platform_identity[0].id : null
}

output "platform_management_management_group_id" {
  description = "The ID of the Platform > Management management group"
  value       = var.create_platform_mg ? azurerm_management_group.platform_management[0].id : null
}

output "platform_connectivity_management_group_id" {
  description = "The ID of the Platform > Connectivity management group"
  value       = var.create_platform_mg ? azurerm_management_group.platform_connectivity[0].id : null
}

# -----------------------------------------------------------------------------
# Landing Zones Management Groups
# -----------------------------------------------------------------------------
output "landing_zones_management_group_id" {
  description = "The ID of the Landing Zones management group"
  value       = var.create_landing_zones_mg ? azurerm_management_group.landing_zones[0].id : null
}

output "landing_zones_corp_management_group_id" {
  description = "The ID of the Landing Zones > Corp management group"
  value       = var.create_landing_zones_mg ? azurerm_management_group.landing_zones_corp[0].id : null
}

output "landing_zones_online_management_group_id" {
  description = "The ID of the Landing Zones > Online management group"
  value       = var.create_landing_zones_mg ? azurerm_management_group.landing_zones_online[0].id : null
}

# -----------------------------------------------------------------------------
# Sandbox & Decommissioned Management Groups
# -----------------------------------------------------------------------------
output "sandbox_management_group_id" {
  description = "The ID of the Sandbox management group"
  value       = var.create_sandbox_mg ? azurerm_management_group.sandbox[0].id : null
}

output "decommissioned_management_group_id" {
  description = "The ID of the Decommissioned management group"
  value       = var.create_decommissioned_mg ? azurerm_management_group.decommissioned[0].id : null
}

# -----------------------------------------------------------------------------
# Additional Management Groups
# -----------------------------------------------------------------------------
output "additional_management_group_ids" {
  description = "Map of additional management group names to their IDs"
  value       = { for k, v in azurerm_management_group.additional : k => v.id }
}

# -----------------------------------------------------------------------------
# All Management Groups Summary
# -----------------------------------------------------------------------------
output "all_management_groups" {
  description = "Map of all management group names to their IDs for easy reference"
  value = merge(
    {
      "root" = azurerm_management_group.root.id
    },
    var.create_platform_mg ? {
      "platform"             = azurerm_management_group.platform[0].id
      "platform-identity"    = azurerm_management_group.platform_identity[0].id
      "platform-management"  = azurerm_management_group.platform_management[0].id
      "platform-connectivity" = azurerm_management_group.platform_connectivity[0].id
    } : {},
    var.create_landing_zones_mg ? {
      "landing-zones"      = azurerm_management_group.landing_zones[0].id
      "landing-zones-corp" = azurerm_management_group.landing_zones_corp[0].id
      "landing-zones-online" = azurerm_management_group.landing_zones_online[0].id
    } : {},
    var.create_sandbox_mg ? {
      "sandbox" = azurerm_management_group.sandbox[0].id
    } : {},
    var.create_decommissioned_mg ? {
      "decommissioned" = azurerm_management_group.decommissioned[0].id
    } : {},
    { for k, v in azurerm_management_group.additional : k => v.id }
  )
}
