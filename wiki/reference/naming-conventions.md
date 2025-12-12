# Naming conventions

Names in this lab follow the Cloud Adoption Framework style to stay short, predictable, and readable. Most names combine the zone, environment, and a location short code built in `locals.tf`.

## Location short codes

Defined in `locals.tf`, for example `westeurope` → `weu`, `eastus` → `eus`. These keep names under Azure length limits.

## Common patterns

- Resource groups: `rg-{zone}-{env}-{loc}` (for example, `rg-hub-lab-eus`).  
- VNets: `vnet-{zone}-{env}-{loc}`.  
- Subnets: `snet-{role}-{zone}-{env}-{loc}` except required names like `GatewaySubnet` and `AzureFirewallSubnet`.  
- Firewall: `afw-hub-{env}-{loc}`.  
- Route tables: `rt-{zone}-{env}-{loc}`.  
- NSGs: `nsg-{zone}-{env}-{loc}`.  
- Load balancer: `lb-{workload}-{env}-{loc}`.  
- App Gateway: `agw-hub-{env}-{loc}`.  
- AKS: `aks-{workload}-{env}-{loc}`.  
- VMs: short names like `web01-prd`, `dc01`, `jumpbox`.  
- Storage: `st{project}{env}{random}` using the random suffix for global uniqueness.

## Tags

`locals.common_tags` sets a shared tag map for every resource: Environment, Project, ManagedBy, Purpose, Owner, CostCenter, and Repository. Adjust the values in `terraform.tfvars` to change how these appear.

## Why this matters

- Predictable names make troubleshooting and log searches faster.  
- Short codes keep Azure happy when names must be unique and concise.  
- Only globally unique resources, like storage accounts, use the random suffix; everything else stays human-friendly.
