# Contributing

Changes should keep the repository useful as a low-cost learning lab and must
not imply that a profile is production-ready.

## Toolchain

- Terraform 1.15.8
- TFLint 0.63.1 with the AzureRM ruleset from `.tflint.hcl`
- Trivy 0.72.0
- actionlint 1.7.12
- terraform-docs 0.24.0
- Go version declared in `tests/go.mod`

Install pre-commit, then enable the hooks:

```powershell
pre-commit install
pre-commit run --all-files
```

## Required checks

```powershell
terraform fmt -check -recursive
terraform init -backend=false -lockfile=readonly
terraform validate
terraform test
tflint --init
tflint --recursive
trivy config --severity MEDIUM,HIGH,CRITICAL --ignorefile .trivyignore.yaml .
Push-Location tests; go test ./...; Pop-Location
actionlint
```

Regenerate Terraform references after changing an input, output, provider,
resource, or module:

```powershell
./scripts/generate-terraform-docs.ps1
```

Generated `README.md` files under `modules/` and `landing-zones/`, plus
`TERRAFORM.md`, must be committed with the source change.

## Security exceptions

Do not add a global scanner skip to make CI green. Add only a path-scoped,
time-bounded exception, document its rationale and compensating control in
`SECURITY_EXCEPTIONS.md`, and set a review date.

## Dependency updates

Dependabot checks GitHub Actions, Terraform providers, and Go modules weekly.
Provider updates must be isolated from functional changes. Regenerate the lock
file, run every local check, and inspect a plan against the intended remote
state before merging. Never infer a target subscription from whichever Azure
CLI session happens to be active.

## Pull requests

- Work on a branch and open a pull request to protected `main`.
- Explain cost, security, state, and compatibility impact.
- Never include credentials, generated passwords, plan files, or state.
- Apply and destroy are out-of-band manual operations and must not be used to
  validate an ordinary pull request.
