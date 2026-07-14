# =============================================================================
# PRODUCTION-LIKE LAB ENVIRONMENT CONFIGURATION
# =============================================================================
# Demonstrates stronger controls and a fuller topology. This remains a
# disposable learning profile and is not a production-ready landing zone.
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

# Lab-sized VMs
vm_size = "Standard_B2s"

# AKS - production-like topology with lab-sized nodes
aks_node_count = 2
aks_vm_size    = "Standard_B2s"

# Auto-shutdown disabled in prod
enable_auto_shutdown = false

# Safer ingress and PaaS defaults for the production-like profile.
appgw_waf_mode             = "Prevention"
enable_jumpbox_public_ip   = false
allowed_jumpbox_source_ips = []
allowed_rdp_source_ips     = []
deploy_private_dns_zones   = true
deploy_private_endpoints   = true

# HA for identity
deploy_secondary_dc = true

# Full logging
log_retention_days = 30
log_daily_quota_gb = 5
