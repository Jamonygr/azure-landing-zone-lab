# Current lab configuration (Full PaaS deployment, VPN off, public jumpbox)

This page summarizes the active `terraform.tfvars` profile so you know what will deploy and how to reach it.

## What's on

- Region: **East US**; hub/spoke VNets with Azure Firewall (Standard) enabled.
- Jumpbox: **Public IP enabled**, NSG allows RDP from `allowed_jumpbox_source_ips` (currently `0.0.0.0/0` in `terraform.tfvars` — tighten to your IP/CIDR).
- Load balancer: **Public LB** with two IIS web VMs and NAT RDP rules.
- Shared services: Key Vault, Storage **on**; Private Endpoints and Private DNS **on**.
- PaaS: **All services enabled** — Functions, Static Web App, Logic Apps, Event Grid, Service Bus, App Service (F1), Cosmos DB, Container Apps, Event Hubs, API Management (Consumption). Some run in alternate regions (Functions/App Service in `ukwest`, Static Web App in `eastus2`, Cosmos in `westus2`) to avoid quotas.
- Observability: Log Analytics workspace **on** (`log_retention_days = 30`, `log_daily_quota_gb = 1`).
- Network features: NAT Gateway, VNet Flow Logs, Traffic Analytics, Application Security Groups **enabled**.
- Workload environments: Both **prod** and **dev** workload zones deployed.

## What's off

- VPN gateway and on-prem simulation **off** (no VPN entry path).
- Application Gateway **off** (backend IPs not wired).
- AKS **off**; secondary DC **off**; Azure SQL **off**.

## Access path

- RDP to the jumpbox public IP after `terraform apply` (`terraform output -raw jumpbox_public_ip`).
- Traffic is allowed based on `allowed_jumpbox_source_ips`; set this to your public IP/CIDR before broad use.

## Key caveats and recommendations

- Restrict `allowed_jumpbox_source_ips` from `0.0.0.0/0` to your IP range as soon as possible.
- If you prefer no public exposure, re-enable `deploy_vpn_gateway` and set `enable_jumpbox_public_ip = false`, then connect via VPN.
- Monitoring/diagnostic settings are not auto-enabled for all resources unless you turn on the monitoring features in the management module; enable them if you need platform alerts/logs.
- With firewall on and VPN off, outbound flows from spokes use the firewall SNAT; inbound RDP relies solely on the jumpbox public IP.

## Quick flag snapshot (from `terraform.tfvars`)

### Core infrastructure
- `deploy_firewall = true`, `deploy_vpn_gateway = false`, `deploy_onprem_simulation = false`
- `enable_jumpbox_public_ip = true`, `allowed_jumpbox_source_ips = ["0.0.0.0/0"]`
- `deploy_load_balancer = true`, `deploy_application_gateway = false`, `deploy_aks = false`

### Shared services
- `deploy_keyvault = true`, `deploy_storage = true`, `deploy_sql = false`
- `deploy_workload_prod = true`, `deploy_workload_dev = true`

### Network features
- `deploy_nat_gateway = true`
- `deploy_private_dns_zones = true`, `deploy_private_endpoints = true`
- `deploy_application_security_groups = true`
- `enable_vnet_flow_logs = true`, `enable_traffic_analytics = true`
- `create_network_watcher = true`

### PaaS services (Tier 1 - Compute)
- `deploy_functions = true`, `deploy_static_web_app = true`, `deploy_logic_apps = true`
- `deploy_container_apps = true`, `deploy_app_service = true`

### PaaS services (Tier 2 - Integration)
- `deploy_event_grid = true`, `deploy_service_bus = true`
- `deploy_event_hubs = true`, `deploy_api_management = true`

### PaaS services (Tier 3 - Data)
- `deploy_cosmos_db = true`
