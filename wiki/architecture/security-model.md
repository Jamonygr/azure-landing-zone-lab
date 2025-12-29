# Security model

<p align="center">
  <img src="../images/architecture-security-model.svg" alt="Security model banner" width="1000" />
</p>


Security in this lab is layered. The outer ring is Azure Firewall, the middle ring is network security groups (NSGs), and the inner ring is diagnostics that record what happened. This article walks through how those rings are configured and how traffic is routed through them.

## What you will learn

- When Azure Firewall is deployed, what it inspects, and how rules are organized.
- How NSGs differ by subnet and why they only allow the traffic each tier needs.
- How user-defined routes enforce firewall inspection without breaking web flows.
- How diagnostics are enabled so you can see what happened later.

## Azure Firewall

- Deployed in the hub when `deploy_firewall = true`.  
- Lives in `AzureFirewallSubnet` and uses a policy-based configuration.  
- Exposes both a private IP (used as a next hop for spokes) and a public IP.  
- Rule collections are attached in `main.tf` so all spokes share the same policy.

Rule collections are split into:

- **Base rules** – DNS to domain controllers, RDP/SSH from admin ranges, east-west traffic between spokes, and common outbound services such as Windows Update.  
- **PaaS rules** – allow traffic to services like Functions, Static Web Apps, Logic Apps, Event Grid, Service Bus, Cosmos DB, and Application Insights when you deploy them.

There are no DNAT rules in this lab because inbound web traffic is handled by the load balancer or Application Gateway.

## Network security groups

Each subnet has an NSG tuned to its role:

- **Hub management** – RDP/SSH from the VPN client pool only.  
- **Identity** – directory ports (389/636, 53) plus RDP from the hub or VPN.  
- **Management jumpbox** – RDP from hub, VPN, and optionally on-premises.  
- **Workload web** – HTTP/HTTPS from the internet, RDP from the hub.  
- **Workload app** – port 8080 from the web subnet, RDP from the hub.  
- **Workload data** – port 1433 from the app subnet, RDP from the hub.

A deny-all rule closes the door after the allowed entries. NSGs are created in the landing zone modules so they sit right next to the subnets they protect.

## Route tables and forced tunneling

- When the firewall is on, spokes receive a route table that points `0.0.0.0/0` to the firewall private IP.  
- The hub gateway subnet adds routes for each spoke prefix so VPN traffic is inspected by the firewall.  
- If you deploy a **public** load balancer, the workload web subnet deliberately skips the firewall route to keep inbound and outbound traffic symmetrical. Internal load balancers keep the route so traffic is inspected.  
- When the firewall is off, these route tables are not created, letting Azure’s system routes handle traffic.

## Application Gateway (optional)

If `deploy_application_gateway` is true, the hub gains a WAF_v2 Application Gateway. It lives in its own subnet, uses a small lab-friendly capacity, and forwards to the web tier. Backend IPs are injected after deploy to avoid circular dependencies with the workload module.

## Diagnostics and alerting

- A Log Analytics workspace is created in the management zone when `deploy_log_analytics = true`.  
- Diagnostic settings are enabled for the firewall, VPN gateway, AKS, Application Gateway, and other resources when they exist.  
- Metric alerts can target domain controllers, the firewall, and AKS clusters; an action group sends email notifications.  
- Retention and daily ingestion caps come from the root variables so you can control cost.

## Putting the layers together

1. Traffic leaves a VM and hits its subnet NSG first.  
2. User-defined routes often steer that traffic to the firewall for inspection.  
3. The firewall policy decides whether to allow or deny.  
4. Diagnostic settings and alerts capture the decision for later review.

That sequence delivers defense in depth: even if one layer is misconfigured, another layer still provides coverage.

## Related pages

- [Security landing zone (Pillar 4: Security / Shared Services)](../landing-zones/shared-services.md)
- [Security modules](../modules/security.md)
- [Hardening and hygiene checklist (current lab profile)](../reference/hardening.md)
- [Architecture overview](overview.md)
