# Certification skill matrix

<p align="center">
  <img src="../images/certifications-skill-matrix.svg" alt="Certification skill matrix banner" width="1000" />
</p>


Use this matrix to see how each certification objective aligns with the repository. The intent is to make it easy to locate the right modules, docs, and hands-on tasks.

## Identity and governance

Repo components:
- `landing-zones/governance`
- `modules/management-groups`, `modules/policy`, `modules/rbac`, `modules/regulatory-compliance`
- `policies/`

AZ-104 focus:
- Build and review management groups, RBAC, and policy compliance.
- Practice tagging and governance enforcement.

AZ-305 focus:
- Design a governance model for multiple environments and teams.
- Decide where to enforce vs. audit policy.

AZ-400 focus:
- Treat policy as code and integrate checks into CI.
- Enforce naming and tagging through pipeline gates.

Practice tasks:
- Add a required tag and evaluate compliance drift in a plan.
- Document the management group hierarchy and RBAC roles.

## Networking and connectivity

Repo components:
- `landing-zones/networking`
- `modules/networking/*`

AZ-104 focus:
- Validate hub-spoke routing, peering, NSGs, and VPN configuration.

AZ-305 focus:
- Design connectivity and segmentation; choose firewall vs. NAT.

AZ-400 focus:
- Automate network policy checks (NSGs, routes) in the pipeline.

Practice tasks:
- Toggle `deploy_firewall` and compare routing behavior.
- Enable VPN and on-prem simulation for hybrid path testing.

## Compute and application platform

Repo components:
- `modules/compute/*`
- `landing-zones/management`, `landing-zones/workload`
- `modules/aks`, `modules/app-service`, `modules/functions`

AZ-104 focus:
- Manage VM sizing, scale, and access patterns.

AZ-305 focus:
- Design compute tiers and decide where to use PaaS vs. IaaS.

AZ-400 focus:
- Standardize compute modules and validate outputs in CI.

Practice tasks:
- Scale web servers with `lb_web_server_count` and evaluate impact.
- Switch between VM and PaaS options for a workload.

## Data and storage

Repo components:
- `modules/storage`, `modules/sql`, `modules/cosmos-db`
- `landing-zones/security/shared-services`

AZ-104 focus:
- Validate storage configuration, private endpoints, and diagnostics.

AZ-305 focus:
- Design data tiers and private connectivity for sensitive data.

AZ-400 focus:
- Automate data security checks (private endpoints, encryption settings).

Practice tasks:
- Confirm private endpoint resolution in shared services.
- Review data service outputs and document access flows.

## Security and compliance

Repo components:
- `modules/firewall`, `modules/keyvault`, `modules/private-endpoint`
- `modules/regulatory-compliance`
- `.github/actions/security`, `.github/actions/secret-scan`

AZ-104 focus:
- Operate firewall and private endpoints; monitor diagnostics.

AZ-305 focus:
- Design layered security and compliance posture.

AZ-400 focus:
- Integrate security scanning and secret detection into CI.

Practice tasks:
- Enable private endpoints and private DNS, validate access paths.
- Review Gitleaks, tfsec, and Checkov findings.

## Monitoring and operations

Repo components:
- `modules/monitoring/*`
- `landing-zones/management`

AZ-104 focus:
- Configure Log Analytics, diagnostics, and alerts.

AZ-305 focus:
- Design monitoring and operational readiness for scale.

AZ-400 focus:
- Export metrics and make pipeline results actionable.

Practice tasks:
- Adjust `log_retention_days` and review workspace settings.
- Inspect pipeline `metrics` and `resource-inventory` artifacts.

## DevOps and automation

Repo components:
- `.github/workflows/terraform.yml`
- `.github/actions/*`
- `.pre-commit-config.yaml`, `.gitleaks.toml`

AZ-104 focus:
- Run plans safely and review outputs.

AZ-305 focus:
- Decide on release gates and manual approvals for prod.

AZ-400 focus:
- Build, test, and secure the pipeline.

Practice tasks:
- Add a PR check or scheduled plan to detect drift.
- Wire Terratest into the workflow to validate live deployments.

## Related pages

- [Certification lab workbook](lab-workbook.md)
- [Certification alignment](README.md)
- [Module design patterns](../modules/README.md)
