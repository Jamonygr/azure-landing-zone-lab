# =============================================================================
# PROD ENVIRONMENT CONFIGURATION
# =============================================================================
# Full enterprise deployment for production
# =============================================================================

# General
environment = "prod"
project     = "azlab"
location    = "West Europe"
owner       = "Platform-Team"

# Full deployment
deploy_firewall          = true
deploy_vpn_gateway       = true
deploy_onprem_simulation = true

# All workloads
deploy_workload_prod = true
deploy_workload_dev  = false # No dev in prod
deploy_aks           = true

# Production VMs
vm_size     = "Standard_B2s"
sql_vm_size = "Standard_B2ms"

# AKS - Production ready
aks_node_count = 2
aks_vm_size    = "Standard_B2s"

# Auto-shutdown disabled in prod
enable_auto_shutdown = false

# HA for identity
deploy_secondary_dc = true

# Full logging
log_retention_days = 30
log_daily_quota_gb = 5
