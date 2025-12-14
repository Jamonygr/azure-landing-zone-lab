# =============================================================================
# OUTPUTS
# =============================================================================

# -----------------------------------------------------------------------------
# Hub Outputs
# -----------------------------------------------------------------------------

output "hub_vnet_id" {
  description = "Hub VNet ID"
  value       = module.hub.vnet_id
}

output "hub_firewall_private_ip" {
  description = "Azure Firewall private IP"
  value       = var.deploy_firewall ? module.hub.firewall_private_ip : null
}

output "hub_firewall_public_ip" {
  description = "Azure Firewall public IP"
  value       = var.deploy_firewall ? module.hub.firewall_public_ip : null
}

output "hub_vpn_gateway_public_ip" {
  description = "Hub VPN Gateway public IP"
  value       = var.deploy_vpn_gateway ? module.hub.vpn_gateway_public_ip : null
}

# -----------------------------------------------------------------------------
# Identity Outputs
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
# Management Outputs
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

# -----------------------------------------------------------------------------
# Shared Services Outputs
# -----------------------------------------------------------------------------

output "shared_services_vnet_id" {
  description = "Shared Services VNet ID"
  value       = module.shared_services.vnet_id
}

output "keyvault_uri" {
  description = "Key Vault URI"
  value       = module.shared_services.keyvault_uri
}

output "storage_account_name" {
  description = "Storage Account name"
  value       = module.shared_services.storage_account_name
}

output "sql_server_fqdn" {
  description = "SQL Server FQDN"
  value       = module.shared_services.sql_server_fqdn
}

# -----------------------------------------------------------------------------
# Workload Outputs
# -----------------------------------------------------------------------------

output "workload_prod_vnet_id" {
  description = "Workload Prod VNet ID"
  value       = var.deploy_workload_prod ? module.workload_prod[0].vnet_id : null
}

output "workload_dev_vnet_id" {
  description = "Workload Dev VNet ID"
  value       = var.deploy_workload_dev ? module.workload_dev[0].vnet_id : null
}

# -----------------------------------------------------------------------------
# AKS Outputs
# -----------------------------------------------------------------------------

output "aks_cluster_name" {
  description = "AKS Cluster Name"
  value       = var.deploy_workload_prod && var.deploy_aks ? module.workload_prod[0].aks_name : null
}

output "aks_cluster_fqdn" {
  description = "AKS Cluster FQDN"
  value       = var.deploy_workload_prod && var.deploy_aks ? module.workload_prod[0].aks_fqdn : null
}

# -----------------------------------------------------------------------------
# Load Balancer Outputs
# -----------------------------------------------------------------------------

output "lb_frontend_ip" {
  description = "Load Balancer public IP address (access web servers here)"
  value       = var.deploy_workload_prod && var.deploy_load_balancer ? module.workload_prod[0].lb_frontend_ip : null
}

output "lb_web_server_ips" {
  description = "Private IP addresses of web servers behind load balancer"
  value       = var.deploy_workload_prod && var.deploy_load_balancer ? module.workload_prod[0].web_server_ips : []
}

# -----------------------------------------------------------------------------
# On-Premises Outputs
# -----------------------------------------------------------------------------

output "onprem_vnet_id" {
  description = "On-Premises VNet ID"
  value       = var.deploy_onprem_simulation ? module.onprem[0].vnet_id : null
}

output "onprem_vpn_gateway_public_ip" {
  description = "On-Premises VPN Gateway public IP"
  value       = var.deploy_onprem_simulation ? module.onprem[0].vpn_gateway_public_ip : null
}

output "onprem_mgmt_vm_public_ip" {
  description = "On-Premises Management VM public IP (RDP access point)"
  value       = var.deploy_onprem_simulation ? module.onprem[0].mgmt_vm_public_ip : null
}

output "onprem_mgmt_vm_private_ip" {
  description = "On-Premises Management VM private IP"
  value       = var.deploy_onprem_simulation ? module.onprem[0].mgmt_vm_private_ip : null
}

# -----------------------------------------------------------------------------
# VPN Connectivity (Gateways, LNGs, Connections)
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
# Connection Information
# -----------------------------------------------------------------------------

output "connection_info" {
  description = "Connection information for the lab"
  value       = <<-EOT
    
    ╔═══════════════════════════════════════════════════════════════════════════╗
    ║                    AZURE LANDING ZONE LAB - CONNECTION INFO               ║
    ╠═══════════════════════════════════════════════════════════════════════════╣
    ║                                                                           ║
    ║  🔐 Access Methods:                                                       ║
    ║     1. VPN: Connect via Point-to-Site VPN (configure in Azure Portal)    ║
    ║     2. Jump Box: ${var.enable_jumpbox_public_ip ? "RDP to public IP" : "Access via VPN or Bastion"}                                ║
    ║                                                                           ║
    ║  📍 Key IP Addresses:                                                     ║
    ║     Jump Box:     ${module.management.jumpbox_private_ip}                                          ║
    ║     DC01:         ${var.dc01_ip_address}                                          ║
    ║     DC02:         ${var.dc02_ip_address}                                          ║
    ${var.deploy_firewall ? "║     Firewall:     Check firewall_private_ip output                       ║" : ""}
    ║                                                                           ║
    ║  🔑 Default Credentials:                                                  ║
    ║     Username: ${var.admin_username}                                              ║
    ║     Password: <from terraform.tfvars>                                     ║
    ║                                                                           ║
    ║  📚 Documentation:                                                        ║
    ║     See README.md for detailed instructions                               ║
    ║                                                                           ║
    ╚═══════════════════════════════════════════════════════════════════════════╝
    
  EOT
}

# -----------------------------------------------------------------------------
# Backup Outputs
# -----------------------------------------------------------------------------

output "recovery_services_vault_id" {
  description = "Recovery Services Vault ID"
  value       = var.deploy_backup ? module.backup[0].vault_id : null
}

output "recovery_services_vault_name" {
  description = "Recovery Services Vault Name"
  value       = var.deploy_backup ? module.backup[0].vault_name : null
}

# -----------------------------------------------------------------------------
# Automation Outputs
# -----------------------------------------------------------------------------

output "automation_account_name" {
  description = "Automation Account name for scheduled start/stop"
  value       = var.enable_scheduled_startstop ? module.automation[0].automation_account_name : null
}
