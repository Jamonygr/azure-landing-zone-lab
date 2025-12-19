# Security modules

These modules provide the core security controls for the lab and are part of **Pillar 4: Security**. They include Azure Firewall for central inspection, firewall policies for rules, Key Vault for secrets, and storage/SQL with private endpoints.

## Module summary

| Module | Purpose | Cost |
|--------|---------|------|
| Firewall | Central traffic inspection | ~$300/month |
| Firewall Rules | Rule collection groups | Free |
| Key Vault | Secrets management | ~$3/month |
| Storage | General-purpose storage | ~$5/month |
| SQL | Managed relational database | ~$5/month |
| Private Endpoint | Private access to PaaS | Free |

## Firewall (`modules/firewall/`)

Creates Azure Firewall with a policy and the required public IP.

| Input | Description | Default |
|-------|-------------|---------|
| `name` | Firewall name | Required |
| `resource_group` | Resource group | Required |
| `location` | Azure region | Required |
| `subnet_id` | AzureFirewallSubnet ID | Required |
| `sku_name` | Firewall SKU | `AZFW_VNet` |
| `sku_tier` | Firewall tier | `Standard` |
| `policy_name` | Policy name | Required |
| `dns_servers` | Custom DNS servers | `[]` |
| `dns_proxy_enabled` | Enable DNS proxy | `true` |
| `threat_intel_mode` | Threat intel mode | `Alert` |

**Outputs:** `firewall_id`, `private_ip`, `public_ip`, `policy_id`

## Firewall rules (`modules/firewall-rules/`)

Attaches rule collection groups to an existing firewall policy.

| Input | Description | Default |
|-------|-------------|---------|
| `name` | Rule collection group name | Required |
| `firewall_policy_id` | Firewall policy ID | Required |
| `priority` | Collection group priority | Required |
| `network_rules` | List of network rule collections | `[]` |
| `application_rules` | List of application rule collections | `[]` |
| `nat_rules` | List of NAT rule collections | `[]` |

**Outputs:** `rule_collection_group_id`

### Rule collection structure
```hcl
network_rules = [{
  name     = "AllowDNS"
  priority = 100
  action   = "Allow"
  rules = [{
    name                  = "DNS"
    source_addresses      = ["10.0.0.0/8"]
    destination_addresses = ["*"]
    destination_ports     = ["53"]
    protocols             = ["UDP", "TCP"]
  }]
}]
```

## Key Vault (`modules/keyvault/`)

Creates an Azure Key Vault with purge protection.

| Input | Description | Default |
|-------|-------------|---------|
| `name` | Key Vault name | Required |
| `resource_group` | Resource group | Required |
| `location` | Azure region | Required |
| `tenant_id` | Azure AD tenant ID | Required |
| `sku` | Key Vault SKU | `standard` |
| `enable_rbac` | Use RBAC for access | `true` |
| `purge_protection` | Enable purge protection | `true` |
| `soft_delete_retention` | Soft delete retention days | `90` |

**Outputs:** `keyvault_id`, `keyvault_uri`, `keyvault_name`

## Storage (`modules/storage/`)

Creates an Azure Storage Account with configurable redundancy.

| Input | Description | Default |
|-------|-------------|---------|
| `name` | Storage account name | Required |
| `resource_group` | Resource group | Required |
| `location` | Azure region | Required |
| `account_tier` | Storage tier | `Standard` |
| `replication_type` | Redundancy type | `LRS` |
| `account_kind` | Storage kind | `StorageV2` |
| `enable_https_only` | Require HTTPS | `true` |
| `min_tls_version` | Minimum TLS version | `TLS1_2` |

**Outputs:** `storage_account_id`, `storage_account_name`, `primary_blob_endpoint`

## SQL (`modules/sql/`)

Creates Azure SQL Database with configurable settings.

| Input | Description | Default |
|-------|-------------|---------|
| `server_name` | SQL Server name | Required |
| `database_name` | Database name | Required |
| `resource_group` | Resource group | Required |
| `location` | Azure region | Required |
| `admin_login` | Admin username | Required |
| `admin_password` | Admin password | Required |
| `sku_name` | Database SKU | `Basic` |
| `min_tls_version` | Minimum TLS | `1.2` |
| `public_network_access` | Allow public access | `false` |

**Outputs:** `sql_server_id`, `sql_server_fqdn`, `database_id`

## Private Endpoint (`modules/private-endpoint/`)

Creates private endpoints for PaaS services.

| Input | Description | Default |
|-------|-------------|---------|
| `name` | Private endpoint name | Required |
| `resource_group` | Resource group | Required |
| `location` | Azure region | Required |
| `subnet_id` | Private endpoint subnet ID | Required |
| `private_connection_resource_id` | Target resource ID | Required |
| `subresource_names` | Private Link subresource | Required |
| `private_dns_zone_ids` | DNS zone IDs for registration | `[]` |

**Outputs:** `private_endpoint_id`, `private_ip_address`

## Usage patterns

### Full security stack
```hcl
deploy_firewall          = true
firewall_sku_tier        = "Standard"
deploy_keyvault          = true
deploy_storage           = true
deploy_sql               = true
deploy_private_endpoints = true
deploy_private_dns_zones = true
```

### Cost-optimized security
```hcl
deploy_firewall          = false  # Saves ~$300/month
deploy_keyvault          = true   # Keep for secrets
deploy_storage           = true   # Keep for diagnostics
deploy_sql               = false  # Disable if not needed
deploy_private_endpoints = false  # Use public endpoints
```
