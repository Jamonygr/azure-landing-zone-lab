# Networking modules

<p align="center">
  <img src="../images/modules-networking.svg" alt="Networking modules banner" width="1000" />
</p>


These modules build the network fabric for the landing zones and are the foundation of **Pillar 1: Networking**. Each module focuses on one Azure networking concept so you can mix and match them.

## Module summary

| Module | Purpose | Cost |
|--------|---------|------|
| VNet | Virtual network | Free |
| Subnet | Subnet with service endpoints | Free |
| NSG | Network security group | Free |
| Route Table | User-defined routes | Free |
| Peering | VNet peering | Free |
| VPN Gateway | Hybrid connectivity | ~$140/month |
| VPN Connection | Site-to-site tunnels | Free |
| Local Network Gateway | On-prem representation | Free |
| Load Balancer | Standard load balancer | ~$25/month |
| NAT Gateway | Fixed outbound IP | ~$45/month |
| Application Gateway | Layer 7 ingress with WAF | ~$36/month |
| ASG | Application Security Groups | Free |
| Private DNS Zone | Private Link DNS | Minimal |

## VNet (`modules/networking/vnet/`)

Creates a virtual network with optional custom DNS servers.

| Input | Description | Default |
|-------|-------------|---------|
| `name` | VNet name | Required |
| `resource_group` | Resource group | Required |
| `location` | Azure region | Required |
| `address_space` | CIDR blocks | Required |
| `dns_servers` | Custom DNS servers | `[]` |

**Outputs:** `vnet_id`, `vnet_name`

## Subnet (`modules/networking/subnet/`)

Creates a subnet with optional service endpoints.

| Input | Description | Default |
|-------|-------------|---------|
| `name` | Subnet name | Required |
| `resource_group` | Resource group | Required |
| `virtual_network_name` | Parent VNet name | Required |
| `address_prefixes` | Subnet CIDR | Required |
| `service_endpoints` | Service endpoint list | `[]` |
| `private_endpoint_policies` | PE policies | `Disabled` |

**Outputs:** `subnet_id`, `subnet_name`

## Network security group (`modules/networking/nsg/`)

Creates an NSG and optionally associates it to a subnet.

| Input | Description | Default |
|-------|-------------|---------|
| `name` | NSG name | Required |
| `resource_group` | Resource group | Required |
| `location` | Azure region | Required |
| `subnet_id` | Subnet to associate | `null` |
| `associate_with_subnet` | Enable association | `false` |
| `security_rules` | List of rules | `[]` |

**Outputs:** `nsg_id`, `nsg_name`

### Security rule structure
```hcl
security_rules = [{
  name                       = "AllowHTTPS"
  priority                   = 100
  direction                  = "Inbound"
  access                     = "Allow"
  protocol                   = "Tcp"
  source_port_range          = "*"
  destination_port_range     = "443"
  source_address_prefix      = "*"
  destination_address_prefix = "*"
}]
```

## Route table (`modules/networking/route-table/`)

Creates a user-defined route table and attaches it to subnets.

| Input | Description | Default |
|-------|-------------|---------|
| `name` | Route table name | Required |
| `resource_group` | Resource group | Required |
| `location` | Azure region | Required |
| `subnet_ids` | Subnets to associate | `[]` |
| `routes` | List of routes | `[]` |
| `disable_bgp_propagation` | Disable BGP routes | `false` |

**Outputs:** `route_table_id`

### Route structure
```hcl
routes = [{
  name                   = "ToFirewall"
  address_prefix         = "0.0.0.0/0"
  next_hop_type          = "VirtualAppliance"
  next_hop_in_ip_address = "10.0.1.4"  # Firewall IP
}]
```

## Peering (`modules/networking/peering/`)

Creates bidirectional VNet peering between two VNets. Supports gateway transit.

| Input | Description | Default |
|-------|-------------|---------|
| `resource_group` | Primary resource group | Required |
| `vnet1_id` | First VNet ID | Required |
| `vnet1_name` | First VNet name | Required |
| `vnet2_id` | Second VNet ID | Required |
| `vnet2_name` | Second VNet name | Required |
| `remote_resource_group` | Second VNet RG | Required |
| `allow_gateway_transit_vnet1` | Gateway transit on VNet1 | `false` |
| `use_remote_gateways_vnet2` | Use remote gateway on VNet2 | `false` |

**Outputs:** `peering_vnet1_to_vnet2_id`, `peering_vnet2_to_vnet1_id`

## VPN gateway (`modules/networking/vpn-gateway/`)

Creates a route-based VPN gateway with optional BGP.

| Input | Description | Default |
|-------|-------------|---------|
| `name` | Gateway name | Required |
| `resource_group` | Resource group | Required |
| `location` | Azure region | Required |
| `subnet_id` | GatewaySubnet ID | Required |
| `sku` | Gateway SKU | `VpnGw1` |
| `enable_bgp` | Enable BGP | `false` |
| `asn` | BGP ASN | `65515` |

**Outputs:** `vpn_gateway_id`, `public_ip`, `bgp_peering_address`  
**Cost:** ~$140/month

## VPN connection (`modules/networking/vpn-connection/`)

Creates a site-to-site or VNet-to-VNet connection.

| Input | Description | Default |
|-------|-------------|---------|
| `name` | Connection name | Required |
| `resource_group` | Resource group | Required |
| `location` | Azure region | Required |
| `type` | Connection type | `IPsec` |
| `virtual_network_gateway_id` | VPN Gateway ID | Required |
| `local_network_gateway_id` | LNG ID (for S2S) | `null` |
| `peer_gateway_id` | Peer VPN GW ID (for V2V) | `null` |
| `shared_key` | Pre-shared key | Required |
| `enable_bgp` | Enable BGP | `false` |

**Outputs:** `vpn_connection_id`

## Local network gateway (`modules/networking/local-network-gateway/`)

Represents an on-premises gateway from Azure's point of view.

| Input | Description | Default |
|-------|-------------|---------|
| `name` | LNG name | Required |
| `resource_group` | Resource group | Required |
| `location` | Azure region | Required |
| `gateway_address` | On-prem public IP | Required |
| `address_space` | On-prem address ranges | Required |
| `enable_bgp` | Enable BGP | `false` |
| `asn` | On-prem BGP ASN | `null` |
| `bgp_peering_address` | On-prem BGP IP | `null` |

**Outputs:** `local_network_gateway_id`

## Load balancer (`modules/networking/load-balancer/`)

Creates a Standard load balancer (public or internal) with probes, rules, and optional outbound rules.

| Input | Description | Default |
|-------|-------------|---------|
| `name` | LB name | Required |
| `resource_group` | Resource group | Required |
| `location` | Azure region | Required |
| `sku` | LB SKU | `Standard` |
| `type` | `public` or `internal` | `public` |
| `subnet_id` | Subnet (for internal) | `null` |
| `private_ip` | Private IP (for internal) | `null` |
| `backend_pool_name` | Backend pool name | Required |
| `health_probes` | List of health probes | `[]` |
| `lb_rules` | List of LB rules | `[]` |
| `nat_rules` | List of NAT rules | `[]` |
| `enable_outbound_rule` | Enable outbound rule | `false` |

**Outputs:** `lb_id`, `backend_pool_id`, `frontend_ip`, `nat_rule_ids`  
**Cost:** ~$25/month

## NAT Gateway (`modules/networking/nat-gateway/`)

Creates a NAT Gateway for fixed outbound IP.

| Input | Description | Default |
|-------|-------------|---------|
| `name` | NAT Gateway name | Required |
| `resource_group` | Resource group | Required |
| `location` | Azure region | Required |
| `subnet_ids` | Subnets to associate | `[]` |

**Outputs:** `nat_gateway_id`, `public_ip`  
**Cost:** ~$45/month

## Application Security Group (`modules/networking/asg/`)

Creates Application Security Groups for micro-segmentation.

| Input | Description | Default |
|-------|-------------|---------|
| `name` | ASG name | Required |
| `resource_group` | Resource group | Required |
| `location` | Azure region | Required |

**Outputs:** `asg_id`  
**Cost:** Free

## Private DNS Zone (`modules/networking/private-dns-zone/`)

Creates a Private DNS zone and optionally links it to VNets.

| Input | Description | Default |
|-------|-------------|---------|
| `name` | DNS zone name | Required |
| `resource_group` | Resource group | Required |
| `vnet_ids` | VNets to link | `[]` |
| `registration_enabled` | Enable auto-registration | `false` |

**Outputs:** `dns_zone_id`, `dns_zone_name`  
**Cost:** Minimal (~$0.50/zone/month)

## Related pages

- [Hub landing zone (Pillar 1: Networking)](../landing-zones/hub.md)
- [Network topology](../architecture/network-topology.md)
- [Variables reference](../reference/variables.md)
