# Variables reference

<p align="center">
  <img src="../images/reference-variables.svg" alt="Variables reference banner" width="1000" />
</p>


This page summarizes the root input variables you set in `terraform.tfvars`. The variables are organized by the 5-pillar architecture. For full definitions and defaults, see `variables.tf`.

## Context and basics

| Variable | Type | Description | Default |
|----------|------|-------------|---------|
| `subscription_id` | string | Azure subscription to deploy into | **Required** |
| `project` | string | Project name for resource naming | `azlab` |
| `environment` | string | Environment identifier | `lab` |
| `location` | string | Azure region | `West Europe` |
| `owner` | string | Owner tag value | `Lab-User` |
| `repository_url` | string | Git repository URL for tags | GitHub URL |

## Authentication and credentials

| Variable | Type | Description | Sensitive |
|----------|------|-------------|-----------|
| `admin_username` | string | Local admin for VMs | No |
| `admin_password` | string | VM admin password | Yes |
| `sql_admin_login` | string | SQL Server admin username | No |
| `sql_admin_password` | string | SQL Server admin password | Yes |
| `vpn_shared_key` | string | Pre-shared key for VPN tunnels | Yes |

## Network address spaces

### Hub (Pillar 1: Networking)
- `hub_address_space` – Hub VNet CIDR (default: `10.0.0.0/16`)
- `hub_gateway_subnet_prefix` – VPN Gateway subnet (default: `10.0.0.0/24`)
- `hub_firewall_subnet_prefix` – Azure Firewall subnet (default: `10.0.1.0/24`)
- `hub_mgmt_subnet_prefix` – Hub management subnet (default: `10.0.2.0/24`)
- `hub_appgw_subnet_prefix` – Application Gateway subnet (default: `10.0.3.0/24`)
- `vpn_client_address_pool` – P2S VPN client pool (default: `172.16.0.0/24`)

### Identity (Pillar 2: Identity Management)
- `identity_address_space` – Identity VNet CIDR (default: `10.1.0.0/16`)
- `identity_dc_subnet_prefix` – DC subnet (default: `10.1.1.0/24`)
- `dc01_ip_address` – DC01 static IP (default: `10.1.1.4`)
- `dc02_ip_address` – DC02 static IP (default: `10.1.1.5`)

### Management (Pillar 5: Management)
- `management_address_space` – Management VNet CIDR (default: `10.2.0.0/16`)
- `management_jumpbox_subnet_prefix` – Jumpbox subnet (default: `10.2.1.0/24`)

### Shared Services (Pillar 4: Security)
- `shared_address_space` – Shared services VNet CIDR (default: `10.3.0.0/16`)
- `shared_app_subnet_prefix` – Application subnet (default: `10.3.1.0/24`)
- `shared_pe_subnet_prefix` – Private Endpoint subnet (default: `10.3.2.0/24`)

### Workloads (Pillar 5: Management/Workload)
- `workload_prod_address_space` – Prod VNet CIDR (default: `10.10.0.0/16`)
- `workload_prod_web_subnet_prefix`, `workload_prod_app_subnet_prefix`, `workload_prod_data_subnet_prefix`
- `workload_prod_container_apps_subnet_prefix` – Container Apps subnet (default: `10.10.8.0/23`)
- `aks_subnet_prefix` – AKS node pool subnet (default: `10.10.16.0/20`)
- `workload_dev_address_space` – Dev VNet CIDR (default: `10.11.0.0/16`)

### On-Premises Simulation
- `onprem_address_space` – On-prem VNet CIDR (default: `10.100.0.0/16`)
- `onprem_gateway_subnet_prefix`, `onprem_servers_subnet_prefix`
- `onprem_bgp_asn` – BGP ASN (default: `65050`)
- `allowed_rdp_source_ips` – IPs allowed to RDP to on-prem VM

## Feature flags by pillar

### Pillar 1: Networking
| Flag | Default | Description | Est. Cost |
|------|---------|-------------|-----------|
| `deploy_firewall` | `true` | Azure Firewall | ~$300/mo |
| `firewall_sku_tier` | `Standard` | Firewall SKU | - |
| `deploy_vpn_gateway` | `false` | VPN Gateway | ~$140/mo |
| `vpn_gateway_sku` | `VpnGw1` | VPN Gateway SKU | - |
| `enable_bgp` | `false` | Enable BGP routing | - |
| `hub_bgp_asn` | `65515` | Hub BGP ASN | - |
| `deploy_application_gateway` | `true` | Application Gateway with WAF | ~$36/mo |
| `appgw_waf_mode` | `Detection` | WAF mode (Detection/Prevention) | - |

### Pillar 2: Identity Management
| Flag | Default | Description | Est. Cost |
|------|---------|-------------|-----------|
| `deploy_secondary_dc` | `false` | Second Domain Controller | ~$30/mo |

### Pillar 3: Governance
| Flag | Default | Description |
|------|---------|-------------|
| `deploy_management_groups` | `true` | Management Group hierarchy |
| `management_group_root_name` | `Organization` | Root MG display name |
| `management_group_root_id` | `org-root` | Root MG ID |
| `deploy_azure_policy` | `true` | Azure Policy assignments |
| `policy_allowed_locations` | `[list]` | Allowed Azure regions |
| `policy_required_tags` | `{map}` | Required tags for resources |
| `enable_audit_public_network_access` | `true` | Audit public access |
| `enable_require_https_storage` | `true` | Require HTTPS for storage |
| `enable_require_nsg_on_subnet` | `true` | Require NSG on subnets |
| `deploy_cost_management` | `true` | Budget and cost alerts |
| `cost_budget_amount` | `1000` | Monthly budget in USD |
| `cost_alert_emails` | `[]` | Alert email recipients |
| `deploy_regulatory_compliance` | `true` | HIPAA/PCI-DSS policies |
| `enable_hipaa_compliance` | `false` | Enable HIPAA initiative |
| `enable_pci_dss_compliance` | `false` | Enable PCI-DSS initiative |
| `compliance_enforcement_mode` | `DoNotEnforce` | Audit only by default |
| `deploy_rbac_custom_roles` | `true` | Custom RBAC roles |

### Pillar 4: Security (Shared Services)
| Flag | Default | Description | Est. Cost |
|------|---------|-------------|-----------|
| `deploy_keyvault` | `true` | Azure Key Vault | ~$3/mo |
| `deploy_storage` | `true` | Storage Account | ~$5/mo |
| `deploy_sql` | `true` | Azure SQL Database | ~$5/mo |
| `deploy_private_dns_zones` | `true` | Private DNS for Private Link | Minimal |
| `deploy_private_endpoints` | `true` | Private Endpoints for PaaS | None |

### Pillar 5: Management
| Flag | Default | Description | Est. Cost |
|------|---------|-------------|-----------|
| `enable_jumpbox_public_ip` | `false` | Public IP for jumpbox | ~$3/mo |
| `allowed_jumpbox_source_ips` | `[]` | IPs allowed to RDP | - |
| `deploy_log_analytics` | `true` | Log Analytics workspace | ~$10/mo |
| `log_retention_days` | `30` | Log retention | - |
| `log_daily_quota_gb` | `1` | Daily ingestion limit | - |
| `deploy_backup` | `true` | Recovery Services Vault | ~$10/mo |
| `backup_storage_redundancy` | `LocallyRedundant` | Backup redundancy | - |
| `deploy_workbooks` | `true` | Azure Workbooks | Free |
| `deploy_connection_monitor` | `true` | Connection Monitor | ~$1/mo |
| `enable_scheduled_startstop` | `true` | VM start/stop automation | ~$1/mo |
| `startstop_timezone` | `America/New_York` | Timezone for schedules | - |

### Workloads
| Flag | Default | Description | Est. Cost |
|------|---------|-------------|-----------|
| `deploy_workload_prod` | `true` | Production workload VNet | - |
| `deploy_workload_dev` | `false` | Development workload VNet | - |
| `deploy_onprem_simulation` | `false` | Simulated on-premises | ~$60/mo |
| `deploy_load_balancer` | `true` | Load Balancer + IIS VMs | ~$55/mo |
| `lb_type` | `public` | Load balancer type | - |
| `lb_web_server_count` | `2` | Number of web servers | - |
| `lb_web_server_size` | `Standard_B1ms` | Web server VM size | - |
| `deploy_aks` | `false` | Azure Kubernetes Service | ~$30+/mo |

### PaaS Services
| Flag | Default | Description | Est. Cost |
|------|---------|-------------|-----------|
| `deploy_functions` | `true` | Azure Functions (Consumption) | Free |
| `deploy_static_web_app` | `true` | Static Web Apps | Free |
| `deploy_logic_apps` | `true` | Logic Apps (Consumption) | ~$0 |
| `deploy_event_grid` | `true` | Event Grid | Free (100k) |
| `deploy_service_bus` | `true` | Service Bus (Basic) | ~$0.05/mo |
| `deploy_app_service` | `true` | App Service (F1) | Free |
| `deploy_cosmos_db` | `true` | Cosmos DB (Serverless) | ~$0-5/mo |
| `deploy_container_apps` | `false` | Container Apps (placeholder) | - |
| `paas_alternative_location` | `westus2` | Alternate region for PaaS | - |
| `cosmos_location` | `""` | Override for Cosmos DB region | - |

### Network Extensions
| Flag | Default | Description |
|------|---------|-------------|
| `deploy_nat_gateway` | `true` | NAT Gateway for fixed outbound IP |
| `deploy_application_security_groups` | `false` | ASGs for micro-segmentation |
| `enable_vnet_flow_logs` | `true` | VNet flow logs (replaces NSG flow logs) |
| `enable_traffic_analytics` | `true` | Traffic Analytics |
| `create_network_watcher` | `true` | Create Network Watcher if missing |
| `network_watcher_name` | `null` | Name of existing Network Watcher |
| `nsg_flow_logs_retention_days` | `7` | Flow log retention |

## VM sizing

| Variable | Default | Description |
|----------|---------|-------------|
| `vm_size` | `Standard_B2s` | Default VM size (DCs, jumpbox) |
| `sql_vm_size` | `Standard_B2s` | SQL VM size |
| `enable_auto_shutdown` | `true` | Auto-shutdown VMs at 7 PM |
| `aks_node_count` | `1` | AKS node count |
| `aks_vm_size` | `Standard_B2s` | AKS node size |

## Related pages

- [Configuration flow](../architecture/configuration-flow.md)
- [Current lab configuration (lab profile)](current-config.md)
- [Outputs reference](outputs.md)
