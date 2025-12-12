# Outputs reference

After `terraform apply`, the root module surfaces key IDs and IPs you can use to connect to the environment or feed into other tools.

## Hub

- `hub_vnet_id` – for peering and diagnostics.  
- `hub_firewall_private_ip` / `hub_firewall_public_ip` – next hop for spokes and egress testing (conditional on firewall).  
- `hub_vpn_gateway_public_ip` – endpoint for VPN connections (conditional on gateway).

## Identity

- `identity_vnet_id` – for peering.  
- `domain_controller_ips` – DNS servers used by every other landing zone.

## Management

- `management_vnet_id` – for peering.  
- `jumpbox_private_ip` and `jumpbox_public_ip` – administrator entry points.  
- `log_analytics_workspace_id` – shared destination for diagnostics.

## Shared services

- `shared_services_vnet_id` – for peering.  
- `keyvault_uri`, `storage_account_name`, `sql_server_fqdn` – endpoints for application secrets and data.

## Workload

- `workload_prod_vnet_id` and `workload_dev_vnet_id` (when deployed).  
- `lb_frontend_ip` and `lb_web_server_ips` when the load balancer is enabled.  
- `aks_cluster_name` and `aks_cluster_fqdn` when AKS is deployed.

## On-premises simulation

- `onprem_vnet_id` – for peering and diagnostics.  
- `onprem_vpn_gateway_public_ip` – useful for testing the tunnel.  
- `onprem_mgmt_vm_public_ip` / `onprem_mgmt_vm_private_ip` – RDP endpoints for the simulated site.

## VPN connectivity objects

- `hub_local_network_gateway_id` and `onprem_local_network_gateway_id`.  
- `vpn_connection_hub_to_onprem_id` and `vpn_connection_onprem_to_hub_id`.

## Connection info banner

`connection_info` is a multi-line output summarizing how to reach the jumpbox, VPN endpoint, firewall, and web app. Use it as a quick checklist after deployment.
