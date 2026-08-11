# Azure Landing Zone Lab

[![Terraform Pipeline](https://github.com/Jamonygr/azure-landing-zone-lab/actions/workflows/terraform.yml/badge.svg)](https://github.com/Jamonygr/azure-landing-zone-lab/actions/workflows/terraform.yml)
[![Terraform](https://img.shields.io/badge/terraform-1.15.8-844FBA?logo=terraform&logoColor=white)](https://developer.hashicorp.com/terraform)
[![AzureRM](https://img.shields.io/badge/azurerm-~%3E%204.0-0078D4?logo=microsoftazure&logoColor=white)](https://registry.terraform.io/providers/hashicorp/azurerm/latest)
[![License: MIT](https://img.shields.io/github/license/Jamonygr/azure-landing-zone-lab)](LICENSE)
[![GitHub stars](https://img.shields.io/github/stars/Jamonygr/azure-landing-zone-lab?style=flat)](https://github.com/Jamonygr/azure-landing-zone-lab/stargazers)

A cost-conscious Terraform lab for learning Azure landing-zone architecture:
hub-and-spoke networking, identity, management, governance, security, private
connectivity, monitoring, policy, and workload services.

> This is a hardened learning environment, not a production-ready landing
> zone. The `prod` profile demonstrates production-like controls while keeping
> lab-sized SKUs and disposable-resource behavior.

![Architecture overview](wiki/images/diagrams/architecture-overview.svg)

## Topology at a glance

```mermaid
graph TB
    INET([Internet])
    ONPREM([Simulated on-premises<br/>10.100.0.0/16])

    subgraph HUB["Hub VNet 10.0.0.0/16 - Pillar 1: Networking"]
        FW["Azure Firewall"]
        VPN["VPN Gateway (optional)"]
        AGW["App Gateway WAF (optional)"]
        NAT["NAT Gateway (optional)"]
    end

    subgraph SPOKES["Spoke VNets"]
        IDN["Identity 10.1.0.0/16<br/>DC01 / DC02 + DNS"]
        MGMT["Management 10.2.0.0/16<br/>Jumpbox + Log Analytics"]
        SHARED["Shared services 10.3.0.0/16<br/>Key Vault / Storage / SQL"]
        PROD["Workload prod 10.10.0.0/16<br/>web / app / data / AKS"]
        DEV["Workload dev 10.11.0.0/16<br/>web / app / data"]
    end

    GOV["Governance - Pillar 3<br/>Management groups / Policy / Budgets / RBAC"]

    INET --> AGW
    INET <--> FW
    ONPREM <-. site-to-site VPN .-> VPN
    FW <--> IDN
    FW <--> MGMT
    FW <--> SHARED
    FW <--> PROD
    FW <--> DEV
    GOV -. applies to all .-> HUB
    GOV -. applies to all .-> SPOKES
```

Every spoke peers to the hub; when the firewall is enabled, user-defined
routes force spoke traffic through it. See the
[network topology](wiki/architecture/network-topology.md) page for routing
details and guardrails.

## What is included

- Hub-and-spoke VNets, peerings, routing, VPN options, Firewall, WAF, NAT, and
  VNet flow logs.
- Identity, jumpbox, shared services, Key Vault, Storage, SQL, AKS, and optional
  PaaS workload modules.
- Azure Policy, management groups, cost budgets, regulatory initiatives, RBAC,
  monitoring, backup, workbooks, and scheduled VM start/stop.
- Four profiles: `cheap-lab`, `lab`, `dev`, and `prod` (production-like lab).
- OIDC-only GitHub Actions with blocking Terraform, lint, policy, security,
  documentation, and Go checks.

The generated [Terraform reference](TERRAFORM.md) is the canonical list of root
inputs and outputs. Each directory under `modules/` and `landing-zones/` also
contains a generated module reference.

## Environment profiles

Four tracked profiles in `environments/` scale the same topology up or down.
Costs are rough lab estimates, not guarantees.

| Feature | `cheap-lab` | `lab` | `dev` | `prod` |
|---|---|---|---|---|
| Azure Firewall (~$300/mo) | – | ✔ | – | ✔ |
| VPN Gateway + on-prem sim (~$140/mo) | – | – | – | ✔ |
| Application Gateway WAF | – | ✔ Detection | ✔ Detection | ✔ Prevention |
| NAT Gateway / Load Balancer | – | ✔ | – | ✔ |
| Workload spokes | prod only | prod + dev | dev only | prod only |
| AKS | – | – | – | ✔ 2 nodes |
| PaaS bundle (Functions, Cosmos, Service Bus…) | – | ✔ | – | ✔ defaults |
| Secondary domain controller | – | – | – | ✔ |
| Auto-shutdown | ✔ | ✔ | ✔ | – |
| Log quota / retention | 0.5 GB/day, 30d | 2 GB/day, 30d | 0.5 GB/day, 30d | 5 GB/day, 30d |
| Est. monthly cost | ~$50 | ~$100–150 | ~$60–80 | ~$300+ |

Profiles only pin the flags they change; anything unset falls back to the
defaults in `variables.tf`. AKS, the load balancer, and the PaaS bundle live
in the prod workload spoke, so they require `deploy_workload_prod = true`.

See the [environment profiles guide](wiki/reference/environments.md) for the
full feature matrix and a decision tree.

## Prerequisites

- Terraform 1.15.8
- Azure CLI and an Azure subscription you are allowed to use
- PowerShell 7 for repository helper scripts
- Optional local checks: TFLint 0.63.1, Trivy 0.72.0, Checkov, Gitleaks,
  actionlint 1.7.12, pre-commit, Go, and terraform-docs 0.24.0

Confirm the subscription before any plan against remote state:

```powershell
az login
az account show --output table
terraform version
```

## Secure quick start

1. Start with the cheapest profile and review its feature flags.

   ```powershell
   Copy-Item environments/cheap-lab.tfvars terraform.tfvars
   ```

2. Keep passwords and VPN keys out of files and shell history. Generate them
   for the current session or allow Terraform to generate them:

   ```powershell
   $env:TF_VAR_admin_password = '<generated-password>'
   $env:TF_VAR_sql_admin_password = '<generated-password>'
   $env:TF_VAR_vpn_shared_key = '<generated-shared-key>'
   ```

3. Run local checks without touching Azure resources:

   ```powershell
   terraform init -backend=false -lockfile=readonly
   terraform fmt -check -recursive
   terraform validate
   terraform test
   tflint --init
   tflint --recursive
   trivy config --severity MEDIUM,HIGH,CRITICAL --ignorefile .trivyignore.yaml .
   ```

4. For a real deployment, configure the protected state backend and GitHub
   OIDC environments in the [pipeline setup guide](.github/SETUP.md). Run a
   manual `plan` first. Apply and destroy are never triggered by pull requests
   or ordinary pushes.

## Cost and safety

Azure Firewall, VPN Gateway, Application Gateway WAF, NAT Gateway, AKS, public
IPs, Log Analytics ingestion, and retained flow logs can create meaningful
charges. Begin with `cheap-lab`, inspect the saved plan and cost estimate, and
destroy disposable resources when finished.

The lab intentionally keeps several teardown-friendly or low-cost defaults,
including optional purge protection, short flow-log retention, and basic SKUs.
Accepted findings and compensating controls are recorded in
[SECURITY_EXCEPTIONS.md](SECURITY_EXCEPTIONS.md). Do not copy these exceptions
into production without a separate risk review.

## Automation model

- Pull requests receive no Azure OIDC token. They run formatting, validation,
  Terraform tests, TFLint, Trivy, Checkov, Gitleaks, Conftest fixtures,
  documentation drift, actionlint, and Go tests.
- Pushes to protected `main` may create a read-only saved plan for `lab`.
- `apply` requires a manual workflow dispatch and the selected GitHub
  environment.
- `destroy` additionally requires the exact text `DESTROY <environment>` and a
  protected destroy environment.
- The state account uses Microsoft Entra authentication, versioning, soft
  delete, and a delete lock; no storage account key is required by CI.

## Documentation

![Documentation map](wiki/images/diagrams/documentation-map.svg)

- [Documentation home](wiki/README.md)
- [Architecture](wiki/architecture/overview.md)
- [Landing zones](wiki/landing-zones/README.md)
- [Module guide](wiki/modules/README.md)
- [Environment profiles](wiki/reference/environments.md)
- [Testing guide](wiki/testing/lab-testing-guide.md)
- [Live provisioning validation](wiki/testing/live-provisioning-validation.md)
- [State and secrets](wiki/reference/state-and-secrets.md)
- [Pipeline reference](wiki/reference/pipeline.md)
- [Contributing](CONTRIBUTING.md)
- [Security policy](SECURITY.md)

## License and responsibility

Use the lab only in subscriptions where you have authorization. Review Azure
costs and organizational policy before deploying. You remain responsible for
resources, data, access, and charges created by your runs.
