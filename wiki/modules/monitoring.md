# Monitoring modules

Monitoring in the lab is built from small modules that create a workspace, action groups, metric alerts, diagnostic settings, workbooks, and connection monitors. These are part of **Pillar 5: Management** and provide observability across the entire landing zone.

## Module summary

| Module | Purpose | Cost |
|--------|---------|------|
| Log Analytics | Centralized logging | ~$10/month |
| Action Group | Alert notifications | Free |
| Alerts | Metric-based alerts | Free (50 rules) |
| Diagnostic Settings | Route logs to workspace | Free |
| Workbooks | Visualization dashboards | Free |
| NSG Flow Logs | NSG traffic capture (legacy) | ~$5/month |
| VNet Flow Logs | VNet traffic capture (modern) | ~$5/month |
| Connection Monitor | Network connectivity testing | ~$1/month |

## Log Analytics (`modules/monitoring/log-analytics/`)

Creates a Log Analytics workspace for centralized logging.

| Input | Description | Default |
|-------|-------------|---------|
| `name` | Workspace name | Required |
| `resource_group` | Resource group | Required |
| `location` | Azure region | Required |
| `sku` | Workspace SKU | `PerGB2018` |
| `retention_days` | Log retention | `30` |
| `daily_quota_gb` | Daily ingestion limit | `1` |

**Outputs:** `workspace_id`, `workspace_name`

## Action group (`modules/monitoring/action-group/`)

Creates an alert action group with email receivers for notifications.

| Input | Description | Default |
|-------|-------------|---------|
| `name` | Action group name | Required |
| `resource_group` | Resource group | Required |
| `short_name` | Short name (12 char max) | Required |
| `email_receivers` | List of email addresses | `[]` |

**Outputs:** `action_group_id`

## Alerts (`modules/monitoring/alerts/`)

Creates metric alerts for VMs, AKS, and Azure Firewall based on feature flags.

| Input | Description | Default |
|-------|-------------|---------|
| `resource_group` | Resource group | Required |
| `name_prefix` | Alert name prefix | Required |
| `action_group_id` | Action group for notifications | Required |
| `enable_vm_alerts` | Enable VM CPU alerts | `false` |
| `vm_ids` | List of VM resource IDs | `[]` |
| `vm_cpu_threshold` | CPU percentage threshold | `80` |
| `enable_aks_alerts` | Enable AKS alerts | `false` |
| `enable_firewall_alerts` | Enable Firewall alerts | `false` |

**Outputs:** `vm_alert_ids`, `aks_alert_ids`, `firewall_alert_ids`

## Diagnostic settings (`modules/monitoring/diagnostic-settings/`)

Applies diagnostic settings to route logs to Log Analytics.

| Input | Description | Default |
|-------|-------------|---------|
| `name_prefix` | Diagnostic setting name prefix | Required |
| `workspace_id` | Log Analytics workspace ID | Required |
| `firewall_id` | Firewall resource ID | `null` |
| `vpn_gateway_id` | VPN Gateway resource ID | `null` |
| `aks_id` | AKS cluster resource ID | `null` |
| `sql_server_id` | SQL Server resource ID | `null` |
| `keyvault_id` | Key Vault resource ID | `null` |
| `storage_account_id` | Storage account resource ID | `null` |

**Outputs:** `diagnostic_setting_ids`

## Workbooks (`modules/monitoring/workbooks/`)

Creates Azure Workbooks for visualization and monitoring dashboards.

| Input | Description | Default |
|-------|-------------|---------|
| `name` | Workbook name | Required |
| `resource_group` | Resource group | Required |
| `location` | Azure region | Required |
| `workspace_id` | Log Analytics workspace ID | Required |
| `workbook_type` | Type of workbook template | `network` |

**Outputs:** `workbook_id`

## VNet Flow Logs (`modules/monitoring/vnet-flow-logs/`)

Modern replacement for NSG flow logs, captures traffic at the VNet level.

| Input | Description | Default |
|-------|-------------|---------|
| `name` | Flow log name | Required |
| `network_watcher_name` | Network Watcher name | Required |
| `network_watcher_rg` | Network Watcher resource group | Required |
| `vnet_id` | VNet resource ID | Required |
| `storage_account_id` | Storage for flow logs | Required |
| `retention_days` | Flow log retention | `7` |
| `enable_traffic_analytics` | Enable Traffic Analytics | `true` |
| `workspace_id` | Log Analytics workspace ID | Required if TA enabled |

**Outputs:** `flow_log_id`

## Connection Monitor (`modules/monitoring/connection-monitor/`)

Tests network connectivity between endpoints.

| Input | Description | Default |
|-------|-------------|---------|
| `name` | Connection monitor name | Required |
| `network_watcher_id` | Network Watcher ID | Required |
| `source_vm_id` | Source VM resource ID | Required |
| `destination_address` | Destination IP or FQDN | Required |
| `destination_port` | Port to test | `443` |
| `test_frequency_sec` | Test interval | `60` |

**Outputs:** `connection_monitor_id`

## Usage patterns

### Enable full observability
```hcl
deploy_log_analytics     = true
deploy_workbooks         = true
deploy_connection_monitor = true
enable_vnet_flow_logs    = true
enable_traffic_analytics = true
```

### Cost-optimized monitoring
```hcl
deploy_log_analytics     = true
log_retention_days       = 7
log_daily_quota_gb       = 0.5
deploy_workbooks         = false
enable_vnet_flow_logs    = false
```
