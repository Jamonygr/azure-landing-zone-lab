# On-premises simulated landing zone

This landing zone gives you a small, Azure-hosted “on-premises” site so you can practice hybrid networking without real hardware. It builds a separate VNet, its own VPN gateway, and a management VM you can RDP into.

## What you will learn

- What gets deployed to represent an on-premises environment.  
- How the VPN connection is built between the hub and this simulated site.  
- Which settings control BGP, shared keys, and access to the management VM.

## What it deploys

- An on-premises VNet (`10.100.0.0/16`) with a `GatewaySubnet` and a servers subnet.  
- A route-based VPN gateway with optional BGP support.  
- A local network gateway that points back to the hub VPN public IP.  
- A site-to-site VPN connection between the two gateways.  
- A small management VM with an optional RDP allowlist.  
- Optional route tables and NSGs sized for the subnets.

## Inputs to know about

- `deploy_onprem_simulation` turns the entire zone on or off from the root.  
- `vpn_gateway_sku`, `enable_bgp`, `onprem_bgp_asn`, and `hub_bgp_asn` shape the VPN and routing behavior.  
- `vpn_shared_key` is the pre-shared key for the tunnel; it must match on both sides.  
- `hub_address_spaces` is the list of prefixes advertised to this site (spokes plus hub).  
- `allowed_rdp_source_ips` lets you lock down the management VM if you enable its public IP.

## Outputs you will use

- `vpn_gateway_public_ip` and `vpn_gateway_bgp_peering_address` for verification.  
- `lng_to_hub_id` and `vpn_connection_to_hub_id` to confirm the connection objects.  
- Management VM public and private IPs so you can RDP in and test name resolution and routing.

## How the connection is built

1. The on-premises VPN gateway is created with the address space you provide.  
2. The root module creates a local network gateway in the hub that points to the on-premises gateway public IP.  
3. A VPN connection is created in both directions, using the same shared key and BGP settings.  
4. If BGP is enabled, the on-premises site learns Azure prefixes dynamically; otherwise the address spaces you supply are used as static routes.

## When to use this zone

- You want to demo hybrid networking or gateway transit without touching a physical router.  
- You need a safe place to test firewall rules or asymmetric routing scenarios.  
- You want to practice BGP and route propagation before working with a real site.

## Next step

Head to the [workload landing zone](workload.md) to see how applications behave once hybrid connectivity is in place.
