# Variables reference

This page summarizes the root input variables you set in `terraform.tfvars`. For full definitions and defaults, see `variables.tf`.

## Context and basics

- `subscription_id` – Azure subscription to deploy into (required).  
- `project`, `environment` – naming prefixes; default to `azlab` and `lab`.  
- `location` – Azure region (for example, `westeurope`).  
- `owner`, `repository_url` – used in tags for traceability.

## Authentication and credentials

- `admin_username` / `admin_password` – local admin for VMs.  
- `sql_admin_login` / `sql_admin_password` – SQL admin credentials.  
- `vpn_shared_key` – pre-shared key for VPN tunnels (required if VPN is on).

## Network address spaces

- Hub: `hub_address_space`, `hub_gateway_subnet_prefix`, `hub_firewall_subnet_prefix`, `hub_mgmt_subnet_prefix`, `hub_appgw_subnet_prefix`.  
- Identity: `identity_address_space`, `identity_dc_subnet_prefix`, `dc01_ip_address`, `dc02_ip_address`.  
- Management: `management_address_space`, `management_jumpbox_subnet_prefix`.  
- Shared services: `shared_address_space`, `shared_app_subnet_prefix`, `shared_pe_subnet_prefix`.  
- Workloads: `workload_prod_address_space` and `workload_dev_address_space` with web/app/data prefixes, plus `aks_subnet_prefix`.  
- On-premises simulation: `onprem_address_space`, `onprem_gateway_subnet_prefix`, `onprem_servers_subnet_prefix`, `onprem_bgp_asn`.

## Feature flags (major switches)

- Platform: `deploy_firewall`, `deploy_vpn_gateway`, `deploy_onprem_simulation`.  
- Identity: `deploy_secondary_dc`.  
- Management: `enable_jumpbox_public_ip`, `allowed_jumpbox_source_ips` (CIDRs allowed to RDP when the jumpbox has a public IP), `deploy_log_analytics`.  
- Shared services: `deploy_keyvault`, `deploy_storage`, `deploy_sql`.  
- Workloads: `deploy_workload_prod`, `deploy_workload_dev`, `deploy_load_balancer`, `deploy_application_gateway`, `deploy_aks`.  
- PaaS options: `deploy_functions`, `deploy_static_web_app`, `deploy_logic_apps`, `deploy_event_grid`, `deploy_service_bus`, `deploy_app_service`, `deploy_cosmos_db`, `deploy_container_apps` (placeholder flag), and `paas_alternative_location`.

## Network extensions

- `deploy_nat_gateway` - assigns a static outbound IP for the workload web subnet.  
- `deploy_private_dns_zones` - central Private DNS zones for blob, Key Vault, and SQL Private Link.  
- `deploy_private_endpoints` - creates Private Endpoints for Key Vault, Storage, and SQL (requires Private DNS zones).  
- `deploy_application_security_groups` - creates ASGs for workload web/app/data tiers to simplify NSG rules.  
- `enable_vnet_flow_logs` - VNet-level flow logs (requires storage and a Network Watcher in the region).  
- `enable_traffic_analytics` - turns on Traffic Analytics (requires `deploy_log_analytics = true` and storage).
- `create_network_watcher` - create the NetworkWatcherRG/Network Watcher if your subscription doesn't have one yet.

## VM and workload sizing

- `vm_size`, `sql_vm_size`, `enable_auto_shutdown`.  
- Load balancer: `lb_type`, `lb_private_ip`, `lb_web_server_count`, `lb_web_server_size`.  
- AKS: `aks_node_count`, `aks_vm_size`, `aks_subnet_prefix`.

## Monitoring

- `log_retention_days` and `log_daily_quota_gb` control workspace cost.  
- `deploy_log_analytics` determines whether diagnostics are enabled for dependent services.

## Naming and tags

`locals.tf` builds names and the shared `common_tags` map using `project`, `environment`, and `location_short`. Adjust the inputs above to change how resources are labelled across the platform.
