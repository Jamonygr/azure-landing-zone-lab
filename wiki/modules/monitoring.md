# Monitoring modules

Monitoring in the lab is built from small modules that create a workspace, an action group, metric alerts, and diagnostic settings. You can reuse these pieces independently.

## Log Analytics

Creates a Log Analytics workspace.  
Inputs: name, resource group, location, SKU, retention days, daily quota in GB, tags.  
Outputs: workspace ID and name.

## Action group

Creates an alert action group with email receivers.  
Inputs: action group name, resource group, short name, list of email receivers, tags.  
Outputs: action group ID.

## Alerts

Creates metric alerts for VMs, AKS, and Azure Firewall based on the flags you set.  
Inputs: resource group, location, alert name prefix, action group ID, enable flags, VM IDs and CPU threshold, AKS cluster ID, firewall ID, tags.  
Outputs: alert IDs.

## Diagnostic settings

Applies diagnostic settings to the resources you specify.  
Inputs: diagnostic name prefix, Log Analytics workspace ID, resource IDs for firewall, VPN gateway, AKS, SQL, Key Vault, storage, NSGs (all optional), and enable flags per resource type.  
Outputs: diagnostic setting IDs.
