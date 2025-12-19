# Outputs reference

After `terraform apply`, the root module surfaces key IDs and IPs you can use to connect to the environment or feed into other tools. Outputs are organized by the **5-pillar architecture**.

## Pillar 1: Networking (Hub)

| Output | Description | Condition |
|--------|-------------|-----------|
| `hub_vnet_id` | Hub VNet resource ID for peering | Always |
| `hub_vnet_name` | Hub VNet name | Always |
| `hub_firewall_private_ip` | Firewall's private IP (next hop for spokes) | `deploy_firewall` |
| `hub_firewall_public_ip` | Firewall's public IP for egress | `deploy_firewall` |
| `hub_vpn_gateway_public_ip` | VPN Gateway public IP | `deploy_vpn_gateway` |
| `appgw_public_ip` | Application Gateway frontend IP | `deploy_application_gateway` |
| `appgw_fqdn` | Application Gateway FQDN | `deploy_application_gateway` |

## Pillar 2: Identity Management

| Output | Description | Condition |
|--------|-------------|-----------|
| `identity_vnet_id` | Identity VNet resource ID | Always |
| `domain_controller_ips` | List of DC private IPs (DNS servers) | Always |

## Pillar 3: Governance

Governance outputs are currently embedded in the governance module. The module manages:
- Management Group IDs
- Policy Assignment IDs
- Budget IDs
- Custom Role Definition IDs

## Pillar 4: Security (Shared Services)

| Output | Description | Condition |
|--------|-------------|-----------|
| `shared_services_vnet_id` | Shared Services VNet resource ID | Always |
| `keyvault_uri` | Key Vault URI for secrets | `deploy_keyvault` |
| `keyvault_name` | Key Vault name | `deploy_keyvault` |
| `storage_account_name` | Storage account name | `deploy_storage` |
| `sql_server_fqdn` | SQL Server FQDN | `deploy_sql` |

## Pillar 5: Management

| Output | Description | Condition |
|--------|-------------|-----------|
| `management_vnet_id` | Management VNet resource ID | Always |
| `jumpbox_private_ip` | Jumpbox private IP | Always |
| `jumpbox_public_ip` | Jumpbox public IP | `enable_jumpbox_public_ip` |
| `log_analytics_workspace_id` | Log Analytics workspace ID | `deploy_log_analytics` |
| `log_analytics_workspace_name` | Log Analytics workspace name | `deploy_log_analytics` |
| `recovery_services_vault_id` | Backup vault ID | `deploy_backup` |
| `recovery_services_vault_name` | Backup vault name | `deploy_backup` |

## Workload Outputs

| Output | Description | Condition |
|--------|-------------|-----------|
| `workload_prod_vnet_id` | Production workload VNet ID | `deploy_workload_prod` |
| `workload_dev_vnet_id` | Development workload VNet ID | `deploy_workload_dev` |
| `lb_frontend_ip` | Load Balancer frontend IP | `deploy_load_balancer` |
| `lb_web_server_ips` | List of web server private IPs | `deploy_load_balancer` |
| `aks_cluster_name` | AKS cluster name | `deploy_aks` |
| `aks_cluster_fqdn` | AKS API server FQDN | `deploy_aks` |

## On-premises simulation

| Output | Description | Condition |
|--------|-------------|-----------|
| `onprem_vnet_id` | On-prem VNet resource ID | `deploy_onprem_simulation` |
| `onprem_vpn_gateway_public_ip` | On-prem VPN Gateway public IP | `deploy_onprem_simulation` |
| `onprem_mgmt_vm_public_ip` | On-prem VM public IP | `deploy_onprem_simulation` |
| `onprem_mgmt_vm_private_ip` | On-prem VM private IP | `deploy_onprem_simulation` |

## VPN connectivity objects

| Output | Description | Condition |
|--------|-------------|-----------|
| `hub_local_network_gateway_id` | Hub LNG for on-prem connection | `deploy_onprem_simulation && deploy_vpn_gateway` |
| `onprem_local_network_gateway_id` | On-prem LNG for hub connection | `deploy_onprem_simulation && deploy_vpn_gateway` |
| `vpn_connection_hub_to_onprem_id` | Hub → On-prem VPN connection | `deploy_onprem_simulation && deploy_vpn_gateway` |
| `vpn_connection_onprem_to_hub_id` | On-prem → Hub VPN connection | `deploy_onprem_simulation && deploy_vpn_gateway` |

## Connection info banner

The `connection_info` output provides a multi-line summary for quick reference after deployment:

```hcl
output "connection_info" {
  value = <<-EOT
    ========================================
    CONNECTION INFORMATION
    ========================================
    Jumpbox Private IP:    ${jumpbox_private_ip}
    Jumpbox Public IP:     ${jumpbox_public_ip}
    VPN Gateway IP:        ${vpn_gateway_ip}
    Firewall Public IP:    ${firewall_public_ip}
    Application Gateway:   ${appgw_url}
    Log Analytics:         ${log_analytics_workspace}
    ========================================
  EOT
}
```

Use this as a quick checklist after deployment to verify connectivity.
