# Network topology

<p align="center">
  <img src="../images/architecture-network-topology.svg" alt="Network topology banner" width="1000" />
</p>


This article explains the IP layout, subnets, peering, and routing strategy used in the lab. If you have never designed a hub-and-spoke network before, think of the hub as the meeting point for all traffic and the firewall as the doorman.

## What you will learn

- The address spaces for every landing zone and why they are spaced apart.
- Which subnets live in each zone and what runs inside them.
- How peering and gateway transit connect the hub to every spoke.
- How user-defined routes and a few guardrails keep traffic symmetrical.

## Address spaces

Each landing zone receives its own /16 block so you have room to experiment without overlap.

| Zone | VNet | CIDR | Purpose |
|------|------|------|---------|
| Hub | `vnet-hub-{env}-{loc}` | `10.0.0.0/16` | Central connectivity and security. |
| Identity | `vnet-identity-{env}-{loc}` | `10.1.0.0/16` | Domain controllers and DNS. |
| Management | `vnet-management-{env}-{loc}` | `10.2.0.0/16` | Jumpbox and monitoring. |
| Shared | `vnet-shared-{env}-{loc}` | `10.3.0.0/16` | Key Vault, storage, SQL. |
| Workload Prod | `vnet-prod-{env}-{loc}` | `10.10.0.0/16` | Sample application tier. |
| Workload Dev | `vnet-dev-{env}-{loc}` | `10.11.0.0/16` | Optional second workload. |
| On-Prem Sim | `vnet-onprem-{env}-{loc}` | `10.100.0.0/16` | Simulated on-premises site. |

## Subnets by zone

- **Hub** – `GatewaySubnet` for VPN, `AzureFirewallSubnet`, a management subnet, and an optional Application Gateway subnet.  
- **Identity** – a domain controller subnet (`10.1.1.0/24`) with static IPs for DC01 and the optional DC02.  
- **Management** – a jumpbox subnet (`10.2.1.0/24`) that hosts the RDP entry point.  
- **Shared services** – an app subnet and a private endpoint subnet for PaaS resources.  
- **Workloads** – web, app, and data subnets plus an optional AKS subnet; the prefixes change if you deploy the dev or prod copy.  
- **On-premises simulation** – `GatewaySubnet` and a small servers subnet for a management VM.

## Peering and gateway transit

The hub peers with every spoke. When the VPN gateway exists, gateway transit is enabled so spokes can reach on-premises networks without running their own gateways.

- Hub ↔ Identity  
- Hub ↔ Management  
- Hub ↔ Shared services  
- Hub ↔ Workload prod (conditional)  
- Hub ↔ Workload dev (conditional)

If you disable the VPN gateway, peering still connects the VNets but without transit routes.

## Routing strategy

- **Forced tunneling via firewall** – When `deploy_firewall` is true, a route table sends `0.0.0.0/0` from spoke subnets to the firewall. Hub management traffic is also steered through it.  
- **Gateway subnet routes** – When both firewall and VPN are enabled, the hub gateway subnet has routes for each spoke prefix that point to the firewall so VPN traffic is inspected.  
- **Web subnet exception** – If you use a public load balancer, the workload web subnet does not receive a firewall route to keep inbound and outbound traffic symmetrical. Internal load balancer scenarios keep the UDR.  
- **On-premises routes** – The on-premises gateway learns Azure prefixes via BGP when enabled, or from a static list you set on the local network gateway.

## Traffic flows to picture

- Outbound internet: spoke VM → firewall → internet.  
- East-west: spoke A → hub firewall → spoke B.  
- Inbound web: internet → public load balancer → web VMs (or internet → App Gateway → web VMs when enabled).  
- Hybrid: on-premises → VPN gateway → hub → spokes.

## Guardrails against asymmetric routing

Asymmetric routing causes traffic to enter through one path and leave through another, which firewalls will drop. To avoid this:

- Public load balancer subnets skip the firewall UDR so return traffic uses the same public IP.  
- Peering uses gateway transit only when a hub VPN gateway exists; otherwise spokes talk directly to the internet.  
- Route tables are attached only when the firewall is present, keeping the defaults clean when you disable it.

## Where to go next

- [Security model](security-model.md) to see how firewall and NSGs combine with this routing.  
- [Configuration flow](configuration-flow.md) to understand how these CIDRs are passed into each module.  
- [Landing zones overview](../landing-zones/README.md) to see which zone owns which subnet.

## Related pages

- [Hub landing zone (Pillar 1: Networking)](../landing-zones/hub.md)
- [Workload landing zone](../landing-zones/workload.md)
- [Networking modules](../modules/networking.md)
- [Architecture overview](overview.md)
