# Current lab configuration (lab profile)

This page summarizes the active `terraform.tfvars` profile in the repo so you know what will deploy and how to reach it.

For the full list of feature flags, see the **MASTER CONTROL PANEL** section at the top of `terraform.tfvars`.

## What's on

- Region: **westus2**.
- Networking: **Hub/spoke topology** with Azure Firewall (**Standard**) enabled.
- Jumpbox: **Public IP enabled**; RDP allowed from `allowed_jumpbox_source_ips` (currently `0.0.0.0/0` in `terraform.tfvars` — tighten to your IP/CIDR).
- Application delivery: **Public Load Balancer** with two IIS web VMs and NAT RDP rules.
- App Gateway: **Enabled** (`deploy_application_gateway = true`).
- Shared services: **Key Vault + Storage + Azure SQL** enabled; **Private DNS + Private Endpoints** enabled.
- Observability: Log Analytics workspace enabled (`log_retention_days = 30`, `log_daily_quota_gb = 2`).
- Network extensions: **NAT Gateway** enabled; **Application Security Groups** enabled.
- Workloads: both **prod** and **dev** workload zones deployed.
- PaaS (enabled): Static Web App, Logic Apps, Event Grid, Service Bus, App Service, Cosmos DB.

## What's off

- VPN gateway and on-prem simulation (no VPN entry path).
- AKS.
- Azure Functions.
- Backup.
- VNet Flow Logs and Traffic Analytics.

## Access path

- RDP to the jumpbox public IP after `terraform apply` (`terraform output -raw jumpbox_public_ip`).
- Traffic is allowed based on `allowed_jumpbox_source_ips`; set this to your public IP/CIDR before broad use.

## Key caveats and recommendations

- Restrict `allowed_jumpbox_source_ips` from `0.0.0.0/0` to your IP range as soon as possible.
- If you prefer no public exposure, set `enable_jumpbox_public_ip = false` and enable `deploy_vpn_gateway`, then connect via VPN.
- Cost alerts use `cost_alert_emails`; replace `your-email@example.com` with your real address.

## Quick flag snapshot (from `terraform.tfvars`)

### Core infrastructure
- `deploy_firewall = true`, `deploy_vpn_gateway = false`, `deploy_onprem_simulation = false`
- `enable_jumpbox_public_ip = true`, `allowed_jumpbox_source_ips = ["0.0.0.0/0"]`
- `deploy_load_balancer = true`, `deploy_application_gateway = true`, `deploy_aks = false`

### Shared services
- `deploy_keyvault = true`, `deploy_storage = true`, `deploy_sql = true`
- `deploy_private_dns_zones = true`, `deploy_private_endpoints = true`

### Network extensions & observability
- `deploy_nat_gateway = true`
- `deploy_application_security_groups = true`
- `create_network_watcher = false`, `enable_vnet_flow_logs = false`, `enable_traffic_analytics = false`

### PaaS services
- `deploy_functions = false`
- `deploy_static_web_app = true`, `deploy_logic_apps = true`, `deploy_event_grid = true`
- `deploy_service_bus = true`, `deploy_app_service = true`, `deploy_cosmos_db = true`
