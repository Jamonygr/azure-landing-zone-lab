# Module design patterns

The lab is built from small, reusable Terraform modules. Each module creates a focused set of resources and expects the caller to decide names, tags, and feature flags. This page explains how the modules are structured so you can reuse or extend them in your own projects.

## How modules are structured

- Each module has `main.tf`, `variables.tf`, and `outputs.tf`.  
- Inputs are validated with types and descriptions; required values are marked clearly.  
- Outputs return IDs, names, and IPs so callers can chain modules together.  
- Modules avoid inventing names; the caller passes fully composed names and tags.

## Conventions that keep things simple

- Keep modules single-purpose (for example, one module for NSGs, another for VNets).  
- Let the root or landing zone decide whether something should exist; modules rarely use `count` inside.  
- Use shared tags from the caller so every resource tells the same ownership story.  
- Use `depends_on` in the caller to serialize operations that Azure struggles to parallelize (subnet creation, NSG association).

## Testing a module by itself

1. Create a scratch `main.tf` that points to the module folder.  
2. Supply the minimal inputs and run `terraform init && terraform apply`.  
3. Destroy when finished to keep costs near zero.  
4. Add the module to `wiki/modules/*.md` if you plan to keep it.

## Categories you will find

- **Networking** – VNets, subnets, NSGs, route tables, peering, VPN, load balancers.  
- **Compute** – Windows VMs and IIS web servers.  
- **Security** – Azure Firewall, firewall rule collections, Key Vault.  
- **Monitoring** – Log Analytics, action groups, alerts, diagnostic settings.  
- **PaaS** – AKS and common app services like Functions, App Service, and Cosmos DB.

## Error avoidance tips

- Compose names in the caller using `location_short` to stay within Azure length limits.  
- Use the provided random suffix for globally unique resources like storage accounts.  
- For public load balancers, skip the firewall route on the web subnet to avoid asymmetric routing; the workload module already does this for you.  
- If you see subnet conflicts, add `depends_on` in the caller so subnets are created one after another.
