# =============================================================================
# DEV ENVIRONMENT CONFIGURATION
# =============================================================================
# Cost-optimized settings for development/testing
# =============================================================================

# General
environment = "dev"
project     = "azlab"
location    = "West Europe"
owner       = "DevTeam"

# Cost Optimization - Minimal deployment
deploy_firewall          = false # Save ~$300/month
deploy_vpn_gateway       = false # Save ~$140/month
deploy_onprem_simulation = false # Save ~$140/month

# Deploy only essential components
deploy_workload_prod = false
deploy_workload_dev  = true
deploy_aks           = true

# Smaller VMs for dev
vm_size     = "Standard_B2s"
sql_vm_size = "Standard_B2s"

# AKS - Minimal for dev
aks_node_count = 1
aks_vm_size    = "Standard_B2s"

# Auto-shutdown enabled
enable_auto_shutdown = true

# No secondary DC in dev
deploy_secondary_dc = false

# Reduced logging (Azure Log Analytics minimum retention is 30 days)
log_retention_days = 30
log_daily_quota_gb = 0.5
