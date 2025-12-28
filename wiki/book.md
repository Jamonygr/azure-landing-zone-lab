# Azure Landing Zone Lab - Book-Style Guide

This guide stitches the entire repository together so you can understand the Terraform logic, deployment flow, and CI/CD pipeline end to end. It is organized to be read like a small book. Each section links back to the existing reference pages for deeper detail. The emphasis is lab-scale clarity rather than production-scale completeness.

## How to read this guide
- Part 0 explains the Microsoft foundations (CAF and Entra) that shape the lab.
- Part 1 orients you to the repo layout, the master control panel, and environment profiles.
- Part 2 traces how values move from tfvars into locals, modules, and resources.
- Part 3 describes each landing zone and how the hub-and-spoke model works.
- Part 4 explains the CI/CD pipeline and how to customize it.
- Part 5 and Part 6 focus on operating the lab and common Terraform patterns.
- Parts 10 and 11 map the lab to certification practice.

If you are new, start with Part 0 and Part 1, then jump to the landing zone you are most interested in.

## What this guide assumes
- You have a subscription, can run Terraform 1.9+, and can authenticate to Azure.
- You will drive the lab mostly through `terraform.tfvars` and `environments/*.tfvars`.
- You want a practical, lab-sized view of CAF-aligned landing zones.
- You may toggle features on and off to control cost and complexity.

---

## Part 0 - Foundations (CAF and Entra)

### Cloud Adoption Framework, as used here
The Cloud Adoption Framework (CAF) is a lifecycle model that helps teams plan, build, and operate in the cloud. This lab focuses on the Ready phase by building a landing zone foundation, then touches the Govern and Manage phases by adding policy, logging, and cost controls.

CAF lifecycle in one line each:
- Strategy: define outcomes, drivers, and success metrics.
- Plan: inventory, prioritize, and sequence what you will adopt.
- Ready: build the platform foundation (identity, networking, governance, security, management).
- Adopt: migrate or innovate workloads.
- Govern: enforce policies, cost guardrails, and compliance.
- Manage: operate and improve continuously.

This lab is intentionally small but maps each pillar to a real CAF concept. It is meant to help you see how a landing zone is assembled, not to replace an enterprise-scale platform.

### Microsoft Entra fundamentals for this lab
Microsoft Entra ID (formerly Azure AD) is the identity control plane for Azure. Your subscription belongs to an Entra tenant, and every role assignment uses Entra identities.

Key ideas used by this lab:
- Tenants are identity boundaries; subscriptions live inside tenants.
- Users, groups, and service principals are Entra identities.
- Authentication proves who you are; authorization (RBAC) grants access.
- The lab uses AD DS VMs for Windows domain scenarios, but Entra remains the source of truth for Azure access.

The identity landing zone simulates the on-prem style directory while Entra handles access to Azure resources and Terraform automation.

### Where to go deeper
- `wiki/architecture/foundations.md` for a longer CAF and Entra primer.
- `wiki/landing-zones/identity.md` for how AD DS and DNS are implemented here.

---

## Part 1 - Orientation

### Repository layout (top level)
- `backend.tf` - azurerm backend definition; the pipeline injects the RG/account/key at init time.
- `main.tf` - root module orchestrator that stitches together hub, identity, management, shared services, workload, VPN/on-prem, PaaS, and observability blocks.
- `variables.tf`, `locals.tf`, `terraform.tfvars` - input surface and default shaping. The MASTER CONTROL PANEL at the top of `terraform.tfvars` drives deploy/enable switches.
- `landing-zones/` - per-zone compositions (hub, identity, management, shared, workload, on-prem).
- `modules/` - reusable building blocks (networking, compute, security, monitoring, PaaS).
- `environments/` - per-environment `*.tfvars` (lab/dev/prod) used by the pipeline to isolate state.
- `.github/workflows/terraform.yml` - orchestrator workflow (15 visible jobs).
- `.github/actions/` - composite actions for plan/apply/destroy plus cost, graph, docs, policy, secrets, inventory, changelog, metrics, terratest.
- `wiki/` - documentation hub (this guide, reference pages, testing, hardening, etc.).

### Documentation map
- `wiki/README.md` is the index to all pages.
- Architecture pages explain how values and dependencies flow.
- Landing zone pages describe what each pillar deploys.
- Module pages explain reusable building blocks.
- Reference pages document variables, outputs, and pipeline behavior.

### Providers and backend
- Providers: AzureRM ~> 4.x and AzAPI ~> 2.x (AzAPI needed for modern features like VNet Flow Logs).
- Backend: azurerm with container `tfstate`; key is `<environment>.terraform.tfstate`; set via pipeline/backend config.
- State isolation: each environment (lab/dev/prod) maps to its own key; locks are blob leases.

### Feature flags and profiles
- MASTER CONTROL PANEL in `terraform.tfvars` groups all `deploy_*` / `enable_*` flags.
- Common switches: `deploy_firewall`, `deploy_vpn_gateway`, `deploy_application_gateway`, `deploy_workload_prod`, `deploy_workload_dev`, `deploy_private_endpoints`, `deploy_nat_gateway`, `deploy_aks`, PaaS flags, observability flags.
- Profiles (see README tables): Minimal, Standard, Standard+PaaS, Full Hybrid, Enterprise.

### Environment profiles
- `environments/lab.tfvars`, `dev.tfvars`, and `prod.tfvars` override the same variables with different sizes, regions, and feature flags.
- The pipeline chooses the profile and state key based on the environment input.
- Locals normalize names and tags so each environment stays consistent.

---

## Part 2 - Terraform logic flow

### Input -> locals -> modules -> resources
1. Inputs: `terraform.tfvars` (or `environments/*.tfvars`) provide subscription, region, credentials, and all feature flags.
2. Locals: `locals.tf` normalizes names (CAF-inspired), derives region short codes, builds tags, and maps feature flags into per-module settings.
3. Modules: `main.tf` instantiates modules with locals/variables; optional blocks are wrapped in `count`/`for_each` or conditional module calls.
4. Resources: Modules emit Azure resources (VNets, subnets, VMs, Key Vault, Storage, SQL, firewall, VPN, private endpoints, AKS, etc.) along with diagnostics and role assignments.
5. Outputs: `outputs.tf` returns connection info (IPs, FQDNs, credentials), resource IDs, and diagnostics endpoints for post-deploy testing.

### Variable precedence and shaping
- Defaults live in `variables.tf`.
- `terraform.tfvars` is the primary override for local runs.
- `environments/*.tfvars` override the same variables in pipeline runs.
- `locals.tf` is the opinionated translator that turns inputs into consistent naming, tags, and module-friendly structures.

### Dependency approach
- Network-first: hub VNet and subnets created before spokes; peering ensures routing; firewall/VPN/App Gateway depend on subnets.
- Identity bootstrap: domain controller provisioned early; other VMs can join domain when enabled.
- Security layering: NSGs, firewall, and diagnostic settings applied as part of module outputs; private DNS and endpoints gated by flags.
- Observability: Log Analytics workspace created up front when `deploy_log_analytics=true`; diagnostics from network, compute, and PaaS feed into it.
- Optional stacks:
  - Hybrid/VPN when `deploy_vpn_gateway` and `deploy_onprem_simulation` are enabled.
  - App platform via PaaS flags (Functions, Logic Apps, Event Grid, Service Bus, App Service, Static Web Apps, Cosmos DB).
  - AKS when `deploy_aks=true` (disabled by default to reduce time/cost).

### Configuration shaping patterns (HCL idioms used here)
- `count`/`for_each` to toggle optional modules and to create per-zone subnets.
- `local` maps to centralize naming/tagging and avoid duplication.
- `depends_on` used sparingly; preference for implicit dependencies via inputs (IDs, subnet names, workspace IDs).
- Dynamic blocks inside modules for NSG rules, route tables, and diagnostic settings.
- `try()` and `lookup()` used in locals to keep optional inputs safe.

### Outputs as hand-off contracts
- Outputs expose IPs/FQDNs (LB frontend, jumpbox, firewall DNAT, VPN), credentials placeholders, resource IDs, and workspace info.
- Testing flows: web load balancer round-robin, RDP via jumpbox or firewall DNAT, VPN connectivity, log ingestion checks (see `wiki/testing/lab-testing-guide.md`).

---

## Part 3 - Modules and landing zones

### Landing-zone compositions (`landing-zones/`)
- Hub: VNet, subnets for gateway/firewall/management/appgw, optional Azure Firewall, optional VPN Gateway, optional Application Gateway; peering anchor for spokes.
- Identity: Domain controller VM(s), DNS config, optional secondary DC.
- Management: Jumpbox VM (optionally with public IP), Log Analytics workspace, diagnostics wiring.
- Shared services: Key Vault, Storage, SQL DB, private endpoints, private DNS (when enabled).
- Workload: Web/app/data subnets, load balancer, IIS web servers, optional AKS, optional PaaS attachments, NAT Gateway, ASGs.
- On-prem simulated: Optional VNet, file server, VPN gateway to test S2S.

### How zones fit together
- The hub is the routing and security anchor.
- Spokes peer to the hub and send default routes through the firewall when enabled.
- Identity provides DNS so resources can resolve names consistently.
- Management centralizes monitoring and operations.
- Shared services provide security and data services for workloads.

### Reusable modules (`modules/`)
- Networking: VNet/subnet creation, peering, route tables, NSGs, VPN gateway, firewall, Application Gateway, load balancer, NAT Gateway, private endpoints, private DNS.
- Compute: Windows VMs for DC, jumpbox, IIS web tier; VMSS not used to keep complexity low.
- Security: Firewall policies/rules, Key Vault access policies, role assignments where needed.
- Monitoring: Log Analytics workspace, diagnostic settings, Traffic Analytics, VNet Flow Logs (via AzAPI).
- PaaS: AKS cluster, Functions, Logic Apps, Event Grid, Service Bus, App Service, Static Web Apps, Cosmos DB (enabled by flags).
- Governance: management groups, policy assignments, cost budgets, and RBAC roles.

### Naming and tagging
- CAF-aligned names produced by locals; tags include `project`, `environment`, `owner`, and optional cost/role metadata.
- See `wiki/reference/naming-conventions.md` for the pattern and examples.

### Outputs and access
- Outputs expose IPs/FQDNs (LB frontend, jumpbox, firewall DNAT, VPN), credentials placeholders, resource IDs, and workspace info.
- Testing flows: web load balancer round-robin, RDP via jumpbox or firewall DNAT, VPN connectivity, log ingestion checks (see `wiki/testing/lab-testing-guide.md`).

---

## Part 4 - CI/CD pipeline (GitHub Actions)

### Overview
- File: `.github/workflows/terraform.yml`
- Jobs: 15 visible stages with concurrency guard `terraform-${ref}-${environment}`.
- Secrets required: `AZURE_CLIENT_ID`, `AZURE_CLIENT_SECRET`, `AZURE_SUBSCRIPTION_ID`, `AZURE_TENANT_ID`, `AZURE_CREDENTIALS`, `TF_STATE_RG`, `TF_STATE_SA`, optional `INFRACOST_API_KEY`.

### Job sequence
1) 1xx Format Check - `terraform fmt -check -recursive`
2) 2xx Validate - `terraform init -backend=false` + `terraform validate`
3) 3xx Security - tfsec - SARIF upload (soft-fail)
4) 3xx Security - Checkov - SARIF upload (soft-fail)
5) 3xx Security - Secrets - Gitleaks scan
6) 4xx Lint - TFLint - Azure rules (soft-fail)
7) 4xx Lint - Policy - Conftest OPA policies against `tfplan.json` (soft-fail by default)
8) 4xx Lint - Docs - `terraform-docs` for root and modules (artifact)
9) 5xx Analysis - Graph - Terraform graph -> SVG (artifact)
10) 5xx Analysis - Versions - Terraform + provider versions (summary)
11) 6xx Analysis - Cost - Infracost estimate (soft-fail, artifact)
12) 7xx Plan - init with backend, plan with change detection, uploads plan artifact, outputs add/change/destroy counts
13) 8xx Apply - manual (`workflow_dispatch` with `action=apply`), restores state backup, downloads plan artifact, applies, emits inventory + changelog artifacts
14) 9xx Destroy - manual (`action=destroy` + `DESTROY` confirm), backs up state then destroys
15) 9xx Metrics - after successful apply; records duration, counts, actor, run id

### Triggers
- Push to `main` with Terraform-path filter: runs all checks through plan; apply is never automatic.
- Pull request to `main`: same checks plus plan; no PR comment is posted by default.
- Manual (`workflow_dispatch`): choose `action` (`plan|apply|destroy`), `environment` (`lab|dev|prod`), and `destroy_confirm` for destroys. Apply runs only if plan reported `has_changes=true`.

### Safety rails built in
- Detailed exit codes prevent no-op plans from running apply.
- Destroy requires a confirmation string.
- State backups run before apply and destroy.
- Soft-fail scanners provide feedback without blocking learning workflows.

### Composite actions (selected)
- `plan/` - setup Terraform, Azure login, init backend, `terraform plan -detailed-exitcode`, parse counts, upload artifact.
- `apply/` - download plan artifact, init backend, `terraform apply tfplan`, step summary.
- `destroy/` - confirmation gate, init backend, `terraform destroy -var-file=...`.
- `state-backup/` - blob copy of state to `tfstate-backups`.
- `secret-scan/` - Gitleaks wrapper with step summary.
- `policy-check/` - Conftest against `tfplan.json`.
- `terraform-docs/` - docs generation for root and modules.
- `graph/` - produces graph SVG (backend temporarily disabled to avoid remote state mutations).
- `module-version/`, `cost-estimate/`, `resource-inventory/`, `changelog/`, `metrics/`, `terratest/`.

---

## Part 5 - Operating the lab

### Day 0: first deployment
1. `terraform init` (local backend by default) or `terraform init -backend-config ...` to match remote.
2. `terraform plan -out=tfplan` using the desired `*.tfvars`.
3. `terraform apply tfplan` when ready.
4. Use `terraform output` to gather IPs/FQDNs for testing; run the lab testing guide.

### Day 1: steady operations
- Rotate admin passwords in `terraform.tfvars` and in Azure when needed.
- Track cost and disable expensive switches when not in use.
- Keep Log Analytics enabled so diagnostics validate the lab.

### Day 2: change management
- Make changes in `terraform.tfvars`, re-plan, and apply.
- Avoid manual portal edits; they surface as drift.
- Use the graph and inventory artifacts to document changes.

### Pipeline workflow
1. Push/PR runs checks and produces plan artifacts, docs, graph, cost estimate, and summaries.
2. Manual Apply if `has_changes=true` and you are ready to deploy.
3. Manual Destroy with confirmation when you want to tear down an environment.

### Cost controls
- Disable `deploy_firewall` and `deploy_vpn_gateway` to cut most hourly cost.
- Reduce web tier size/count (`lb_web_server_size`, `lb_web_server_count`).
- Turn off PaaS/data flags when not needed; set `enable_auto_shutdown=true` to stop VMs at night.
- Use `paas_alternative_location` and `cosmos_location` for quota-friendly regions.

### Troubleshooting
- Format/validate failures: run `terraform fmt -recursive` and `terraform validate`.
- Plan/apply auth errors: confirm Azure credentials and role (Owner recommended for policy/role assignments).
- State lock stuck: `terraform force-unlock -force <LOCK_ID>`.
- Cost job missing: set `INFRACOST_API_KEY` secret.
- Docs/graph issues: ensure backend file exists; graph action temporarily moves `backend.tf` to run locally.
- Secret scan: if Gitleaks fails, rotate secrets and clean history as needed.

### Testing
- Use `wiki/testing/lab-testing-guide.md` for post-deploy validation (web LB, RDP paths, VPN, logs).
- Terratest composite action is available but not wired into the main workflow; can be added as a job if desired.

---

## Part 6 - Deep dive: Terraform structure, patterns, and gotchas

### How files cooperate
- Root module (`main.tf`): orchestrates all module calls. Think of it as the chapter index; each landing zone is a section, and each module is a paragraph inside that section.
- `variables.tf`: the contract. Every tunable knob is declared here with types, descriptions, and defaults where sensible.
- `locals.tf`: the opinionated translator. It shapes names, tags, CIDRs, SKU choices, and feature flags into module-friendly structures. Many downstream decisions (like whether to attach diagnostics or private endpoints) flow from locals maps and booleans.
- `terraform.tfvars` + `environments/*.tfvars`: the stories you want to tell. Lab/dev/prod swap in different regions, SKUs, and feature toggles without touching code.
- `outputs.tf`: the back-of-book index. It surfaces the important connection points and IDs after a run.

### Conditional assembly
- Hub-first rule: The hub VNet, firewall subnet, gateway subnet, and management subnet stand up before any spoke peering. This ensures routes and gateway transit are ready for spokes.
- Feature gates: Modules wrap optional resources in `count` or `for_each`. For example, private endpoints only render when both `deploy_private_endpoints` and the corresponding service flag are true.
- Diagnostics by default: When `deploy_log_analytics=true`, most modules emit `azurerm_monitor_diagnostic_setting` blocks to push platform logs/metrics into the workspace, avoiding drift between services.
- Private DNS coupling: Private DNS zones only deploy when both `deploy_private_dns_zones=true` and at least one private endpoint-enabled service is on; the zones link to hub VNets so spokes inherit resolution via peering.

### Networking decisions
- Addressing: Hub uses /16; spokes use /16 with /24 slices per tier. Adjust cautiously; routing, peering, and firewall DNAT/SNAT rules assume these defaults.
- Security planes: NSGs per subnet, optional ASGs for workload tiers, and Azure Firewall for central egress/DNAT. Turning off firewall but leaving public jumpbox enabled is allowed for cost-saving lab scenarios.
- Outbound control: NAT Gateway available for deterministic egress when firewall is off. When firewall is on, SNAT comes from the firewall public IP.
- Hybrid: VPN Gateway + simulated on-premises VNet give you a full S2S path. Use `vpn_shared_key` and match IP ranges to avoid overlaps.

### Compute and identity
- Domain controllers: Windows Server VMs with AD DS. Secondary DC optional for cost. DNS services anchor identity and name resolution across spokes.
- Jumpbox: RDP entry point. Can use public IP (cheaper, simpler) or force DNAT through firewall for a more realistic posture.
- IIS workload: Two web servers behind a load balancer by default. AKS is optional and off by default to keep runtime short and costs low.

### Data and PaaS
- SQL: Single DB with optional private endpoint and private DNS. Admin creds come from variables; rotate in secrets manager for production-like use.
- Storage: Used for files, diagnostics, and (optionally) VNet Flow Logs. Private endpoints and service endpoints can be toggled.
- PaaS expansion: Functions, Logic Apps, Event Grid, Service Bus, App Service, Static Web Apps, Cosmos DB are opt-in. Use `paas_alternative_location` to route to quota-friendly regions if your primary region is saturated.

### Observability
- Log Analytics: Central sink; diagnostic settings from firewall, VPN, Application Gateway, AKS (if enabled), and VMs point here. Default retention is 30 days (adjust in `terraform.tfvars`).
- Traffic Analytics: Enabled when both `enable_vnet_flow_logs` and `enable_traffic_analytics` are true; uses AzAPI for VNet Flow Logs (NSG flow logs are deprecated).
- Alerts: Minimal baseline; consider extending with action groups and metrics (CPU, disk) for jumpbox/DC/workload VMs if you want production-like behaviors.

### Naming and tagging rules of thumb
- Names use region short codes from locals (for example, `wus2`), environment codes, and resource roles. Keep them short to satisfy Azure length constraints.
- Tags: at least `project`, `environment`, `owner`. Add `cost_center`, `criticality`, `data_classification` if you mirror enterprise standards.

### Common pitfalls
- Role/Policy operations require Owner: The landing zone creates policy assignments and role assignments; Contributor alone is not enough.
- State drift from manual edits: Avoid ad-hoc portal changes; they will surface as drift in plan/apply.
- Address overlap: Changing CIDRs after first deploy will force replacement of VNets and peered resources. Plan carefully before changing address spaces.
- Long-running resources: VPN Gateway and AKS increase deploy time. Keep them off when you need fast loops.
- Passwords in tfvars: Replace with secret store integrations for anything beyond a lab; rotate regularly.

---

## Part 7 - Deep dive: CI/CD pipeline behaviors and extensions

### Change detection and gating
- Plan uses `-detailed-exitcode` to detect "no changes"; apply only runs when `has_changes=true` and `action=apply`.
- Destroy is isolated behind `action=destroy` and a `DESTROY` confirmation string to prevent accidental teardown.
- Concurrency key `terraform-${ref}-${environment}` ensures only one run per branch/environment; newer runs wait rather than cancel.

### Security and quality stages
- tfsec + Checkov: Both upload SARIF so findings appear in the Security tab. Soft-fail keeps feedback flowing without blocking iterations.
- Gitleaks: Fails on suspected secrets. Run locally with `.gitleaks.toml` if you hit failures.
- TFLint + Conftest: Azure ruleset catches SKU/usage issues; OPA policies can enforce tagging, naming, or allowed regions (extend `policies/` as needed).
- terraform-docs: Keeps module docs fresh; artifacts are uploaded for review instead of committing autogenerated files.

### Artifacts produced per run
- `tfplan-<env>-<sha>`: binary plan + `plan_output.txt`.
- `terraform-docs`: root/module docs.
- `terraform-graph`: SVG dependency graph.
- `checkov-results.sarif`, `tfsec-results.sarif`: security scan outputs.
- `infracost.json` + summary in step output when API key present.
- `resource-inventory-<env>`: JSON/CSV of state resources.
- `changelog-<env>`: top changes from plan.
- `metrics-<env>-<run>`: deployment metadata (duration, counts, actor).

### Customizing the workflow
- Add Terratest: Wire `.github/actions/terratest` after plan (or after apply for live tests) with its own job needs.
- PR comments: Add a step to post plan summaries back to PRs if desired (currently not posted).
- Tighten policy: Set `soft_fail: false` on policy-check or security jobs to enforce gates.
- Auto-apply: Not enabled by design; you could add an approval job to gate apply instead of manual dispatch.
- Cache optimization: Terraform cache is intentionally not persisted to avoid stale providers; add caching if you want faster init at the cost of complexity.

### Runner considerations
- All jobs run on `ubuntu-latest`. If you add self-hosted runners, ensure Azure CLI, Terraform, jq, graphviz, conftest, and gitleaks are available.
- Graph job temporarily moves `backend.tf` to avoid touching remote state; safe for read-only graph generation.

---

## Part 8 - Operating guides by persona

### For learners
- Start with the Minimal profile: disable firewall, VPN, AKS, and PaaS; keep jumpbox public IP on for easy RDP.
- Focus on network fundamentals: inspect peering, NSGs, and routing tables; use the graph artifact to see dependencies.
- Experiment with toggles: turn on firewall and private endpoints to see how traffic paths change.

### For platform engineers
- Treat `locals.tf` as the policy engine; extend tags, naming, and SKU choices here.
- Add Conftest policies to enforce allowed regions, required tags, and prohibiting public IPs in production.
- Consider layering in key rotation and secret injection via Key Vault + Managed Identity for VMs and App Services.

### For cost-conscious users
- Keep `deploy_firewall=false`, `deploy_vpn_gateway=false` when not demonstrating hybrid/security.
- Use B-series VM sizes and reduce counts (`lb_web_server_count=1`) for small demos.
- Enable `enable_auto_shutdown` to stop VMs daily; tear down with destroy when idle.

### For reliability testers
- Turn on secondary DC, multiple workloads, and private endpoints; validate failover paths.
- Add synthetic probes and alerts in Log Analytics; extend metrics job to export to your observability stack.
- Use Terratest to assert key resources (VNets, subnets, firewall rules) exist and outputs are non-empty.

### For instructors
- Use the book guide as the lecture spine, then assign a landing zone page as homework.
- Have students toggle one flag per session and record the plan diff.
- Use the lab workbook to track progress and evidence.

---

## Part 9 - FAQ

- Can I swap regions? Yes. Update `location` in `terraform.tfvars` and check `locals.tf` for the short code mapping. Ensure SKUs are available in your region.
- Can I bring my own DNS? You can point VNets to custom DNS, but the identity landing zone assumes its DC handles DNS. Adjust module inputs accordingly.
- How do I add a new landing zone? Create a new composition under `landing-zones/` and a module under `modules/` if needed, then wire it into `main.tf` with appropriate flags.
- How do I enforce tag compliance? Add OPA policies in `policies/` and switch `soft_fail` to false in the policy-check job.
- Can I run apply automatically on merge? The current design requires manual dispatch. You can add an environment protection rule or manual approval job if you want controlled auto-apply.
- What about state encryption and backups? Azure Storage encrypts at rest; the pipeline creates on-demand backups via `state-backup` before apply/destroy. Enable blob versioning in the storage account for longer retention if desired.
- Is there drift detection? Plans on push/PR surface drift; you can add a scheduled workflow (cron) to run plan nightly for drift checks.
- Why do some resources take a long time? VPN Gateway and AKS are slow; keep them off for fast iterations.

---

## Part 10 - Certification alignment (AZ-104, AZ-305, AZ-400)

The certification guides translate this repo into exam-focused practice. They map the lab's landing zones, modules, and pipeline to the skills measured so you can practice on a single platform.

### AZ-104 focus map
- Operate the platform: identity, networking, compute, storage, monitoring.
- Use the current lab profile with a few deltas (backup, VPN, flow logs).

### AZ-305 focus map
- Design tradeoffs: security vs. cost, private vs. public access, PaaS vs. IaaS.
- Document architecture decisions and governance posture.

### AZ-400 focus map
- Use the GitHub Actions pipeline to practice CI/CD, security, and compliance.
- Treat policy and security checks as code and wire them into the workflow.

### Where to start
- Certification overview: `certifications/README.md`
- Skill matrix: `certifications/skill-matrix.md`
- AZ-104 path: `certifications/az-104.md`
- AZ-305 path: `certifications/az-305.md`
- AZ-400 path: `certifications/az-400.md`

---

## Part 11 - Certification lab workbook

The workbook is a long-form checklist that ties build, operate, and design tasks together. Use it to track progress and collect evidence for each exam.

Highlights:
- Baseline deployment and networking validation.
- Governance and security hardening.
- Compute and PaaS operations.
- DevOps pipeline runs and security scans.
- Architecture review and cost optimization.

Start here: `certifications/lab-workbook.md`.

---

## Appendix - Quick links
- Foundations: `wiki/architecture/foundations.md`
- Architecture overview: `wiki/architecture/overview.md`
- Network topology: `wiki/architecture/network-topology.md`
- Configuration flow: `wiki/architecture/configuration-flow.md`
- Variables: `wiki/reference/variables.md`
- Outputs: `wiki/reference/outputs.md`
- Pipeline reference: `wiki/reference/pipeline.md`
- Pipeline templates: `wiki/reference/pipeline-templates.md`
- State and secrets: `wiki/reference/state-and-secrets.md`
- Hardening: `wiki/reference/hardening.md`
- Naming conventions: `wiki/reference/naming-conventions.md`
- Certification overview: `wiki/certifications/README.md`
- AZ-104 study path: `wiki/certifications/az-104.md`
- AZ-305 study path: `wiki/certifications/az-305.md`
- AZ-400 study path: `wiki/certifications/az-400.md`
- Skill matrix: `wiki/certifications/skill-matrix.md`
- Lab workbook: `wiki/certifications/lab-workbook.md`
