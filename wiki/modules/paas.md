# PaaS modules

<p align="center">
  <img src="../images/modules-paas.svg" alt="PaaS modules banner" width="1000" />
</p>


These modules provision popular Azure platform services used by the workload landing zone. They are sized for labs and can be toggled individually. Most use the lowest-cost SKUs to minimize spend.

## Module summary by tier

| Tier | Services | Est. Monthly Cost |
|------|----------|-------------------|
| **Tier 1 – Compute** | AKS, Functions, Static Web App, App Service, Logic Apps, Container Apps | Free - $30 |
| **Tier 2 – Integration** | Event Grid, Service Bus, Event Hubs, API Management | Free - $5 |
| **Tier 3 – Data** | Cosmos DB, Storage, SQL | $0 - $15 |

## Tier 1 – Compute

### AKS (`modules/aks/`)

Creates an Azure Kubernetes Service cluster with minimal node count.

| Input | Description | Default |
|-------|-------------|---------|
| `name` | Cluster name | Required |
| `resource_group` | Resource group | Required |
| `location` | Azure region | Required |
| `dns_prefix` | DNS prefix | Required |
| `subnet_id` | AKS node subnet ID | Required |
| `node_count` | Default node pool count | `1` |
| `vm_size` | Node VM size | `Standard_B2s` |
| `sku_tier` | AKS SKU tier | `Free` |
| `network_plugin` | Network plugin | `azure` |
| `private_cluster_enabled` | Private API server | `false` |
| `workspace_id` | Log Analytics workspace | `null` |

**Outputs:** `aks_id`, `aks_name`, `aks_fqdn`  
**Cost:** ~$30/month (1 node)

### Functions (`modules/functions/`)

Creates a consumption-based Azure Functions app with Application Insights.

| Input | Description | Default |
|-------|-------------|---------|
| `name_suffix` | Name suffix | Required |
| `resource_group` | Resource group | Required |
| `location` | Azure region | Required |
| `os_type` | Operating system | `Windows` |
| `runtime_stack` | Runtime (dotnet, node, python) | `dotnet` |
| `runtime_version` | Runtime version | `v4.0` |
| `enable_app_insights` | Enable App Insights | `true` |

**Outputs:** `function_app_name`, `function_app_id`  
**Cost:** Free (Consumption tier, 1M executions/month)

### Static Web App (`modules/static-web-app/`)

Creates a free-tier Static Web App.

| Input | Description | Default |
|-------|-------------|---------|
| `name_suffix` | Name suffix | Required |
| `resource_group` | Resource group | Required |
| `location` | Azure region | Required |
| `sku_tier` | SKU tier | `Free` |
| `sku_size` | SKU size | `Free` |

**Outputs:** `static_web_app_name`, `static_web_app_id`  
**Cost:** Free

### App Service (`modules/app-service/`)

Creates an App Service plan and web app.

| Input | Description | Default |
|-------|-------------|---------|
| `name_suffix` | Name suffix | Required |
| `resource_group` | Resource group | Required |
| `location` | Azure region | Required |
| `sku_tier` | Plan SKU tier | `Free` |
| `sku_size` | Plan SKU size | `F1` |
| `os_type` | Operating system | `Windows` |

**Outputs:** `app_service_plan_id`, `web_app_name`  
**Cost:** Free (F1 tier, 60 min CPU/day)

### Logic Apps (`modules/logic-apps/`)

Creates a logic app workflow in consumption mode.

| Input | Description | Default |
|-------|-------------|---------|
| `name_suffix` | Name suffix | Required |
| `resource_group` | Resource group | Required |
| `location` | Azure region | Required |
| `workflow_type` | Workflow type | `Stateless` |

**Outputs:** `logic_app_id`  
**Cost:** ~$0 (pay per execution)

### Container Apps (`modules/container-apps/` - placeholder)

Creates a Container Apps Environment and Container App.

| Input | Description | Default |
|-------|-------------|---------|
| `name_suffix` | Name suffix | Required |
| `resource_group` | Resource group | Required |
| `location` | Azure region | Required |
| `workspace_id` | Log Analytics workspace | Required |
| `cpu` | CPU allocation | `0.25` |
| `memory` | Memory allocation | `0.5Gi` |

**Outputs:** `container_app_id`, `environment_id`  
**Cost:** ~$0 (Consumption, pay per use)

## Tier 2 – Integration

### Event Grid (`modules/event-grid/`)

Creates an Event Grid topic.

| Input | Description | Default |
|-------|-------------|---------|
| `name_suffix` | Name suffix | Required |
| `resource_group` | Resource group | Required |
| `location` | Azure region | Required |
| `input_schema` | Event schema | `EventGridSchema` |

**Outputs:** `topic_id`, `topic_endpoint`  
**Cost:** Free (first 100,000 operations/month)

### Service Bus (`modules/service-bus/`)

Creates a Basic tier Service Bus namespace.

| Input | Description | Default |
|-------|-------------|---------|
| `name_suffix` | Name suffix | Required |
| `resource_group` | Resource group | Required |
| `location` | Azure region | Required |
| `sku` | Service Bus SKU | `Basic` |

**Outputs:** `namespace_id`, `namespace_name`  
**Cost:** ~$0.05/month

## Tier 3 – Data

### Cosmos DB (`modules/cosmos-db/`)

Creates a serverless Cosmos DB account.

| Input | Description | Default |
|-------|-------------|---------|
| `name_suffix` | Name suffix | Required |
| `resource_group` | Resource group | Required |
| `location` | Azure region | Required |
| `account_kind` | Account type | `GlobalDocumentDB` |
| `capabilities` | Account capabilities | `EnableServerless` |
| `consistency_level` | Consistency level | `Session` |

**Outputs:** `cosmos_account_id`, `cosmos_endpoint`  
**Cost:** ~$0-5/month (pay per RU)

### Storage (`modules/storage/`)

Creates a storage account.

| Input | Description | Default |
|-------|-------------|---------|
| `name` | Account name | Required |
| `resource_group` | Resource group | Required |
| `location` | Azure region | Required |
| `account_tier` | Storage tier | `Standard` |
| `replication_type` | Redundancy | `LRS` |

**Outputs:** `storage_account_id`, `storage_account_name`  
**Cost:** ~$5/month

### SQL (`modules/sql/`)

Creates a SQL Server and database.

| Input | Description | Default |
|-------|-------------|---------|
| `name_suffix` | Name suffix | Required |
| `resource_group` | Resource group | Required |
| `location` | Azure region | Required |
| `admin_login` | Admin username | Required |
| `admin_password` | Admin password | Required |
| `sku_name` | Database SKU | `Basic` |

**Outputs:** `sql_server_id`, `sql_server_fqdn`, `database_id`  
**Cost:** ~$5/month (Basic tier)

## Usage patterns

### Full PaaS stack
```hcl
deploy_functions      = true
deploy_static_web_app = true
deploy_logic_apps     = true
deploy_event_grid     = true
deploy_service_bus    = true
deploy_app_service    = true
deploy_cosmos_db      = true
deploy_aks            = true
```

### Free tier only
```hcl
deploy_functions      = true   # Free consumption
deploy_static_web_app = true   # Free tier
deploy_app_service    = true   # F1 free tier
deploy_event_grid     = true   # 100k free
deploy_aks            = false  # Node cost
deploy_cosmos_db      = false  # RU cost
```

## Related pages

- [Workload landing zone](../landing-zones/workload.md)
- [Variables reference](../reference/variables.md)
- [Architecture overview](../architecture/overview.md)
