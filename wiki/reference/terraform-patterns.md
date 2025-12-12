# Terraform patterns

These are the Terraform idioms used throughout the lab. Skim them before extending the codebase so your changes stay consistent.

## Conditional resources

Feature flags drive `count` on modules and resources:

```hcl
count = var.deploy_firewall ? 1 : 0
```

This keeps optional components (firewall, VPN, workloads, PaaS) out of the state when they are disabled.

## Caller-controlled naming

Names are composed in callers using inputs and `location_short`, then passed into modules. Modules do not invent names, which keeps them reusable.

## Shared tags

`local.common_tags` is passed to every resource so ownership and purpose are obvious in Azure and Cost Management.

## Serialization with depends_on

Azure occasionally rejects parallel subnet or NSG operations. Callers add `depends_on` to enforce a safe order:

```hcl
module "firewall_subnet" {
  depends_on = [module.gateway_subnet]
}
```

## Output guarding

Outputs are wrapped in the same flags that control the resources to avoid null references:

```hcl
output "lb_frontend_ip" {
  value = var.deploy_workload_prod && var.deploy_load_balancer ? module.workload_prod[0].lb_frontend_ip : null
}
```

## Remote state (optional)

An example backend for Azure Storage is commented in the root module. Uncomment and configure it if you want shared state across machines.

## Asymmetric routing protection

When using a public load balancer, the workload web subnet skips the firewall route so return traffic uses the same path it arrived on. This prevents the firewall from dropping packets due to asymmetry.
