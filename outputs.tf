# =============================================================================
# ROOT OUTPUTS (5-pillar layout)
# =============================================================================

# -----------------------------------------------------------------------------
# Networking (Hub)
# -----------------------------------------------------------------------------

output "hub_vnet_id" {
  description = "Hub VNet ID"
  value       = module.networking.vnet_id
}

output "hub_firewall_private_ip" {
  description = "Azure Firewall private IP"
  value       = var.deploy_firewall ? module.networking.firewall_private_ip : null
}

output "hub_firewall_public_ip" {
  description = "Azure Firewall public IP"
  value       = var.deploy_firewall ? module.networking.firewall_public_ip : null
}

output "hub_vpn_gateway_public_ip" {
  description = "Hub VPN Gateway public IP"
  value       = var.deploy_vpn_gateway ? module.networking.vpn_gateway_public_ip : null
}

output "application_gateway_public_ip" {
  description = "Application Gateway public IP"
  value       = var.deploy_application_gateway ? module.networking.application_gateway_public_ip : null
}

# -----------------------------------------------------------------------------
# Identity
# -----------------------------------------------------------------------------

output "identity_vnet_id" {
  description = "Identity VNet ID"
  value       = module.identity.vnet_id
}

output "domain_controller_ips" {
  description = "Domain Controller IP addresses"
  value       = module.identity.dns_servers
}

# -----------------------------------------------------------------------------
# Management
# -----------------------------------------------------------------------------

output "management_vnet_id" {
  description = "Management VNet ID"
  value       = module.management.vnet_id
}

output "jumpbox_private_ip" {
  description = "Jump box private IP"
  value       = module.management.jumpbox_private_ip
}

output "jumpbox_public_ip" {
  description = "Jump box public IP"
  value       = module.management.jumpbox_public_ip
}

output "log_analytics_workspace_id" {
  description = "Log Analytics Workspace ID"
  value       = module.management.log_analytics_workspace_id
}

output "log_analytics_workspace_guid" {
  description = "Log Analytics Workspace GUID"
  value       = module.management.log_analytics_workspace_guid
}

# -----------------------------------------------------------------------------
# Security (Shared Services)
# -----------------------------------------------------------------------------

output "shared_services_vnet_id" {
  description = "Shared services VNet ID"
  value       = module.security.vnet_id
}

output "keyvault_uri" {
  description = "Key Vault URI"
  value       = module.security.keyvault_uri
}

output "storage_account_name" {
  description = "Storage Account name"
  value       = module.security.storage_account_name
}

output "sql_server_fqdn" {
  description = "SQL Server FQDN"
  value       = module.security.sql_server_fqdn
}

# -----------------------------------------------------------------------------
# Workloads
# -----------------------------------------------------------------------------

output "workload_prod_vnet_id" {
  description = "Workload Prod VNet ID"
  value       = var.deploy_workload_prod ? module.workload_prod[0].vnet_id : null
}

output "workload_dev_vnet_id" {
  description = "Workload Dev VNet ID"
  value       = var.deploy_workload_dev ? module.workload_dev[0].vnet_id : null
}

output "aks_cluster_name" {
  description = "AKS Cluster Name"
  value       = var.deploy_workload_prod && var.deploy_aks ? module.workload_prod[0].aks_name : null
}

output "aks_cluster_fqdn" {
  description = "AKS Cluster FQDN"
  value       = var.deploy_workload_prod && var.deploy_aks ? module.workload_prod[0].aks_fqdn : null
}

output "lb_frontend_ip" {
  description = "Load Balancer public IP address (web entrypoint)"
  value       = var.deploy_workload_prod && var.deploy_load_balancer ? module.workload_prod[0].lb_frontend_ip : null
}

output "lb_web_server_ips" {
  description = "Private IPs of web servers behind the load balancer"
  value       = var.deploy_workload_prod && var.deploy_load_balancer ? module.workload_prod[0].web_server_ips : []
}

# -----------------------------------------------------------------------------
# On-Premises Simulation
# -----------------------------------------------------------------------------

output "onprem_vnet_id" {
  description = "On-Premises simulated VNet ID"
  value       = var.deploy_onprem_simulation ? module.onprem[0].vnet_id : null
}

output "onprem_vpn_gateway_public_ip" {
  description = "On-Premises VPN Gateway public IP"
  value       = var.deploy_onprem_simulation ? module.onprem[0].vpn_gateway_public_ip : null
}

output "onprem_mgmt_vm_public_ip" {
  description = "On-Premises management VM public IP (RDP)"
  value       = var.deploy_onprem_simulation ? module.onprem[0].mgmt_vm_public_ip : null
}

output "onprem_mgmt_vm_private_ip" {
  description = "On-Premises management VM private IP"
  value       = var.deploy_onprem_simulation ? module.onprem[0].mgmt_vm_private_ip : null
}

# -----------------------------------------------------------------------------
# VPN Connectivity
# -----------------------------------------------------------------------------

output "hub_local_network_gateway_id" {
  description = "Local Network Gateway in the hub pointing to on-prem"
  value       = var.deploy_onprem_simulation && var.deploy_vpn_gateway ? module.lng_to_onprem[0].id : null
}

output "onprem_local_network_gateway_id" {
  description = "Local Network Gateway in on-prem pointing to the hub"
  value       = var.deploy_onprem_simulation && var.deploy_vpn_gateway ? module.onprem[0].lng_to_hub_id : null
}

output "vpn_connection_hub_to_onprem_id" {
  description = "Site-to-site VPN connection ID from hub to on-prem"
  value       = var.deploy_onprem_simulation && var.deploy_vpn_gateway ? module.vpn_connection_hub_to_onprem[0].id : null
}

output "vpn_connection_onprem_to_hub_id" {
  description = "Site-to-site VPN connection ID from on-prem to hub"
  value       = var.deploy_onprem_simulation && var.deploy_vpn_gateway ? module.onprem[0].vpn_connection_to_hub_id : null
}

# -----------------------------------------------------------------------------
# Backup and Automation
# -----------------------------------------------------------------------------

output "recovery_services_vault_id" {
  description = "Recovery Services Vault ID"
  value       = var.deploy_backup ? module.management.recovery_services_vault_id : null
}

output "recovery_services_vault_name" {
  description = "Recovery Services Vault name"
  value       = var.deploy_backup ? module.management.recovery_services_vault_name : null
}

output "automation_account_name" {
  description = "Automation Account name for scheduled start/stop"
  value       = var.enable_scheduled_startstop ? module.management.automation_account_name : null
}

# -----------------------------------------------------------------------------
# Connection Info (summary)
# -----------------------------------------------------------------------------

output "connection_info" {
  description = "Quick connection summary"
  value       = <<-EOT
    Jump box:      ${module.management.jumpbox_private_ip}${var.enable_jumpbox_public_ip ? " (public: ${module.management.jumpbox_public_ip})" : ""}
    DC01:          ${var.dc01_ip_address}
    DC02:          ${var.dc02_ip_address}
    Firewall IP:   ${var.deploy_firewall ? module.networking.firewall_private_ip : "not deployed"}
    VPN gateway:   ${var.deploy_vpn_gateway ? module.networking.vpn_gateway_public_ip : "not deployed"}
    On-prem VPN:   ${var.deploy_onprem_simulation ? module.onprem[0].vpn_gateway_public_ip : "not deployed"}
    Credentials:   ${var.admin_username} / <password from tfvars>
  EOT
}
