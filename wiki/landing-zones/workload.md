# Workload landing zone

The workload landing zone is where you try application scenarios. It can be deployed as many times as you like (prod, dev, or both) using the same module. It includes subnets for web, app, and data tiers, plus optional AKS and PaaS services.

## What you will learn

- What the workload zone deploys by default and how to size it for a lab.  
- How load balancing, routing, and NSGs are configured for a simple three-tier app.  
- How to toggle AKS and popular Azure PaaS services on and off.

## What it deploys

- A workload VNet with web, app, and data subnets; an AKS subnet is added when enabled.  
- NSGs per subnet with only the ports that tier needs.  
- Optional route tables that send outbound traffic to the hub firewall (except the public web subnet, which skips it to avoid asymmetric routing).  
- Optional load balancer (public or internal) with IIS web servers and RDP NAT rules for convenience.  
- Optional AKS cluster sized for a lab.  
- Optional NAT Gateway for stable outbound IP on the web subnet.  
- Optional Application Security Groups (ASGs) to group web/app/data tiers.  
- Optional PaaS services: Functions, Static Web Apps, Logic Apps, Event Grid, Service Bus, App Service, Cosmos DB, and more.

## Inputs to know about

- `workload_name`/`workload_short` differentiate prod vs dev instances.  
- `deploy_load_balancer`, `lb_type`, `lb_private_ip`, `lb_web_server_count`, and `lb_web_server_size` tune the IIS sample stack.  
- `deploy_aks`, `aks_subnet_prefix`, `aks_node_count`, and `aks_vm_size` shape the AKS cluster.  
- `admin_username` and `admin_password` set credentials for the web servers.  
- PaaS flags (`deploy_functions`, `deploy_cosmos_db`, etc.) toggle cloud services; `paas_alternative_location` provides a fallback region for quota-limited resources.  
- `deploy_nat_gateway` gives the web subnet a consistent outbound IP; useful for egress allowlists.  
- `deploy_application_security_groups` creates ASGs you can reference in NSGs for web/app/data tiers.  
- `firewall_private_ip` and `deploy_route_table` align egress with the hub firewall.  
- `dns_servers` comes from identity so all workloads share the same DNS.

## Outputs you will use

- `vnet_id` and `vnet_name` for peering and diagnostics.  
- `web_server_ips` for quick RDP or HTTP tests.  
- `lb_frontend_ip` when a public load balancer is enabled.  
- `aks_id`, `aks_name`, and `aks_fqdn` when AKS is enabled.

## How routing and security are set up

- Web subnet allows HTTP/HTTPS from anywhere and RDP from the hub.  
- App subnet accepts port 8080 only from the web subnet plus RDP from the hub.  
- Data subnet accepts port 1433 from the app subnet plus RDP from the hub.  
- When the load balancer is public, the web subnet does **not** get a firewall UDR so return traffic uses the same public IP. Internal load balancers keep the UDR for inspection.
- If you enable ASGs, you can rewrite NSG rules to target ASG names instead of CIDR prefixes for cleaner micro-segmentation.

## AKS and diagnostics

- The AKS cluster is small and lab-friendly, using the provided subnet.  
- If `enable_diagnostics` is true and `log_analytics_workspace_id` is provided, control-plane logs flow to the management workspace.  
- Workload identity and OIDC are enabled by default in the module, aligning with current Azure recommendations.

## PaaS options

Toggle the individual flags to see how different Azure services are provisioned inside the workload resource group. Most are sized to the cheapest SKU so you can try them without heavy cost. Some services automatically deploy to `paas_alternative_location` if the primary region lacks capacity.

## When to deploy multiple copies

- Use `workload_prod` and `workload_dev` with different address spaces to test peering and firewall rules between environments.  
- Keep one off when you only need a single application stack to reduce spend.

## Next step

If you want to exercise hybrid scenarios, read about the [on-premises simulated landing zone](onprem-simulated.md). Otherwise, jump to the [modules documentation](../modules/README.md) to see how each building block works.
