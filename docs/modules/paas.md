# PaaS modules

These modules provision popular Azure platform services used by the workload landing zone. They are sized for labs and can be toggled individually.

## Tier 1 – Compute

### AKS

Creates an Azure Kubernetes Service cluster with a minimal node count.  
Inputs: name, resource group, location, DNS prefix, subnet ID, node count, VM size, OS disk size, SKU tier, `private_cluster_enabled`, network plugin and policy, workload identity and OIDC flags, Azure Policy flag, local account setting, Log Analytics workspace ID, tags.  
Outputs: AKS ID, name, and FQDN.

### Functions

Creates a consumption-based Azure Functions app with Application Insights.  
Inputs: name suffix, resource group, location, OS type, runtime and version, whether to enable App Insights, Log Analytics workspace ID, tags.  
Outputs: function app name and ID.

### Static Web App

Creates a free-tier Static Web App.  
Inputs: name suffix, resource group, location, SKU tier and size, tags.  
Outputs: Static Web App name and ID.

### Logic Apps (consumption)

Creates a logic app workflow in consumption mode.  
Inputs: name suffix, resource group, location, tags.  
Outputs: logic app ID.

### Container Apps

Creates a Container Apps Environment and a Container App with minimal resources (0.25 vCPU, 0.5Gi).  
Inputs: name suffix, resource group, location, Log Analytics workspace ID, tags.  
Outputs: Container App ID and environment ID.

### App Service

Creates an App Service plan and web app.  
Inputs: name suffix, resource group, location, SKU tier and size, tags.  
Outputs: plan ID and web app name.

## Tier 2 – Integration

### Event Grid

Creates an Event Grid topic.  
Inputs: name suffix, resource group, location, tags.  
Outputs: topic ID.

### Service Bus

Creates a Basic tier Service Bus namespace.  
Inputs: name suffix, resource group, location, SKU, tags.  
Outputs: Service Bus namespace ID.

### Event Hubs

Creates an Event Hubs namespace (Basic tier) with a default hub.  
Inputs: name suffix, resource group, location, SKU, capacity, tags.  
Outputs: Event Hubs namespace ID and hub ID.

### API Management

Creates an API Management instance in Consumption tier.  
Inputs: name suffix, resource group, location, publisher name and email, SKU name, tags.  
Outputs: API Management ID and gateway URL.

## Tier 3 – Data

### Cosmos DB

Creates a serverless Cosmos DB account.  
Inputs: name suffix, resource group, location, account kind, tags.  
Outputs: Cosmos DB account ID and endpoint.

### Storage

Creates a storage account.  
Inputs: name, resource group, location, account tier, replication type, whether nested items can be public, tags.  
Outputs: storage account ID and name.

### SQL

Creates a SQL Server and database.  
Inputs: name suffix, resource group, location, admin login and password, tags.  
Outputs: SQL server ID, FQDN, and database ID.
