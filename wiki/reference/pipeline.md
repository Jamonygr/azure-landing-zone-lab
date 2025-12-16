# CI/CD Pipeline Reference

This document describes the GitHub Actions pipeline used to deploy and manage the Azure Landing Zone Lab infrastructure.

## Overview

The pipeline is defined in [`.github/workflows/terraform.yml`](../../.github/workflows/terraform.yml) and provides a complete CI/CD workflow for Terraform:

```
┌─────────────┐    ┌───────────┐    ┌──────────────────┐    ┌─────────┐    ┌─────────┐    ┌─────────┐
│   Format    │───▶│  Validate │───▶│  Security Scans  │───▶│ TFLint  │───▶│  Plan   │───▶│  Apply  │
│   Check     │    │           │    │  (tfsec+Checkov) │    │         │    │         │    │         │
└─────────────┘    └───────────┘    └──────────────────┘    └─────────┘    └─────────┘    └─────────┘
```

## Pipeline Stages

| Stage | Purpose | Blocks Deploy? |
|-------|---------|----------------|
| 1️⃣ **Format Check** | Ensures `terraform fmt` compliance | ✅ Yes |
| 2️⃣ **Validate** | Runs `terraform validate` | ✅ Yes |
| 3️⃣ **Security - tfsec** | Static security analysis | ⚠️ Soft fail |
| 3️⃣ **Security - Checkov** | Policy-as-code security scanning | ⚠️ Soft fail |
| 4️⃣ **TFLint** | Azure-specific linting rules | ⚠️ Soft fail |
| 5️⃣ **Terraform Plan** | Shows infrastructure changes | ✅ Yes |
| 6️⃣ **Terraform Apply** | Deploys changes to Azure | - |
| 7️⃣ **Terraform Destroy** | Tears down environment (manual only) | - |

## Triggers

### Automatic Triggers

| Event | What Happens |
|-------|--------------|
| **Push to `main`** | Full pipeline → Plan → **Auto-Apply** (if changes detected) |
| **Pull Request to `main`** | Full pipeline → Plan only (with PR comment) |

**Path Filters**: Pipeline only runs when these files change:
- `**.tf` - Terraform configuration files
- `**.tfvars` - Variable files
- `modules/**` - Module changes
- `landing-zones/**` - Landing zone changes
- `environments/**` - Environment configurations

### Manual Trigger (Workflow Dispatch)

Go to **GitHub → Actions → Terraform Pipeline → Run workflow**

| Input | Options | Description |
|-------|---------|-------------|
| **Action** | `plan`, `apply`, `destroy` | What operation to perform |
| **Environment** | `lab`, `dev`, `prod` | Which environment file to use |
| **Destroy confirm** | Type `DESTROY` | Required safety confirmation for destroy |

## Required Secrets

Configure these in **GitHub → Settings → Secrets and variables → Actions**:

| Secret | Description | Example |
|--------|-------------|---------|
| `AZURE_CLIENT_ID` | Service Principal App ID | `xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx` |
| `AZURE_CLIENT_SECRET` | Service Principal secret | `xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx` |
| `AZURE_SUBSCRIPTION_ID` | Target Azure subscription | `xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx` |
| `AZURE_TENANT_ID` | Azure AD tenant ID | `xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx` |
| `AZURE_CREDENTIALS` | JSON credentials object | See below |
| `TF_STATE_RG` | Resource group for tfstate | `rg-terraform-state` |
| `TF_STATE_SA` | Storage account for tfstate | `stterraformstateXXXX` |

### AZURE_CREDENTIALS Format

```json
{
  "clientId": "<AZURE_CLIENT_ID>",
  "clientSecret": "<AZURE_CLIENT_SECRET>",
  "subscriptionId": "<AZURE_SUBSCRIPTION_ID>",
  "tenantId": "<AZURE_TENANT_ID>"
}
```

## Service Principal Setup

### Create Service Principal

```bash
# Create SP with Owner role (required for role assignments and policies)
az ad sp create-for-rbac \
  --name "terraform-alz-pipeline" \
  --role Owner \
  --scopes /subscriptions/<SUBSCRIPTION_ID> \
  --sdk-auth
```

### Required Permissions

The Service Principal needs these permissions:

| Permission | Purpose |
|------------|---------|
| **Owner** or **Contributor** | Create/manage Azure resources |
| **User Access Administrator** | Create role assignments |
| **Resource Policy Contributor** | Create policy assignments |

> **Note**: Using `Owner` role provides all required permissions. For production, use least-privilege with specific roles.

## Backend Configuration

The pipeline uses Azure Storage for remote Terraform state:

```hcl
terraform init \
  -backend-config="resource_group_name=$TF_STATE_RG" \
  -backend-config="storage_account_name=$TF_STATE_SA" \
  -backend-config="container_name=tfstate" \
  -backend-config="key=<environment>.terraform.tfstate"
```

### Create Backend Storage

```powershell
# PowerShell
$RESOURCE_GROUP = "rg-terraform-state"
$LOCATION = "westus2"
$STORAGE_ACCOUNT = "stterraformstate$(Get-Random -Maximum 9999)"

az group create --name $RESOURCE_GROUP --location $LOCATION

az storage account create `
  --name $STORAGE_ACCOUNT `
  --resource-group $RESOURCE_GROUP `
  --sku Standard_LRS `
  --encryption-services blob `
  --min-tls-version TLS1_2

az storage container create `
  --name tfstate `
  --account-name $STORAGE_ACCOUNT
```

## Environment Files

The pipeline uses environment-specific variable files:

| Environment | File | State Key |
|-------------|------|-----------|
| Lab | `environments/lab.tfvars` | `lab.terraform.tfstate` |
| Dev | `environments/dev.tfvars` | `dev.terraform.tfstate` |
| Prod | `environments/prod.tfvars` | `prod.terraform.tfstate` |

## Pipeline Features

### Concurrency Control

```yaml
concurrency:
  group: terraform-${{ github.ref }}-${{ github.event.inputs.environment || 'lab' }}
  cancel-in-progress: false
```

Only one pipeline per branch/environment runs at a time. New runs wait for completion.

### Plan Artifacts

The plan file is saved as a GitHub artifact for 5 days:
- **Name**: `tfplan-<environment>-<commit-sha>`
- **Contents**: `tfplan`, `plan_output.txt`

### PR Comments

On pull requests, the pipeline automatically comments with the plan summary:

```markdown
## 📋 Terraform Plan - lab

| Action | Count |
|--------|-------|
| ➕ Add | 42 |
| 🔄 Change | 3 |
| ➖ Destroy | 0 |
```

### Step Summaries

Each stage writes to the GitHub Step Summary for easy visibility:
- ✅ Success indicators
- ❌ Failure details
- 📋 Plan/Apply counts

## Security Scanning

### tfsec

Runs [tfsec](https://github.com/aquasecurity/tfsec) for Terraform security analysis:
- Checks for misconfigurations
- Uploads SARIF to GitHub Security tab
- Soft-fail (doesn't block deployment)

### Checkov

Runs [Checkov](https://www.checkov.io/) for policy-as-code:
- 750+ built-in policies
- CIS, SOC2, HIPAA benchmarks
- Uploads SARIF to GitHub Security tab
- Soft-fail (doesn't block deployment)

### TFLint

Runs [TFLint](https://github.com/terraform-linters/tflint) with Azure ruleset:
- Azure-specific best practices
- Deprecated resource checks
- Soft-fail (doesn't block deployment)

## Usage Examples

### Deploy Lab Environment

```bash
# Via GitHub CLI
gh workflow run "Terraform Pipeline" -f action=apply -f environment=lab

# Watch the run
gh run watch
```

### Plan Only (No Changes)

```bash
gh workflow run "Terraform Pipeline" -f action=plan -f environment=lab
```

### Destroy Environment

```bash
gh workflow run "Terraform Pipeline" \
  -f action=destroy \
  -f environment=lab \
  -f destroy_confirm=DESTROY
```

### Check Run Status

```bash
# List recent runs
gh run list --workflow="terraform.yml" --limit 5

# View specific run
gh run view <RUN_ID>

# View logs
gh run view <RUN_ID> --log
```

## Troubleshooting

### State Lock Errors

If you see "state blob is already locked":

```bash
terraform force-unlock -force <LOCK_ID>
```

### Permission Errors

If you see "AuthorizationFailed" errors:
1. Verify Service Principal has Owner role
2. Wait 5-10 minutes for role propagation
3. Re-run the pipeline

### Format Check Failures

Fix locally before pushing:

```bash
terraform fmt -recursive
```

### Plan Shows No Changes

The Apply stage skips if no changes detected. This is expected behavior.

## Related Documentation

- [Variables Reference](variables.md) - Input variables
- [Outputs Reference](outputs.md) - Deployment outputs
- [Architecture Overview](../architecture/overview.md) - Infrastructure design
