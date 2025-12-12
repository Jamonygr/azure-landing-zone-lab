# Hardening and hygiene checklist (current lab profile)

Use this to tighten the lab after initial deployment. The current profile runs with VPN off and a public jumpbox; firewall is on; LB is public; many PaaS services are enabled.

## Highest-priority fixes

- **RDP scope**: Set `allowed_jumpbox_source_ips` in `terraform.tfvars` to your public IP/CIDR instead of `0.0.0.0/0`. For example: `["203.0.113.10/32"]`.
- **Public entry path**: If you want no public exposure, set `enable_jumpbox_public_ip = false` and `deploy_vpn_gateway = true`; then connect via the VPN client pool.
- **Admin secrets**: Rotate `admin_password`, `sql_admin_password`, and `vpn_shared_key` to unique, strong values before apply; avoid reusing across services.

## Monitoring and diagnostics

- Turn on the management monitoring features so diagnostic settings and alerts flow into Log Analytics; adjust `log_daily_quota_gb` if you see cap messages.
- Optional: enable `enable_vnet_flow_logs` (with storage + Network Watcher) and `enable_traffic_analytics` for traffic visibility.

## Networking notes

- Firewall is on; VPN and on-prem simulation are off, so inbound access is only via the jumpbox public IP and LB NAT rules.
- Private endpoints and Private DNS are on; SQL is off. If you later enable SQL, ensure the private endpoint DNS entries resolve from spokes.
- Application Gateway is off; leave it that way unless you wire backend IPs.

## PaaS footprint and regions

- Functions and App Service deploy to `ukwest`, Static Web App to `eastus2`, Cosmos DB to `westus2` (quota workarounds). Align to a single region if latency/governance matters.
- Disable PaaS flags you do not need to reduce surface area and deployment time.

## Cost and lifecycle

- Auto-shutdown is on for VMs (`enable_auto_shutdown = true`). Keep it on for labs.
- If you do not need the load balancer/IIS demo, set `deploy_load_balancer = false` to save time and static public IP usage.

## Optional resilience

- If you need identity resiliency, set `deploy_secondary_dc = true` and ensure DNS settings propagate to spokes.
- If you need dev parity, enable `deploy_workload_dev`, but expect more cost and IP space usage.
