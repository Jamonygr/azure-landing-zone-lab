# Shared services landing zone

The shared services landing zone provides common PaaS components that multiple applications can use. It keeps secrets, data, and private endpoints in one place so workloads do not duplicate them.

## What you will learn

- Which shared services are available out of the box and how to toggle them.  
- How DNS and firewall settings from other zones are reused here.  
- What outputs you can hand to application teams.

## What it deploys

- A shared services VNet (`10.3.0.0/16`) with an app subnet and a private endpoint subnet.  
- An NSG that allows required traffic from trusted ranges.  
- Optional Key Vault, storage account, and SQL database.  
- Private endpoints for the services above when enabled.  
- An optional route table that sends internet-bound traffic to the hub firewall.

## Inputs to know about

- `deploy_keyvault`, `deploy_storage`, and `deploy_sql` toggle each service.  
- `storage_account_name` is generated with the random suffix passed in from the root to maintain global uniqueness.  
- `sql_admin_login` and `sql_admin_password` set the database admin credentials.  
- `dns_servers` comes from the identity zone so private endpoints resolve correctly.  
- `firewall_private_ip` and `deploy_route_table` align egress with the hub firewall when it is enabled.

## Outputs other zones or teams can use

- `keyvault_uri` for storing secrets.  
- `storage_account_name` for data landing.  
- `sql_server_fqdn` for application connection strings.  
- `vnet_id` and subnet IDs if you want to attach more services later.

## How it behaves

- Uses the tenant ID from `azurerm_client_config` to create Key Vault access policies.  
- Applies the shared tag set so ownership and cost are easy to trace.  
- Keeps routing consistent with the firewall flag; if the firewall is off, the route table is skipped.

## When to enable each service

- **Key Vault** – enable by default to centralize secrets, even in a lab.  
- **Storage** – enable when workloads need a general-purpose landing place for files or diagnostics.  
- **SQL** – enable when you want to demo a stateful back end; leave it off for lighter runs.

## Next step

Explore the [workload landing zone](workload.md) to see how an application stack consumes these shared services.
