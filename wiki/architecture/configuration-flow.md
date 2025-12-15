# Configuration flow

This article follows a single value from `terraform.tfvars` all the way into the resources Terraform creates. If you are new to Terraform, read this as a map: where do inputs come from, how are they validated, and how do they reach each landing zone?

## What you will learn

- Where to place your inputs and how the root module validates them.
- How locals keep naming, tagging, and locations consistent across the lab.
- How landing zones forward context without adding hidden logic.
- Which feature flags control major parts of the deployment.

## The flow on one page

`terraform.tfvars` → `variables.tf` → `locals.tf` → `main.tf` → landing zones → reusable modules → outputs

## Where inputs come from

- **`terraform.tfvars`** – the only file you edit for your deployment (subscription, admin credentials, flags).  
- **`environments/*.tfvars`** – optional presets if you want a dev or prod profile.  
- **`variables.tf`** – the contract and guardrails; types, defaults, and descriptions live here.

If a value is missing or of the wrong type, Terraform fails fast during `plan`, not after resources start to deploy.

## Root variable categories

| Category | Examples | Why it matters |
|----------|----------|----------------|
| Context | `project`, `environment`, `location`, `owner` | Shapes names and tags everywhere. |
| Network | `hub_address_space`, `identity_address_space`, `workload_prod_address_space` | Defines the IP fabric for each VNet. |
| Security | `admin_username`, `admin_password`, `vpn_shared_key` | Authenticates VMs and VPN connections. |
| Features | `deploy_firewall`, `deploy_vpn_gateway`, `deploy_aks`, `deploy_application_gateway`, `deploy_private_dns_zones`, `deploy_nat_gateway`, `deploy_application_security_groups` | Turns big-ticket items and network extensions on or off. |
| Workload | `lb_type`, `lb_web_server_count`, `lb_web_server_size` | Sizes the sample application tier. |
| PaaS | `deploy_functions`, `deploy_cosmos_db`, `paas_alternative_location` (`deploy_container_apps` exists as a placeholder flag but is not currently wired) | Controls optional cloud services. |
| Monitoring | `deploy_log_analytics`, `enable_vnet_flow_logs`, `enable_traffic_analytics`, `create_network_watcher`, `log_retention_days`, `log_daily_quota_gb` | Governs observability settings and prerequisites. |

## What locals do

`locals.tf` converts raw inputs into shared values:

- **`location_short`** – keeps names short and CAF-compliant.  
- **`common_tags`** – one map of tags applied everywhere.  
- **Passthrough helpers** – convenient aliases for `environment` and `project`.

Because locals are calculated once, every module call sees the same spelling of names and tags.

## How a value travels (example)

1. You set `dc01_ip_address = "10.1.1.4"` in `terraform.tfvars`.  
2. `variables.tf` enforces that it is a string and matches the expected CIDR.  
3. `locals.tf` does not change it, but builds tags that will sit beside it.  
4. `main.tf` passes `dc01_ip_address` into the identity landing zone call.  
5. The identity landing zone passes it directly to the `compute/windows-vm` module that creates the VM NIC.  
6. The landing zone then outputs `dns_servers`, which include that IP, and other zones consume that list as their DNS setting.

At no point is the value rewritten; it is forwarded so you always know where it went.

## Feature flags to know

| Flag | What it controls |
|------|------------------|
| `deploy_firewall` | Azure Firewall, route tables in spokes, firewall rule collections. |
| `deploy_vpn_gateway` | Hub VPN gateway, gateway transit in peering, VPN connections. |
| `deploy_onprem_simulation` | On-premises VNet, gateway, local network gateways, VPN tunnel. |
| `deploy_workload_prod` / `deploy_workload_dev` | Whether each workload landing zone exists. |
| `deploy_load_balancer` | Public or internal load balancer and IIS sample VMs. |
| `deploy_application_gateway` | App Gateway subnet plus WAF instance. |
| `deploy_aks` | AKS subnet and cluster. |
| `deploy_nat_gateway` | NAT Gateway for predictable egress from the workload web subnet. |
| `deploy_private_dns_zones` | Central Private DNS zones for blob, Key Vault, and SQL Private Link. |
| `deploy_application_security_groups` | ASGs for web/app/data tiers to simplify NSG rules. |
| `deploy_log_analytics` | Workspace plus diagnostic settings that depend on it. |
| `enable_vnet_flow_logs` | VNet flow logs to storage (requires storage + Network Watcher). |
| `enable_traffic_analytics` | Traffic Analytics on the flow logs (requires Log Analytics + storage). |
| `create_network_watcher` | Creates NetworkWatcherRG/Network Watcher if your subscription does not have one. |
| PaaS flags (`deploy_functions`, `deploy_cosmos_db`, etc.) | Optional cloud services inside the workload zone. |

Use these in combinations. For example, if you disable `deploy_firewall`, also disable the route tables that would point to it.

## Propagation patterns

- **Context forwarding** – Every module call receives environment, location, location short code, resource group name, and shared tags.  
- **Cross-zone references** – Identity exports DNS server IPs; the hub exports the firewall IP; management exports the Log Analytics workspace ID. Spokes pull these in rather than duplicating configuration.  
- **Conditional outputs** – Outputs are guarded with the same flags that control the resources to avoid null references when something is off.

## Debugging the flow

- Run `terraform validate` before `plan` to catch missing or mistyped values.  
- Use `terraform console` to inspect `var.<name>` or `local.<name>` when you are unsure how a value resolved.  
- After a `plan`, skim the **Outputs** section to confirm that flags did not null out something you need.  
- If you enable the public load balancer, remember the web subnet will not receive a firewall route to prevent asymmetric routing.

## Ready for more?

- [Network topology](network-topology.md) for the IP layout.  
- [Security model](security-model.md) to see how traffic is inspected and logged.  
- [Landing zones overview](../landing-zones/README.md) for what each zone owns.
