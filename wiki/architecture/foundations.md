# Foundations: Cloud Adoption Framework and Microsoft Entra

This page summarizes the two Microsoft foundations that shape this lab. It is intentionally brief and lab-focused. For full detail, follow the official docs linked at the end.

## Cloud Adoption Framework (CAF) in plain language

CAF is Microsoft's lifecycle for cloud adoption. It is less about specific services and more about organizing how teams plan, build, and operate in the cloud.

### CAF lifecycle at a glance
- Strategy: define outcomes, drivers, and success metrics.
- Plan: inventory, prioritize, and sequence what you will adopt.
- Ready: build the landing zone foundation (identity, networking, governance, security, management).
- Adopt: migrate or innovate workloads.
- Govern: enforce policies, cost guardrails, and compliance.
- Manage: operate and improve continuously.

### How this lab maps to CAF
- The lab focuses on the Ready phase by building a multi-pillar landing zone.
- Governance and management are included so you can see policy, logging, and cost controls in action.
- Workload landing zones represent the Adopt phase but keep workloads simple for learning.

### What this lab does not attempt
- Enterprise scale organization design, portfolio strategy, or landing zone automation at the tenant level.
- Full-scale identity federation or production-grade app modernization patterns.
- Organizational change management; this lab is technical by design.

### When to extend the lab
- Add management group hierarchies and policy sets if you are modeling enterprise governance.
- Replace the lab workloads with your own application stacks.
- Introduce platform automation (pipelines, GitOps, or service catalogs) after the basics are stable.

## Microsoft Entra fundamentals for this lab

Microsoft Entra ID (formerly Azure AD) is the identity control plane for Azure. Every subscription belongs to an Entra tenant, and all Azure role assignments are anchored there.

### Core objects you will encounter
- Tenant and directory: your identity boundary for Azure.
- Users and groups: interactive identities and collections.
- Service principals: non-human identities used by automation such as Terraform.
- Managed identities: identity for Azure resources (not used by default in this lab but common in production).
- App registrations: definitions that back service principals and OAuth flows.

### Authentication vs authorization
- Authentication proves who you are (sign-in to Entra).
- Authorization decides what you can do (Azure RBAC roles at management group, subscription, or resource group scopes).
- The lab requires Owner or high-privilege roles for policy and role assignments.

### Entra ID vs AD DS vs Entra Domain Services
- Entra ID is cloud-native identity and RBAC for Azure.
- Active Directory Domain Services (AD DS) is a Windows domain used by VMs and on-prem style workloads.
- Entra Domain Services is a managed domain; this lab uses self-managed AD DS VMs to keep the learning model explicit.

### Identity flows in this lab
- Human admins sign in with Entra to use the portal or Azure CLI.
- Terraform authenticates using a service principal.
- VMs join the AD DS domain for lab scenarios that require Windows authentication and DNS integration.

### Common pitfalls and fixes
- Wrong tenant or subscription: verify the tenant ID and subscription ID in `terraform.tfvars`.
- Missing permissions: Owner is recommended because policy and role assignments need it.
- Expired credentials: rotate the service principal secret and update GitHub secrets.
- DNS confusion: point spokes to the identity DC IPs, not public DNS.

## Quick glossary
- Tenant: the Entra directory boundary for identities.
- Subscription: the billing and resource boundary inside a tenant.
- Management group: a logical container for subscriptions and policies.
- Service principal: application identity used by automation.
- Managed identity: Azure-managed identity for resources.

## Official resources
- Cloud Adoption Framework: https://learn.microsoft.com/azure/cloud-adoption-framework/
- Microsoft Entra fundamentals: https://learn.microsoft.com/entra/fundamentals/what-is-entra
