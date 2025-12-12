# Networking modules

These modules build the network fabric for the landing zones. Each module focuses on one Azure networking concept so you can mix and match them.

## VNet

Creates a virtual network with optional custom DNS servers.  
Inputs: name, resource group, location, address space, DNS servers, tags.  
Outputs: VNet ID and name.

## Subnet

Creates a subnet with optional service endpoints.  
Inputs: name, resource group, virtual network name, address prefixes, service endpoints.  
Outputs: subnet ID and name.

## Network security group (NSG)

Creates an NSG and, if you choose, associates it to a subnet.  
Inputs: name, resource group, location, subnet ID, `associate_with_subnet`, security rules, tags.  
Outputs: NSG ID.

## Route table

Creates a user-defined route table and attaches it to subnets.  
Inputs: name, resource group, location, subnet IDs, route list, whether to disable BGP propagation, tags.  
Outputs: route table ID.

## Peering

Creates bidirectional VNet peering between two VNets. Supports gateway transit when a VPN gateway exists.  
Inputs: resource group, VNet IDs and names, remote resource group, `allow_gateway_transit_vnet1`, `use_remote_gateways_vnet2`.  
Outputs: peering IDs.

## VPN gateway

Creates a route-based VPN gateway with optional BGP.  
Inputs: name, resource group, location, subnet ID, SKU, `enable_bgp`, ASN, tags.  
Outputs: VPN gateway ID, public IP, and BGP peering address.

## VPN connection

Creates a site-to-site or VNet-to-VNet connection.  
Inputs: name, resource group, location, connection type, virtual network gateway ID, local network gateway ID, peer gateway ID (for VNet-to-VNet), shared key, `enable_bgp`, tags.  
Outputs: VPN connection ID.

## Local network gateway

Represents an on-premises gateway from Azure’s point of view.  
Inputs: name, resource group, location, gateway public IP, address space list, `enable_bgp`, ASN, BGP peering address, tags.  
Outputs: local network gateway ID.

## Load balancer

Creates a Standard load balancer (public or internal) with probes, rules, and optional outbound rules.  
Inputs: name, resource group, location, SKU, type (public/internal), subnet ID, private IP, backend pool name, health probes, load-balancing rules, NAT rules, `enable_outbound_rule`, tags.  
Outputs: load balancer ID, backend pool ID, frontend IP, NAT rule IDs.
