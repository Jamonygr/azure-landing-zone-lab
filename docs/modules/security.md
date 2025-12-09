# Security modules

These modules provide the core security controls for the lab: Azure Firewall for central inspection, firewall policies for rules, and Key Vault for secrets.

## Firewall

Creates Azure Firewall with a policy and the required public IP. Supports custom DNS servers, DNS proxy, and threat intelligence mode.  
Inputs: name, resource group, location, subnet ID, SKU name and tier, policy name, DNS servers, whether DNS proxy is enabled, threat intel mode, tags.  
Outputs: firewall ID, private IP, public IP, and firewall policy ID.

## Firewall rules

Attaches rule collection groups to an existing firewall policy. Handles network, application, and NAT rule collections.  
Inputs: name, firewall policy ID, priority, lists of network/application/NAT rule collections.  
Outputs: rule collection group ID.

## Key Vault

Creates an Azure Key Vault with purge protection aligned to the provider settings.  
Inputs: name, resource group, location, tenant ID, SKU, whether RBAC is enabled, purge protection flag, tags.  
Outputs: Key Vault ID and URI.
