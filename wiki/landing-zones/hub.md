# Hub landing zone

The hub is the centre of the network. It hosts the firewall, optional VPN gateway, and optional Application Gateway. Every spoke VNet peers back here, and most traffic passes through it for inspection.

## What you will learn

- What the hub deploys and why it is the first landing zone called.  
- Which switches control costly components like the firewall and VPN gateway.  
- What the hub exports to the rest of the platform.

## What it deploys

- A hub VNet (`10.0.0.0/16`) with subnets for the VPN gateway, Azure Firewall, hub management, and an optional App Gateway.  
- Azure Firewall with a policy-based configuration and both public and private IPs.  
- A route-based VPN gateway (with optional BGP) for hybrid connectivity.  
- Optional Application Gateway (WAF_v2) for layer 7 ingress.  
- Route tables that steer hub traffic through the firewall and prepare for gateway transit.

## Inputs to know about

- `deploy_firewall` and `firewall_sku_tier` control whether the firewall exists and its tier.  
- `deploy_vpn_gateway`, `vpn_gateway_sku`, and `enable_bgp` control the VPN gateway.  
- `deploy_application_gateway` and `appgw_waf_mode` toggle the WAF and its mode.  
- Address space and subnet prefixes for the hub so you can align with your IP plan.

## Optional observability

- `enable_vnet_flow_logs` captures hub VNet traffic to storage; it needs a Network Watcher in the region.  
- `enable_traffic_analytics` ships those logs to Log Analytics; keep `deploy_log_analytics` on when you use it.  
- `create_network_watcher` creates NetworkWatcherRG/Network Watcher if your subscription does not already have one.  
- `deploy_private_dns_zones` centralizes Private DNS for blob, Key Vault, and SQL in the hub resource group.

## Outputs other zones consume

- `firewall_private_ip` - used as the next hop in spoke route tables.  
- `firewall_public_ip` and `firewall_policy_id` - for rule collections and testing.  
- `vpn_gateway_id` and `vpn_gateway_public_ip` - used when building VPN connections.  
- `application_gateway_id` – available if you enabled the WAF.

## How it behaves

- Subnets are created in a safe order (gateway, firewall, management) to avoid Azure control-plane race conditions.  
- NSG attachment to the management subnet waits until the VPN gateway is ready so RDP rules do not fail.  
- Application Gateway backend IPs are injected after deployment to avoid circular dependencies with the workload module.  
- Gateway transit is enabled in peering when the VPN gateway is on so spokes can reach on-premises networks.

## Cost and lab tips

- Firewall and VPN gateway are the primary cost drivers. Turn them off with feature flags when you just need to explore topology.  
- If you only want layer 7 inspection, you can disable the firewall and leave Application Gateway on.  
- Use the firewall public IP and rule collections to practice outbound filtering without touching the workload modules.
- Flow logs write to storage; Traffic Analytics also ingests to Log Analytics. Budget for both before turning them on.

## Next step

Move to the [identity landing zone](identity.md) to add DNS and Active Directory for the platform.
