# Security policy

## Reporting a vulnerability

Use the repository's private GitHub security-advisory reporting flow. Do not
open a public issue containing credentials, tenant information, exploit steps,
state, or plan output. Include the affected path, impact, reproduction steps,
and a proposed mitigation when possible.

## Supported scope

Security fixes target the current `main` branch. This repository is a learning
lab and does not provide a production support or compliance guarantee.

## Secret handling

- Authenticate GitHub Actions to Azure with OIDC.
- Supply Terraform secrets through ephemeral `TF_VAR_*` environment variables
  or an approved secret manager.
- Never commit `.tfvars` containing credentials, `.tfstate`, saved plans,
  Azure credential JSON, storage keys, or client secrets.
- If a value may have been exposed, rotate it before attempting to remove it
  from history.

The blocking CI scanners are Trivy, Checkov, Gitleaks, and Conftest. Accepted
lab-only risks are listed in `SECURITY_EXCEPTIONS.md` with expiry dates.
