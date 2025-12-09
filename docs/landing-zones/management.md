# Management landing zone

The management landing zone gives administrators a safe entry point and a place to collect logs. It hosts the jumpbox VM and the Log Analytics workspace many other services rely on.

## What you will learn

- What the management zone deploys and how it connects to the rest of the platform.  
- How to control public access, shutdown schedules, and logging costs.  
- What outputs other zones expect from management.

## What it deploys

- A management VNet (`10.2.0.0/16`) with a jumpbox subnet (`10.2.1.0/24`).  
- A Windows jumpbox VM with optional public IP for lab convenience.  
- An NSG that limits RDP to trusted ranges (hub, VPN clients, and optional on-premises).  
- A Log Analytics workspace when `deploy_log_analytics` is true.  
- An optional route table that sends outbound traffic through the hub firewall.

## Inputs to know about

- `enable_jumpbox_public_ip` controls whether the VM gets a public IP. Keep it false for private-only access through VPN.  
- `deploy_log_analytics`, `log_retention_days`, and `log_daily_quota_gb` govern monitoring scope and cost.  
- `deploy_route_table` follows your firewall decision so routes stay consistent.  
- Admin username/password come from the root variables shared with other VMs.

## Outputs other zones consume

- `jumpbox_private_ip` (and public IP if enabled) for administrators.  
- `log_analytics_workspace_id` which AKS, Application Gateway, and diagnostics modules require.  
- `vnet_id` for peering to the hub.

## How it behaves

- NSG rules allow RDP only from the VPN client pool and hub address space by default; you can extend the allowlist for on-premises IPs.  
- Auto-shutdown is enabled by default to keep lab costs low; disable it if you plan to keep the VM running.  
- Diagnostic settings for other resources point to this workspace so you have a single place to query logs.

## When to enable the public IP

- Turn it on only for short-lived demos where a VPN is not available.  
- Keep the NSG source list tight to your current IPs to avoid broad exposure.  
- For production-like testing, leave the public IP off and connect through VPN or ExpressRoute instead.

## Next step

Review the [shared services landing zone](shared-services.md) for Key Vault, storage, SQL, and private endpoints.
