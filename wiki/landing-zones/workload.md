# Workload landing zone

The workload landing zone is where you try application scenarios. It is managed through the **Management pillar (Pillar 5)** and can be deployed as many times as you like (prod, dev, or both) using the same module. It includes subnets for web, app, and data tiers, plus optional AKS and PaaS services.

## What you will learn

- What the workload zone deploys by default and how to size it for a lab.  
- How load balancing, routing, and NSGs are configured for a simple three-tier app.  
- How to toggle AKS and popular Azure PaaS services on and off.

## What it deploys

| Component | Default | Purpose |
|-----------|---------|---------|
| Workload VNet | Prod: `10.10.0.0/16`, Dev: `10.11.0.0/16` | Application network |
| Web/App/Data Subnets | Created | Three-tier architecture |
| Container Apps Subnet | `10.10.8.0/23` | Azure Container Apps |
| AKS Subnet | `10.10.16.0/20` | Kubernetes nodes |
| NSGs | Per subnet | Traffic filtering |
| Route Tables | Optional | Firewall steering |
| Load Balancer | Public/Internal | Application delivery |
| IIS Web Servers | 2 VMs | Sample web tier |
| NAT Gateway | Optional | Fixed outbound IP |
| PaaS Services | Various | Serverless & managed services |

### Subnet layout (Production)

| Subnet | CIDR | Purpose |
|--------|------|---------|
| Web Subnet | `10.10.1.0/24` | Web tier VMs |
| App Subnet | `10.10.2.0/24` | Application tier |
| Data Subnet | `10.10.3.0/24` | Database tier |
| Container Apps | `10.10.8.0/23` | Azure Container Apps |
| AKS Nodes | `10.10.16.0/20` | Kubernetes nodes |

## Inputs to know about

### Workload configuration

| Variable | Description | Default |
|----------|-------------|---------|
| `deploy_workload_prod` | Deploy production workload | `true` |
| `deploy_workload_dev` | Deploy development workload | `false` |
| `workload_prod_address_space` | Prod VNet CIDR | `10.10.0.0/16` |
| `workload_dev_address_space` | Dev VNet CIDR | `10.11.0.0/16` |

### Load balancer

| Variable | Description | Default |
|----------|-------------|---------|
| `deploy_load_balancer` | Enable load balancer | `true` |
| `lb_type` | Load balancer type | `public` |
| `lb_web_server_count` | Number of IIS VMs | `2` |
| `lb_web_server_size` | Web server VM size | `Standard_B1ms` |

### AKS (Kubernetes)

| Variable | Description | Default |
|----------|-------------|---------|
| `deploy_aks` | Enable AKS cluster | `false` |
| `aks_subnet_prefix` | AKS subnet CIDR | `10.10.16.0/20` |
| `aks_node_count` | Node count | `1` |
| `aks_vm_size` | Node VM size | `Standard_B2s` |

### PaaS services

| Variable | Description | Default | Tier |
|----------|-------------|---------|------|
| `deploy_functions` | Azure Functions | `true` | Consumption |
| `deploy_static_web_app` | Static Web Apps | `true` | Free |
| `deploy_logic_apps` | Logic Apps | `true` | Consumption |
| `deploy_event_grid` | Event Grid | `true` | Free (100k) |
| `deploy_service_bus` | Service Bus | `true` | Basic |
| `deploy_app_service` | App Service | `true` | F1 (Free) |
| `deploy_cosmos_db` | Cosmos DB | `true` | Serverless |
| `deploy_container_apps` | Container Apps | `false` | Consumption |

## Outputs you will use

| Output | Description | Condition |
|--------|-------------|-----------|
| `workload_prod_vnet_id` | Prod VNet ID | `deploy_workload_prod` |
| `workload_dev_vnet_id` | Dev VNet ID | `deploy_workload_dev` |
| `lb_frontend_ip` | Load balancer IP | `deploy_load_balancer` |
| `lb_web_server_ips` | Web server IPs | `deploy_load_balancer` |
| `aks_cluster_name` | AKS cluster name | `deploy_aks` |
| `aks_cluster_fqdn` | AKS API FQDN | `deploy_aks` |

## How routing and security are set up

| Tier | Inbound Allowed | Outbound |
|------|-----------------|----------|
| Web | HTTP/HTTPS from Internet, RDP from hub | Through firewall (if LB internal) |
| App | Port 8080 from web subnet, RDP from hub | Through firewall |
| Data | Port 1433 from app subnet, RDP from hub | Through firewall |

**Note:** When the load balancer is public, the web subnet does **not** get a firewall UDR so return traffic uses the same public IP (avoiding asymmetric routing).

## AKS and diagnostics

- The AKS cluster is small and lab-friendly, using the provided subnet.  
- Control-plane logs flow to the management workspace when diagnostics are enabled.
- Workload identity and OIDC are enabled by default.

## PaaS options

Toggle the individual flags to see how different Azure services are provisioned. Most are sized to the cheapest SKU:

| Service | Estimated Cost | Notes |
|---------|----------------|-------|
| Functions | Free (Consumption) | 1M executions/month free |
| Static Web Apps | Free | 100GB bandwidth |
| Logic Apps | ~$0 (Consumption) | Pay per execution |
| Event Grid | Free (100k) | First 100k events free |
| Service Bus | ~$0.05/month | Basic tier |
| App Service | Free (F1) | 60 min CPU/day |
| Cosmos DB | ~$0-5/month | Serverless, pay per RU |

## When to deploy multiple copies

- Use both `workload_prod` and `workload_dev` to test peering and firewall rules between environments.  
- Keep one off when you only need a single application stack to reduce spend.

## Cost and lab tips

| Component | Estimated Cost | Optimization |
|-----------|----------------|--------------|
| 2x IIS VMs | ~$30/month | Use Standard_B1ms |
| Load Balancer | ~$25/month | Public is same cost as internal |
| NAT Gateway | ~$45/month | Disable if not needed |
| AKS (1 node) | ~$30/month | Keep disabled for most labs |

## Next step

If you want to exercise hybrid scenarios, read about the [on-premises simulated landing zone](onprem-simulated.md). Otherwise, jump to the [modules documentation](../modules/README.md) to see how each building block works.
