# Certification alignment

This section extends the Azure Landing Zone Lab documentation with certification-focused study paths for AZ-104, AZ-305, and AZ-400. The goal is to map the lab's Terraform configuration, landing zones, and pipeline to the skills measured so you can practice on real infrastructure rather than isolated demos.

Microsoft updates exam skill outlines regularly. Use these guides as a lab map, and verify any exam objectives against the official skills outline before you schedule.

## How to use these guides
1. Deploy the current lab profile described in `../reference/current-config.md`.
2. Choose a certification path and apply the profile deltas in the relevant guide.
3. Work through the lab workbook and track evidence (plans, screenshots, diagrams).
4. Review architecture and reference docs for any gaps you want to close.
5. Tear down or scale down to control costs when you are done.

## Quick map

| Exam | Focus | Start here | Suggested profile |
| --- | --- | --- | --- |
| AZ-104 | Admin tasks across identity, storage, compute, networking, monitoring | `az-104.md` | AZ-104 profile in `../reference/current-config.md` |
| AZ-305 | Architecture design, governance, security, resiliency | `az-305.md` | AZ-305 profile in `../reference/current-config.md` |
| AZ-400 | DevOps and delivery (pipelines, security, IaC, monitoring) | `az-400.md` | AZ-400 profile in `../reference/current-config.md` |

## Common setup and guardrails
- Prefer `terraform plan` before `terraform apply`, especially after changing multiple flags.
- Keep `allowed_jumpbox_source_ips` scoped to your public IP for safety.
- Track cost-sensitive flags like `deploy_firewall`, `deploy_vpn_gateway`, and `deploy_aks`.
- Use `environments/lab.tfvars` or `terraform.tfvars` for consistent state.
- If you need multiple runs, use `environments/dev.tfvars` and `environments/prod.tfvars` to isolate state.

## Evidence to capture for study and interviews
- `terraform plan` summaries and pipeline artifacts.
- Screenshots of management groups, policy compliance, and resource graphs.
- Outputs such as public IPs, private endpoints, and monitoring workspace IDs.
- A short architecture note on why you enabled or disabled specific components.

## Related documentation
- Book-style guide: `../book.md`
- Architecture overview: `../architecture/overview.md`
- Landing zones: `../landing-zones/README.md`
- Configuration snapshot: `../reference/current-config.md`
- Hardening checklist: `../reference/hardening.md`
- Lab testing: `../testing/lab-testing-guide.md`
