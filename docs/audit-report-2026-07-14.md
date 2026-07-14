# Environment hardening audit — 2026-07-14

## Outcome

The repository was hardened as a cost-conscious Azure learning lab. No Azure
resource was applied, changed, or destroyed during the work.

## Resolved

- Replaced the failing legacy IaC scanner action with pinned Trivy scanning.
- Reduced workflow permissions to job-level least privilege and pinned all
  external actions to immutable commits.
- Made apply and destroy manual-only and strengthened destroy confirmation.
- Repaired schedule, BGP propagation, subnet policy, and on-prem VM-size input
  wiring; removed unused interfaces and retired NSG flow-log code.
- Added Terraform/provider contracts to standalone modules and made TFLint
  blocking with a zero-warning baseline.
- Removed unused credential-bearing outputs and broad automatic compliance
  remediation roles.
- Added validation and Terraform tests for the repaired public behavior.
- Added checksum-verified Conftest and terraform-docs installation, generated
  module references, dependency automation, scanner exception governance, and
  OIDC/backend recovery documentation.
- Activated the `main` ruleset with pull requests, conversation resolution,
  strict required checks, and force-push/deletion protection. All eight
  deployment environments are restricted to protected branches; `prod` and
  every destroy environment require a reviewer while allowing self-review for
  the single-maintainer workflow.
- Set Actions to read-only permissions by default, required immutable action
  SHAs, removed obsolete client-secret credentials, and retained only OIDC and
  state-backend identifiers.
- Reconciled code scanning against the exception register. Only the Key Vault
  network-default and SQL vulnerability-assessment findings remain open; both
  are fixed by this pull request and must close through a successful scan of
  `main`, not by dismissal.
- Updated the test module to Go 1.25 and `golang.org/x/crypto` 0.52.0, removing
  all 18 dependency alerts reported for the previous transitive version once
  this branch becomes the default-branch baseline.
- Sanitized the ignored local override file so it no longer stores credentials.

## Verification

Draft pull request
[#22](https://github.com/Jamonygr/azure-landing-zone-lab/pull/22) has a clean
merge state and passed the required Format, Validate, Terraform Tests, TFLint,
Trivy, Checkov, Gitleaks, Policy Checks, Docs, Actionlint, and Go Tests checks.
The pull-request workflow correctly skipped authenticated plan, apply, and
destroy jobs.

The local acceptance suite also passed:

- Terraform 1.15.8 formatting, validation, and 11 focused Terraform tests.
- TFLint with zero findings and Checkov with 152 passed checks and no failures.
- Trivy with no undocumented configured-severity findings and Gitleaks with no
  secrets found.
- Go tests, actionlint, PowerShell AST parsing, Conftest fixtures, Markdown
  lint/link checks, documentation regeneration, and pre-commit across all
  tracked files.

A manual authenticated plan-only run is intentionally deferred until this
workflow is merged to protected `main`: the environments reject deployments
from the pull-request branch, and the current `main` workflow does not yet
contain these changes. Before that run, confirm the intended Azure subscription
and create or recover the hardened backend. No apply or destroy is authorized
by this audit.

## Accepted lab exceptions

The current exceptions and expiry dates are maintained in
[`SECURITY_EXCEPTIONS.md`](../SECURITY_EXCEPTIONS.md). They cover two
module-boundary NIC false positives and documented low-cost controls such as
short flow-log retention, optional encryption-at-host outside the
production-like profile, and disposable-vault purge behavior.

## Environment inventory

The selected Azure subscription contained no identified lab resource group and
no `rg-terraform-state` backend during the audit. This does not prove that a
different subscription or tenant has no deployment. Confirm the target account
and backend before every authenticated plan.

## Deferred provider update

AzureRM remains locked at 4.57.0 for this hardening change. Upgrade it in an
isolated dependency pull request, regenerate `.terraform.lock.hcl`, run the full
test matrix, and inspect plans for every maintained profile against the intended
remote state before merge. Do not combine the provider upgrade with functional
Terraform changes.
