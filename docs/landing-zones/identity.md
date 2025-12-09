# Identity landing zone

The identity landing zone provides DNS and Active Directory for the entire lab. Other zones point to these domain controllers for name resolution so services can find each other by name instead of IP.

## What you will learn

- What the identity zone deploys and how it fits into the hub-and-spoke layout.  
- Which settings control the number of domain controllers and their IPs.  
- What outputs other zones need from identity.

## What it deploys

- An identity VNet (`10.1.0.0/16`) with a domain controller subnet (`10.1.1.0/24`).  
- One Windows Server VM as DC01; an optional DC02 for high availability.  
- An NSG that allows Active Directory ports and RDP from trusted ranges.  
- An optional route table that sends internet-bound traffic to the hub firewall.

## Inputs to know about

- `dc01_ip_address` and `dc02_ip_address` set static IPs for the controllers.  
- `deploy_secondary_dc` decides whether DC02 is created.  
- `deploy_route_table` follows the firewall flag; turn it off if you disable the firewall.  
- `enable_auto_shutdown` controls cost-saving shutdown on the VMs.

## Outputs other zones consume

- `dns_servers` – the private IPs of the domain controllers. Management, shared services, and workloads all pass this list into their VNets.  
- `vnet_id` and individual VM IDs – useful for peering and diagnostics.

## How it behaves

- DNS IPs are exported so every other landing zone can simply reuse them; you do not have to hard-code DNS anywhere else.  
- NSG rules scope inbound RDP and directory traffic to the hub or on-premises prefixes, reducing exposure.  
- When the firewall is enabled, the route table pushes outbound traffic back to the hub for inspection.

## When to add the secondary DC

- Enable `deploy_secondary_dc` when you want to demonstrate resilience or perform maintenance on DC01 without losing DNS.  
- Keep it off for the lightest-cost lab run; the sample workloads continue to work with a single DC.

## Next step

Proceed to the [management landing zone](management.md) to add a jumpbox and monitoring workspace.
