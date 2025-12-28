# Architecture overview

This article shows how the root Terraform module stitches the platform together. By the end you will know which files matter, how they call each other, and what order Terraform follows during a deployment.

## What you will learn

- The small set of root files that define the contract for the entire lab.
- The 5-pillar architecture and how it maps to a CAF landing zone.
- The order Terraform follows when it creates resource groups, landing zones, and shared services.
- Why some dependencies are explicit while others are inferred by Terraform.
- Where shared settings like names and tags live.

## CAF context

This lab uses the Cloud Adoption Framework landing zone model as a guide. If you want the short, lab-focused CAF and Entra primer, start with `wiki/architecture/foundations.md`.

## The 5-Pillar Architecture

This lab follows a 5-pillar structure aligned with Microsoft's Cloud Adoption Framework:

| Pillar | Landing Zone | Key Components |
|--------|--------------|----------------|
| **1. Networking** | `landing-zones/hub.md` | Hub VNet, Azure Firewall, VPN Gateway, Application Gateway, VNet Peering, NAT Gateway |
| **2. Identity Management** | `landing-zones/identity.md` | Domain Controllers (DC01, DC02), DNS servers, Identity VNet |
| **3. Governance** | `landing-zones/governance.md` | Management Groups, Azure Policy, Cost Management, RBAC custom roles, Regulatory Compliance |
| **4. Security** | `landing-zones/shared-services.md` | Shared Services VNet, Key Vault, Storage Account, SQL Database, Private DNS Zones, Private Endpoints |
| **5. Management** | `landing-zones/management.md` | Jumpbox VM, Log Analytics, Monitoring/Alerts, Backup, Automation, Workload zones (Prod/Dev) |

## The five root files

| File | What it controls |
|------|------------------|
| `main.tf` | The orchestration brain: resource groups, 5-pillar module calls, peering, firewall rules, VPN links, workloads. |
| `variables.tf` | All input variables, defaults, and validation so bad values fail early. |
| `locals.tf` | Derived values such as location short codes and shared tags so names stay consistent. |
| `outputs.tf` | Key IDs and IP addresses that other tools or teams might consume. |
| `terraform.tfvars` | The only file you edit for your environment (subscription, passwords, feature flags). |

Tip: Treat the first four files as the platform contract. Keep changes in `terraform.tfvars` unless you are deliberately extending the lab.

## How the orchestration works

1. Create the homes first. `main.tf` creates the resource groups up front so every pillar has a place to live.
2. Call each pillar. Networking -> Identity -> Management -> Security -> Governance, each as a module call. Workloads and on-premises simulation are optional.
3. Wire the shared pieces. After VNets exist, the networking connectivity module adds peering, flow logs, NAT gateway, and ASGs.
4. Finish with governance. Management groups, policies, cost alerts, and RBAC run after infrastructure exists.

Conditional components such as `workload_dev` or the on-premises simulation use `count` so you can toggle them with a flag.

## Execution order at a glance

- Phase 1: Foundations - generate a random suffix for globally unique names, then create the resource groups in parallel.
- Phase 2: Core Pillars - deploy networking (hub, firewall, VPN, App Gateway), then identity (domain controllers), management (jumpbox, log analytics), and security (shared services).
- Phase 3: Workloads - deploy prod and dev workload zones with their PaaS services.
- Phase 4: Connectivity - peer the VNets, configure flow logs, NAT gateway, and ASGs.
- Phase 5: Governance - create management groups, policy assignments, cost budgets, and RBAC roles.

Azure occasionally struggles when multiple subnets are created at once, so key subnet creations are serialized with `depends_on`. Governance is explicitly ordered last because it needs the subscription and resource groups to exist.

## Why resource groups live in the root

- Consistent names and tags - CAF-style naming is applied once and passed down.
- Lifecycle control - feature flags decide whether a resource group even exists.
- Clean removal - Terraform can delete the group even if Azure adds hidden resources.

## What each landing zone receives

Every landing zone call receives the same bundle of context:

- Environment, location, location short code, and a resource group name.
- The address space and subnet prefixes it should use.
- Feature flags for the services it owns (firewall, VPN, AKS, PaaS, and so on).
- Cross-zone references like the firewall private IP or DNS server list when needed.

This keeps the modules themselves small and reusable; they assume the caller already decided the names, tags, and feature flags.

## Cross-cutting resources managed at the root

- VNet peering connects the hub to each spoke and turns on gateway transit when a VPN gateway exists.
- Firewall rule collections base rules plus optional PaaS rules are attached to the hub firewall policy.
- VPN connections hub to on-premises tunnels use the shared key and BGP settings you provide.

## Provider settings you should know about

- The AzureRM provider is pinned to version 4.x.
- Key Vault is purged on destroy so repeat runs do not hit soft-delete errors.
- Resource groups can be deleted even if Azure adds hidden resources.
- VM OS disks are removed when VMs are destroyed to keep the lab tidy.

## Data sources and random suffix

`data.azurerm_client_config.current` reads your tenant and object IDs so Key Vault and RBAC can use them. A four-character random suffix is generated once per deployment and reused wherever global uniqueness is required, such as storage account names.

## Next steps

- [Foundations](foundations.md) for CAF and Entra context.
- [Network topology](network-topology.md) to see how the address spaces and subnets fit.
- [Security model](security-model.md) to understand firewall, NSG, and diagnostics layering.
- [Configuration flow](configuration-flow.md) to trace a variable from `tfvars` into a module call.
