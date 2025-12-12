# Architecture overview

This article shows how the root Terraform module stitches the platform together. By the end you will know which files matter, how they call each other, and what order Terraform follows during a deployment.

## What you will learn

- The small set of root files that define the contract for the entire lab.
- The order Terraform follows when it creates resource groups, landing zones, and shared services.
- Why some dependencies are explicit while others are inferred by Terraform.
- Where shared settings like names and tags live.

## The five root files

| File | What it controls |
|------|------------------|
| `main.tf` | The orchestration brain: resource groups, landing zone calls, peering, firewall rules, VPN links, monitoring. |
| `variables.tf` | All input variables, defaults, and validation so bad values fail early. |
| `locals.tf` | Derived values such as location short codes and shared tags so names stay consistent. |
| `outputs.tf` | Key IDs and IP addresses that other tools or teams might consume. |
| `terraform.tfvars` | The only file you edit for your environment (subscription, passwords, feature flags). |

Tip: Treat the first four files as the platform contract. Keep changes in `terraform.tfvars` unless you are deliberately extending the lab.

## How the orchestration works

1. **Create the homes first.** `main.tf` creates the resource groups up front so every landing zone has a place to live.  
2. **Call each landing zone.** The hub, identity, management, shared services, and workload zones are each a module call. The on-premises simulation is optional.  
3. **Wire the shared pieces.** After VNets exist, the root module adds peering, firewall rules, and VPN connections.  
4. **Finish with monitoring.** Diagnostic settings and alerts run last so they can point at the final resource IDs.

Conditional zones such as `workload_dev` or the on-premises simulation use `count` so you can toggle them with a flag.

## Execution order at a glance

- **Phase 1: Foundations** – generate a random suffix for globally unique names, then create the resource groups in parallel.  
- **Phase 2: Landing zones** – deploy the hub (firewall, VPN, optional App Gateway), then identity, management, shared services, and any workloads. DNS servers from identity and the firewall IP from the hub flow into the calls that need them.  
- **Phase 3: Cross-cutting** – peer the VNets, attach firewall rule collections, and create VPN connections if the on-premises simulation is enabled.  
- **Phase 4: Monitoring** – create the action group, alerts, and diagnostic settings once everything else exists.

Azure occasionally struggles when multiple subnets are created at once, so key subnet creations are serialized with `depends_on`. Monitoring is also explicitly ordered last because it needs IDs from every zone.

## Why resource groups live in the root

- **Consistent names and tags** – CAF-style naming is applied once and passed down.  
- **Lifecycle control** – feature flags decide whether a resource group even exists.  
- **Clean removal** – Terraform can delete the group even if Azure adds hidden resources.

## What each landing zone receives

Every landing zone call receives the same bundle of context:

- Environment, location, location short code, and a resource group name.  
- The address space and subnet prefixes it should use.  
- Feature flags for the services it owns (firewall, VPN, AKS, PaaS, and so on).  
- Cross-zone references like the firewall private IP or DNS server list when needed.

This keeps the modules themselves small and reusable; they assume the caller already decided the names, tags, and feature flags.

## Cross-cutting resources managed at the root

- **VNet peering** – connects the hub to each spoke and turns on gateway transit when a VPN gateway exists.  
- **Firewall rule collections** – base rules plus optional PaaS rules are attached to the hub firewall policy.  
- **VPN connections** – hub to on-premises tunnels use the shared key and BGP settings you provide.

## Provider settings you should know about

- The AzureRM provider is pinned to version 4.x.  
- Key Vault is purged on destroy so repeat runs do not hit soft-delete errors.  
- Resource groups can be deleted even if Azure adds hidden resources.  
- VM OS disks are removed when VMs are destroyed to keep the lab tidy.

## Data sources and random suffix

`data.azurerm_client_config.current` reads your tenant and object IDs so Key Vault and RBAC can use them. A four-character random suffix is generated once per deployment and reused wherever global uniqueness is required, such as storage account names.

## Next steps

- [Network topology](network-topology.md) to see how the address spaces and subnets fit.  
- [Security model](security-model.md) to understand firewall, NSG, and diagnostics layering.  
- [Configuration flow](configuration-flow.md) to trace a variable from `tfvars` into a module call.
