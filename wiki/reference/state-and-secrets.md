# Remote State & Secrets Management

<p align="center">
  <img src="../images/reference-state-and-secrets.svg" alt="Remote State & Secrets Management banner" width="1000" />
</p>


This document covers Terraform remote state storage and GitHub secrets configuration for the Azure Landing Zone lab pipeline.

Local live validation intentionally runs with `terraform init -backend=false` and temporary tfvars so it does not touch the shared remote state. Use [Live provisioning validation](../testing/live-provisioning-validation.md) when you need to prove a disposable deployment before committing or pushing changes.

---

## Overview

The pipeline requires two main components for secure operation:

```
┌─────────────────────────────────────────────────────────────────────┐
│                     AZURE (Infrastructure)                          │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │  Resource Group: rg-terraform-state                          │   │
│  │                                                              │   │
│  │  ┌─────────────────────────────────────────────────────┐    │   │
│  │  │  Storage Account: stterraformstateXXXX              │    │   │
│  │  │                                                      │    │   │
│  │  │  Container: tfstate                                  │    │   │
│  │  │  ├── lab.terraform.tfstate                          │    │   │
│  │  │  ├── dev.terraform.tfstate                          │    │   │
│  │  │  └── prod.terraform.tfstate                         │    │   │
│  │  └─────────────────────────────────────────────────────┘    │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │  OIDC app registration: terraform-alz-pipeline               │   │
│  │  Federated credentials for GitHub Actions                    │   │
│  └─────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────┐
│                     GITHUB (Secrets)                                │
│                                                                     │
│  Repository Secrets:                                                │
│  ├── AZURE_CLIENT_ID                                                │
│  ├── AZURE_SUBSCRIPTION_ID                                          │
│  ├── AZURE_TENANT_ID                                                │
│  ├── TF_STATE_RG                                                    │
│  └── TF_STATE_SA                                                    │
└─────────────────────────────────────────────────────────────────────┘
```

---

## Part 1: Remote State Storage

### Why Remote State?

| Benefit | Description |
|---------|-------------|
| **Team Collaboration** | Multiple users can work on the same infrastructure |
| **State Locking** | Prevents concurrent modifications (blob leases) |
| **Encryption at Rest** | State files encrypted in Azure Storage |
| **Versioning** | Blob versioning provides state history |
| **Disaster Recovery** | State survives local machine failures |

### Create State Storage

#### PowerShell

```powershell
# Variables
$RESOURCE_GROUP = "rg-terraform-state"
$LOCATION = "westus2"
$RANDOM_SUFFIX = Get-Random -Maximum 9999
$STORAGE_ACCOUNT = "stterraformstate$RANDOM_SUFFIX"

# Create resource group
az group create --name $RESOURCE_GROUP --location $LOCATION

# Create storage account with security best practices
az storage account create `
  --name $STORAGE_ACCOUNT `
  --resource-group $RESOURCE_GROUP `
  --location $LOCATION `
  --sku Standard_LRS `
  --kind StorageV2 `
  --encryption-services blob `
  --min-tls-version TLS1_2 `
  --allow-blob-public-access false `
  --https-only true

# Create container for state files
az storage container create `
  --name tfstate `
  --account-name $STORAGE_ACCOUNT

# Output storage account name (save this!)
Write-Host "Storage Account: $STORAGE_ACCOUNT"
```

#### Bash

```bash
RESOURCE_GROUP="rg-terraform-state"
LOCATION="westus2"
RANDOM_SUFFIX=$RANDOM
STORAGE_ACCOUNT="stterraformstate$RANDOM_SUFFIX"

az group create --name $RESOURCE_GROUP --location $LOCATION

az storage account create \
  --name $STORAGE_ACCOUNT \
  --resource-group $RESOURCE_GROUP \
  --sku Standard_LRS \
  --encryption-services blob \
  --min-tls-version TLS1_2 \
  --allow-blob-public-access false \
  --https-only true

az storage container create \
  --name tfstate \
  --account-name $STORAGE_ACCOUNT

echo "Storage Account: $STORAGE_ACCOUNT"
```

### Backend Configuration

The backend is configured in [backend.tf](../../backend.tf):

```hcl
terraform {
  backend "azurerm" {
    container_name = "tfstate"
    # Dynamic values set via -backend-config in pipeline:
    # resource_group_name  = "rg-terraform-state"
    # storage_account_name = "stterraformstateXXXX"
    # key                  = "lab.terraform.tfstate"
  }
}
```

### Pipeline Backend Initialization

The pipeline initializes the backend dynamically:

```bash
terraform init \
  -backend-config="resource_group_name=$TF_STATE_RG" \
  -backend-config="storage_account_name=$TF_STATE_SA" \
  -backend-config="container_name=tfstate" \
  -backend-config="key=<environment>.terraform.tfstate"
```

### Environment Isolation

Each environment has its own state file:

| Environment | State Key | Purpose |
|-------------|-----------|---------|
| Lab | `lab.terraform.tfstate` | Learning and experimentation |
| Dev | `dev.terraform.tfstate` | Development testing |
| Prod | `prod.terraform.tfstate` | Production workloads |

Benefits:
- Changes to lab don't affect prod state
- Deploy to multiple environments simultaneously
- Destroy lab without affecting dev
- No state locking contention between environments

### State Locking

Terraform uses Azure blob leases for state locking:

```
User A: terraform apply (acquires lock)
User B: terraform apply → ERROR: state blob is already locked
User A: apply completes (releases lock)
User B: can now run apply
```

**Force Unlock (if stuck):**

```bash
# Get lock ID from error message
terraform force-unlock -force <LOCK_ID>
```

### Local Development

For local development without the pipeline:

```bash
# Initialize with Azure backend
terraform init \
  -backend-config="resource_group_name=rg-terraform-state" \
  -backend-config="storage_account_name=stterraformstateXXXX" \
  -backend-config="key=lab.terraform.tfstate"

# Or reconfigure an existing workspace
terraform init -reconfigure \
  -backend-config="resource_group_name=rg-terraform-state" \
  -backend-config="storage_account_name=stterraformstateXXXX" \
  -backend-config="key=lab.terraform.tfstate"
```

---

## Part 2: GitHub OIDC Identity

### Why OIDC?

The pipeline needs a non-interactive Azure identity. GitHub OIDC provides that identity without storing a long-lived client secret in GitHub.

- **Short-lived credentials** - Tokens are minted per workflow run.
- **Scoped trust** - Federated credentials can target a repo, branch, tag, or pull request event.
- **Auditable** - Azure activity is attributed to the app registration/service principal.
- **No secret rotation burden** - There is no Azure client secret to rotate.

### Create the OIDC App Registration

```bash
SUBSCRIPTION_ID=$(az account show --query id -o tsv)
TENANT_ID=$(az account show --query tenantId -o tsv)
REPO="OWNER/REPO"

APP_ID=$(az ad app create \
  --display-name "terraform-alz-pipeline" \
  --query appId \
  --output tsv)

az ad sp create --id "$APP_ID"

az ad app federated-credential create \
  --id "$APP_ID" \
  --parameters "{
    \"name\": \"github-main\",
    \"issuer\": \"https://token.actions.githubusercontent.com\",
    \"subject\": \"repo:${REPO}:ref:refs/heads/main\",
    \"audiences\": [\"api://AzureADTokenExchange\"]
  }"

az ad app federated-credential create \
  --id "$APP_ID" \
  --parameters "{
    \"name\": \"github-pr\",
    \"issuer\": \"https://token.actions.githubusercontent.com\",
    \"subject\": \"repo:${REPO}:pull_request\",
    \"audiences\": [\"api://AzureADTokenExchange\"]
  }"
```

### Required Azure Roles

Assign only the roles required by the profile you deploy:

| Role | Purpose |
|---|---|
| Contributor or equivalent custom role | Create and update Azure resources |
| User Access Administrator | Create role assignments |
| Resource Policy Contributor | Create policy assignments |
| Storage Blob Data Contributor | Read/write Terraform state blobs |

### Manage the OIDC Principal

```bash
az ad sp list --display-name "terraform" --query "[].{Name:displayName, AppId:appId}" -o table
az ad sp show --id <APP_ID>
az role assignment list --assignee <APP_ID> -o table
```

---

## Part 3: GitHub Secrets

### Required Secrets

Configure these in **GitHub → Settings → Secrets and variables → Actions**:

| Secret | Description | Example |
|--------|-------------|---------|
| `AZURE_CLIENT_ID` | App/client ID for GitHub OIDC | `801a5cf9-3e14-4283-a07a-087e0f0351d4` |
| `AZURE_SUBSCRIPTION_ID` | Target Azure subscription | `xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx` |
| `AZURE_TENANT_ID` | Azure AD tenant ID | `xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx` |
| `TF_STATE_RG` | State storage resource group | `rg-terraform-state` |
| `TF_STATE_SA` | State storage account name | `stterraformstate1009` |

### Set Secrets via GitHub CLI

```bash
# Authenticate with GitHub
gh auth login

# Set individual secrets
gh secret set AZURE_CLIENT_ID --body "<CLIENT_ID>"
gh secret set AZURE_SUBSCRIPTION_ID --body "<SUBSCRIPTION_ID>"
gh secret set AZURE_TENANT_ID --body "<TENANT_ID>"
gh secret set TF_STATE_RG --body "rg-terraform-state"
gh secret set TF_STATE_SA --body "<STORAGE_ACCOUNT_NAME>"

# Verify secrets are set
gh secret list
```

### Set Secrets via GitHub UI

1. Go to your repository on GitHub
2. Click **Settings** → **Secrets and variables** → **Actions**
3. Click **New repository secret**
4. Enter the secret name and value
5. Click **Add secret**
6. Repeat for all required secrets

### How Secrets Are Used

The pipeline uses secrets in the composite actions:

```yaml
# In .github/workflows/terraform.yml
- uses: ./.github/actions/plan
  with:
    azure_client_id: ${{ secrets.AZURE_CLIENT_ID }}
    azure_tenant_id: ${{ secrets.AZURE_TENANT_ID }}
    azure_subscription_id: ${{ secrets.AZURE_SUBSCRIPTION_ID }}
    backend_resource_group: ${{ secrets.TF_STATE_RG }}
    backend_storage_account: ${{ secrets.TF_STATE_SA }}

# In .github/actions/plan/action.yml
- name: Azure Login
  uses: azure/login@v2
  with:
    client-id: ${{ inputs.azure_client_id }}
    tenant-id: ${{ inputs.azure_tenant_id }}
    subscription-id: ${{ inputs.azure_subscription_id }}

- name: Set ARM Environment Variables
  run: |
    echo "ARM_USE_OIDC=true" >> $GITHUB_ENV
    echo "ARM_CLIENT_ID=${{ inputs.azure_client_id }}" >> $GITHUB_ENV
    echo "ARM_SUBSCRIPTION_ID=${{ inputs.azure_subscription_id }}" >> $GITHUB_ENV
    echo "ARM_TENANT_ID=${{ inputs.azure_tenant_id }}" >> $GITHUB_ENV
```

---

## Part 4: Security Best Practices

### State Storage Security

| Practice | Implementation |
|----------|----------------|
| **Encryption at rest** | Azure Storage encrypts all blobs by default |
| **TLS 1.2 minimum** | `--min-tls-version TLS1_2` |
| **No public access** | `--allow-blob-public-access false` |
| **HTTPS only** | `--https-only true` |
| **Authentication** | GitHub OIDC principal with Azure RBAC |

### Credential Hygiene

The pipeline does not store an Azure client secret. Keep these practices in place:

- Review federated credentials whenever branch or environment protection changes.
- Rotate storage account keys if anyone uses key-based access outside the pipeline.
- Prefer RBAC data-plane permissions for state storage.
- Remove stale app registrations and role assignments that are no longer used.

### Least Privilege (Production)

For production, consider using more restrictive roles:

```bash
# Instead of Owner, use specific roles:
az role assignment create --assignee <SP_ID> --role "Contributor" --scope /subscriptions/<SUB_ID>
az role assignment create --assignee <SP_ID> --role "User Access Administrator" --scope /subscriptions/<SUB_ID>
az role assignment create --assignee <SP_ID> --role "Resource Policy Contributor" --scope /subscriptions/<SUB_ID>
```

### Audit Logging

Monitor Service Principal activity:

```bash
# View recent sign-ins
az monitor activity-log list \
  --caller <SP_ID> \
  --start-time $(date -d '-7 days' -Iseconds) \
  --query "[].{Time:eventTimestamp, Operation:operationName.localizedValue, Status:status.value}" \
  -o table
```

---

## Troubleshooting

### "state blob is already locked"

The state file is locked by another operation (or a previous run crashed).

```bash
# Get lock ID from error message, then:
terraform force-unlock -force <LOCK_ID>
```

### "AuthorizationFailed"

The OIDC principal lacks required permissions.

```bash
# Verify role assignments
az role assignment list --assignee <APP_ID> -o table

# Add missing least-privilege roles as needed
az role assignment create \
  --assignee <APP_ID> \
  --role "Contributor" \
  --scope /subscriptions/<SUB_ID>

# Wait 5-10 minutes for propagation, then retry
```

### "Secret not found" in pipeline

GitHub secret is not configured or has wrong name.

```bash
# List configured secrets
gh secret list

# Check for typos in secret names
# AZURE_CLIENT_ID, AZURE_TENANT_ID, AZURE_SUBSCRIPTION_ID
```

### "Storage account not found"

State storage account doesn't exist or wrong name in secrets.

```bash
# Verify storage account exists
az storage account show --name <STORAGE_ACCOUNT_NAME> --query name

# Update secret if wrong
gh secret set TF_STATE_SA --body "<CORRECT_NAME>"
```

---

## See Also

- [Pipeline Overview](pipeline.md) - Main pipeline documentation
- [Pipeline Templates](pipeline-templates.md) - 2-level template architecture
- [Live Provisioning Validation](../testing/live-provisioning-validation.md) - Disposable local apply, smoke test, and destroy workflow
- [GitHub Actions - Encrypted Secrets](https://docs.github.com/en/actions/security-guides/encrypted-secrets)
- [Terraform Backend - AzureRM](https://developer.hashicorp.com/terraform/language/settings/backends/azurerm)

## Related pages

- [Security landing zone (Pillar 4: Security / Shared Services)](../landing-zones/shared-services.md)
- [Hardening and hygiene checklist (current lab profile)](hardening.md)
