# Certification lab workbook

This workbook is a long-form, hands-on path through the lab. It is designed to support AZ-104, AZ-305, and AZ-400 by walking through build, operate, and design scenarios. Check off tasks as you go, and capture evidence (screenshots, notes, pipeline artifacts).

## Before you start

- Review the current configuration in `../reference/current-config.md`.
- Decide which certification path you are following and apply the profile deltas.
- Set `allowed_jumpbox_source_ips` to your public IP range.
- Plan for cost. Firewall, VPN, and AKS are the largest drivers.

## Phase 0: Baseline deployment

- [ ] Copy `terraform.tfvars.example` to `terraform.tfvars` if needed.
- [ ] Run `terraform init` and `terraform plan`.
- [ ] Apply the plan and capture outputs.
- [ ] Confirm the hub/spoke VNets exist and peering is connected.

Evidence to capture:
- Plan summary and apply output.
- Portal screenshots of hub and spoke VNets.

## Phase 1: Core networking (AZ-104, AZ-305)

- [ ] Review address spaces in `terraform.tfvars` and ensure no overlap.
- [ ] Validate hub subnets (gateway, firewall, app gateway, management).
- [ ] Toggle `deploy_firewall` off, plan, and observe routing differences.
- [ ] Toggle `deploy_firewall` on again and document egress path.

Evidence to capture:
- Diagram of hub-spoke routing.
- Notes on firewall vs. NAT Gateway tradeoffs.

## Phase 2: Identity and governance (AZ-104, AZ-305)

- [ ] Review management groups and policy assignments in the portal.
- [ ] Add a new required tag in `policy_required_tags` and plan for impact.
- [ ] Inspect custom RBAC roles and map them to landing zones.
- [ ] Enable `deploy_secondary_dc` and document DNS changes.

Evidence to capture:
- Management group hierarchy screenshot.
- Policy compliance report screenshot.

## Phase 3: Security and data (AZ-104, AZ-305)

- [ ] Confirm Key Vault, Storage, and SQL are deployed.
- [ ] Enable private endpoints and private DNS if not already enabled.
- [ ] Validate private endpoint DNS resolution from a workload VM.
- [ ] Enable `deploy_backup` and review Recovery Services Vault settings.

Evidence to capture:
- Private endpoint details and DNS zone links.
- Backup vault configuration notes.

## Phase 4: Compute and workloads (AZ-104)

- [ ] Scale `lb_web_server_count` and note the load balancer behavior.
- [ ] Resize `vm_size` or `lb_web_server_size` to practice right-sizing.
- [ ] Confirm jumpbox access and validate auto-shutdown schedule.
- [ ] Enable or disable `deploy_workload_dev` to see environment isolation.

Evidence to capture:
- Load balancer backend pool screenshot.
- Output values for jumpbox IP and workload endpoints.

## Phase 5: Monitoring and operations (AZ-104, AZ-305)

- [ ] Confirm Log Analytics workspace ingestion for firewall, VMs, and storage.
- [ ] Update `log_retention_days` and document the change.
- [ ] Enable `enable_vnet_flow_logs` and `enable_traffic_analytics`.
- [ ] Review workbooks and alerts for baseline health.

Evidence to capture:
- Log Analytics workspace overview.
- Traffic analytics screenshot.

## Phase 6: DevOps pipeline (AZ-400)

- [ ] Run the GitHub Actions workflow on a branch change.
- [ ] Review the plan artifact and job summaries.
- [ ] Trigger a manual `workflow_dispatch` plan for the lab environment.
- [ ] Add a simple Conftest policy and confirm it runs in CI.
- [ ] Review gitleaks, tfsec, and checkov outputs in the Security tab.

Evidence to capture:
- Workflow run summary.
- SARIF results and policy check output.

## Phase 7: Architecture review (AZ-305)

- [ ] Write a one-page design summary for this landing zone.
- [ ] Document tradeoffs: firewall vs. NAT, private vs. public access, VPN vs. jumpbox.
- [ ] Produce a cost estimate and list which flags you would disable for dev/test.
- [ ] Identify gaps you would address for production (identity, DR, monitoring).

Evidence to capture:
- Architecture diagram and tradeoff table.
- Cost summary with recommended changes.

## Phase 8: Hardening and teardown

- [ ] Apply the hardening checklist in `../reference/hardening.md`.
- [ ] Confirm all public access is intentional and documented.
- [ ] Run `terraform destroy` when finished.

Evidence to capture:
- Final checklist with notes on remaining risks.

## Optional extensions

- [ ] Add Terratest to the pipeline and validate critical outputs.
- [ ] Add a scheduled plan job to detect drift.
- [ ] Create a second environment using `environments/dev.tfvars`.
- [ ] Enable AKS and validate cluster diagnostics.
