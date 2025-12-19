# Governance Pillar

The Governance pillar provides policy enforcement, cost control, compliance frameworks, and RBAC customization for the entire landing zone. It runs last in the deployment sequence because it applies policies and role definitions that reference existing resources.

## What you will learn

- How management groups organize subscriptions for policy inheritance.
- How Azure Policy enforces standards across the environment.
- How cost management budgets and alerts prevent overspend.
- How custom RBAC roles implement least-privilege access.
- How regulatory compliance policies (HIPAA, PCI-DSS) are applied in audit mode.

## Components

| Component | Module | Purpose |
|-----------|--------|---------|
| **Management Groups** | `modules/management-groups/` | Hierarchical organization for subscriptions |
| **Azure Policy** | `modules/policy/` | Location restrictions, required tags, security baselines |
| **Cost Management** | `modules/cost-management/` | Monthly budgets, anomaly alerts, action groups |
| **RBAC Custom Roles** | `modules/rbac/` | Network Operator, Backup Operator, Monitoring Reader |
| **Regulatory Compliance** | `modules/regulatory-compliance/` | HIPAA, PCI-DSS policy assignments |

## Management Groups

When `deploy_management_groups = true`, the following hierarchy is created:

```
Tenant Root Group
└── org-root (your root)
    ├── org-root-platform
    │   ├── org-root-platform-identity
    │   ├── org-root-platform-management
    │   └── org-root-platform-connectivity
    ├── org-root-landing-zones
    │   ├── org-root-landing-zones-corp
    │   └── org-root-landing-zones-online
    ├── org-root-sandbox
    └── org-root-decommissioned
```

Subscriptions can be assigned to any management group for policy inheritance.

## Azure Policy Assignments

When `deploy_azure_policy = true`:

| Policy | Effect | Purpose |
|--------|--------|---------|
| **Allowed Locations** | Deny | Restrict resource creation to approved regions |
| **Required Tags** | Deny | Enforce Environment, Owner, Project tags on all resources |
| **HTTPS Storage** | Deny | Require secure transfer for storage accounts |
| **NSG on Subnet** | Audit | Ensure subnets have network security groups |
| **Audit Public Access** | Audit | Flag resources with public network access |

Configure policies in `terraform.tfvars`:

```hcl
deploy_azure_policy = true
policy_allowed_locations = ["eastus", "eastus2", "westeurope", "westus2"]
policy_required_tags = {
  Environment = "lab"
  Owner       = "Lab-User"
  Project     = "azlab"
}
```

## Cost Management

When `deploy_cost_management = true`:

| Resource | Configuration |
|----------|---------------|
| **Monthly Budget** | Configurable amount (default: $500) |
| **Action Group** | Email notifications for cost alerts |
| **Anomaly Alert** | Detects unusual spending patterns |

Budget thresholds trigger alerts at 50%, 75%, 90%, and 100% of the monthly budget.

```hcl
deploy_cost_management = true
cost_budget_amount     = 500
cost_alert_emails      = ["admin@example.com"]
```

## Custom RBAC Roles

When `deploy_rbac_custom_roles = true`:

| Role | Permissions |
|------|-------------|
| **Network Operator** | Read/write on network resources (VNets, NSGs, route tables) |
| **Backup Operator** | Manage Recovery Services vaults and backup policies |
| **Monitoring Reader** | Read access to Log Analytics, alerts, and metrics |

These roles follow the principle of least privilege and can be assigned to users or service principals.

## Regulatory Compliance

When `deploy_regulatory_compliance = true`:

| Framework | Policy Initiative | Mode |
|-----------|-------------------|------|
| **HIPAA HITRUST 9.2** | Azure regulatory compliance | Audit (DoNotEnforce) |
| **PCI-DSS 3.2.1** | Azure regulatory compliance | Audit (DoNotEnforce) |

Compliance policies are applied in **audit mode** by default to avoid blocking resources during development. Set `compliance_enforcement_mode = "Default"` for production enforcement.

```hcl
deploy_regulatory_compliance = true
enable_hipaa_compliance      = true
enable_pci_dss_compliance    = true
compliance_enforcement_mode  = "DoNotEnforce"  # Audit only
```

## Deployment flags

| Flag | Default | Purpose |
|------|---------|---------|
| `deploy_management_groups` | `true` | Create management group hierarchy |
| `deploy_azure_policy` | `true` | Enable policy assignments |
| `deploy_cost_management` | `true` | Enable budget and alerts |
| `deploy_rbac_custom_roles` | `true` | Create custom RBAC roles |
| `deploy_regulatory_compliance` | `true` | Enable HIPAA/PCI-DSS policies |

## Dependencies

- Governance runs after all other pillars to ensure resources exist for policy scoping.
- Cost management uses the Management resource group for the action group.
- Regulatory compliance targets the workload prod resource group (or shared if prod is disabled).
- Log Analytics workspace ID is passed for compliance logging (optional).

## Best practices

1. **Start with audit mode** - Use `compliance_enforcement_mode = "DoNotEnforce"` until you validate policies.
2. **Restrict locations early** - Prevent accidental deployments to non-compliant regions.
3. **Require tags** - Enforce cost allocation and ownership from day one.
4. **Set realistic budgets** - Configure cost alerts before deploying expensive resources.
5. **Use custom roles** - Avoid Owner/Contributor where specific permissions suffice.

## Next steps

- Review the [policy module](../modules/governance.md) for customization options.
- Check the [cost estimation](../../README.md#-cost-estimation) section in the main README.
- See [hardening checklist](../reference/hardening.md) for production-ready settings.
