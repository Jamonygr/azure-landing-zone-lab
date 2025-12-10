# Landing zones overview

In this lab, a landing zone is a self-contained Terraform module that owns one part of the platform. Each landing zone receives a resource group, address space, and the shared context (tags, location, environment). The root module then connects them with peering and shared services.

## What you will learn

- What each landing zone is responsible for.  
- Which zones are optional and how they depend on one another.  
- How outputs from one zone become inputs to the next.

## The zones at a glance

| Zone | Purpose | Key components |
|------|---------|----------------|
| [Hub](hub.md) | Central connectivity and inspection point. | VNet, Azure Firewall, VPN Gateway, optional Application Gateway. |
| [Identity](identity.md) | Directory and DNS for the platform. | Domain controllers with static IPs, DNS outputs for other zones. |
| [Management](management.md) | Operations entry point and monitoring. | Jumpbox VM, Log Analytics workspace, NSG. |
| [Shared services](shared-services.md) | Common PaaS for multiple apps. | Key Vault, storage, SQL Database, private endpoints. |
| [Workload](workload.md) | Sample application tiers. | Web/app/data subnets, load balancer, AKS, optional PaaS. |
| [On-premises simulated](onprem-simulated.md) | Hybrid playground. | On-prem VNet, VPN gateway, local network gateway, VPN connection. |

## How they connect

- The hub peers to every spoke. If a VPN gateway exists, gateway transit lets spokes reach on-premises networks.  
- Identity exports DNS server IPs; every other zone consumes them so name resolution is consistent.  
- The hub exports the firewall private IP; spokes use it as their default route when the firewall is on.  
- Management exports the Log Analytics workspace ID; AKS and Application Gateway use it for diagnostics.  
- Workload zones are optional; you can deploy just prod, just dev, or both with the same module.

## Choosing what to deploy

- Turn off the firewall or VPN gateway if you only need a light demo and want to control cost.  
- Skip the on-premises simulation unless you want to practice VPN or BGP.  
- Enable the workload zone to see the sample web/app/data stack and load balancer.  
- Add the PaaS flags to try Functions, Cosmos DB, Logic Apps, and more inside the workload zone.  
- Turn on the network extensions when you need them: NAT Gateway for stable egress IPs, Private DNS zones for Private Link, ASGs for cleaner NSG rules, and VNet Flow Logs/Traffic Analytics for traffic visibility (with Network Watcher + Log Analytics prerequisites).

## Next steps

Start with the [hub](hub.md), then follow the chain to identity and management. Those three form the core platform. Add shared services and workload when you want to see application scenarios, and the on-premises simulation when you want a hybrid story.
