# Azure Landing Zone Lab documentation

Azure Landing Zone Lab is a hands-on, Terraform-first walkthrough of the Cloud Adoption Framework hub-and-spoke design. It is written for people who want to see the moving parts of an Azure landing zone without needing to be Terraform experts. Follow these articles in order and you will understand what deploys, why it matters, and which switches you can safely toggle.

## Who this is for

- Cloud engineers who need a guided tour of CAF concepts backed by runnable code.
- Students and hobbyists who want a safe sandbox to learn hybrid networking, firewalls, and PaaS.
- Teams evaluating landing-zone patterns before building out an enterprise platform.

## What you will deploy

- A hub VNet with Azure Firewall, optional VPN Gateway, and optional Application Gateway.
- Spoke VNets for identity, management, shared services, and one or more workloads.
- Optional hybrid link to a simulated on-premises VNet.
- Monitoring via Log Analytics with diagnostics wired to key resources.

Everything is controlled with variables and feature flags so you can scale the footprint up or down to fit a demo or proof of concept.

The fastest way to change the footprint is the **MASTER CONTROL PANEL** at the top of `terraform.tfvars` (all `deploy_*` / `enable_*` switches in one place).

## How to use these docs

1) Start with **Architecture** to see how the Terraform files fit together.  
2) Move to **Landing zones** to understand each slice of the platform.  
3) Check **Modules** if you want to reuse a building block in your own code.  
4) Refer to **Reference** for variables, outputs, and naming while you edit `terraform.tfvars`.  
5) Use **Lab testing** after your first apply to confirm everything works end to end.

## Article map

| Topic | What you will learn |
|-------|---------------------|
| [Architecture overview](architecture/overview.md) | How the root module orchestrates resource groups, landing zones, and shared resources. |
| [Network topology](architecture/network-topology.md) | Address spaces, subnets, peering, and routing choices. |
| [Security model](architecture/security-model.md) | How firewall, NSGs, and diagnostics layer together. |
| [Configuration flow](architecture/configuration-flow.md) | How values move from `tfvars` through locals, modules, and outputs. |
| [Landing zones overview](landing-zones/README.md) | What each landing zone owns and how they connect. |
| [Hub](landing-zones/hub.md) | Central connectivity: firewall, VPN, gateway transit. |
| [Identity](landing-zones/identity.md) | Domain controllers and DNS for the platform. |
| [Management](landing-zones/management.md) | Jumpbox and monitoring workspace. |
| [Shared services](landing-zones/shared-services.md) | Key Vault, storage, SQL, and private endpoints. |
| [Workload](landing-zones/workload.md) | Web/app/data tiers, load balancer, AKS, and optional PaaS. |
| [On-premises simulated](landing-zones/onprem-simulated.md) | A small on-prem VNet to test VPN connectivity. |
| [Module design patterns](modules/README.md) | How each reusable module is built and consumed. |
| [Networking modules](modules/networking.md) | VNets, subnets, NSGs, peering, routing, VPN, load balancer. |
| [Compute modules](modules/compute.md) | Windows VMs and IIS web servers. |
| [Security modules](modules/security.md) | Firewall, firewall rules, and Key Vault. |
| [Monitoring modules](modules/monitoring.md) | Log Analytics, alerts, diagnostic settings. |
| [PaaS modules](modules/paas.md) | AKS and common Azure services for apps. |
| [Variables reference](reference/variables.md) | The inputs you set in `terraform.tfvars`. |
| [Outputs reference](reference/outputs.md) | What the deployment returns for downstream use. |
| [Naming conventions](reference/naming-conventions.md) | CAF-aligned names and tags used throughout. |
| [Terraform patterns](reference/terraform-patterns.md) | Reusable HCL idioms in this repo. |
| [**CI/CD Pipeline**](reference/pipeline.md) | GitHub Actions workflow for automated deployments. |
| [Current config (westus2 lab profile)](reference/current-config.md) | Snapshot of the active lab profile and access path. |
| [Hardening checklist](reference/hardening.md) | Quick steps to lock down the current lab profile. |
| [Lab testing guide](testing/lab-testing-guide.md) | Step-by-step validation checklist after deployment. |

## Before you start

- Azure subscription with Owner or Contributor rights.
- Terraform 1.9 or later.
- Azure CLI signed in (`az login`).
- Rough budget awareness: Azure Firewall and VPN Gateway accrue notable hourly cost. Toggle `deploy_firewall` or `deploy_vpn_gateway` to control spend.

> **Note:** This project uses both **AzureRM** (~> 4.0) and **AzAPI** (~> 2.0) providers. AzAPI is required for VNet Flow Logs (the modern replacement for deprecated NSG Flow Logs).

## Quick path

1. Copy `terraform.tfvars.example` to `terraform.tfvars`.  
2. Set your subscription ID, admin credentials, and any feature flags.  
3. Run `terraform init`, then `terraform apply`.  
4. Use the outputs file to connect to VMs, firewall, and VPN endpoints.

## Helpful Microsoft resources

- [Cloud Adoption Framework](https://learn.microsoft.com/azure/cloud-adoption-framework/) for the concepts behind this lab.
- [Azure Landing Zones](https://learn.microsoft.com/azure/architecture/landing-zones/) for design guidance.
- [Terraform AzureRM provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs) for resource-specific settings.
