<!-- Never include secrets, subscription IDs, tenant IDs, or state contents. -->

# Pull request

## What does this PR change?

<!-- Short summary. Link related issues with "Fixes #123". -->

## Profile impact

<!-- Which environment profiles are affected (cheap-lab / lab / dev / prod)?
     Any cost impact? New flags should default to the cheap side. -->

## Checklist

- [ ] `terraform fmt -check -recursive` passes
- [ ] `terraform init -backend=false -lockfile=readonly` + `terraform validate` pass
- [ ] `terraform test` passes
- [ ] `tflint --recursive` reports no warnings
- [ ] `trivy config --severity MEDIUM,HIGH,CRITICAL --ignorefile .trivyignore.yaml .` passes
- [ ] Docs regenerated with `scripts/generate-terraform-docs.ps1` if variables, outputs, or modules changed
- [ ] Markdown links verified with `scripts/test-markdown-links.ps1` if docs changed
- [ ] New accepted risks recorded in `SECURITY_EXCEPTIONS.md` (if any)

See [CONTRIBUTING.md](../CONTRIBUTING.md) for the full expectations.
