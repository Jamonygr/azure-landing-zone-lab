# 🚀 GitHub Actions Pipeline Setup Guide

This guide helps you set up the CI/CD pipeline for your own Azure subscription.

## Prerequisites

- Azure subscription
- GitHub account
- Azure CLI installed locally
- Contributor access to the Azure subscription

---

## Step 1: Fork or Clone the Repository

```bash
# Fork via GitHub UI, then clone
git clone https://github.com/YOUR-USERNAME/azure-landing-zone-lab.git
cd azure-landing-zone-lab
```

---

## Step 2: Create Azure State Storage

The pipeline needs a storage account to store Terraform state remotely.

### PowerShell
```powershell
# Login to Azure
az login

# Set variables
$RESOURCE_GROUP = "rg-terraform-state"
$LOCATION = "westus2"  # Change to your preferred region
$STORAGE_ACCOUNT = "stterraformstate$(Get-Random -Maximum 9999)"

# Create resource group
az group create --name $RESOURCE_GROUP --location $LOCATION

# Create storage account
az storage account create `
  --name $STORAGE_ACCOUNT `
  --resource-group $RESOURCE_GROUP `
  --sku Standard_LRS `
  --encryption-services blob `
  --min-tls-version TLS1_2

# Create container
az storage container create `
  --name tfstate `
  --account-name $STORAGE_ACCOUNT

# Display values to save
Write-Host "`n=== SAVE THESE FOR GITHUB SECRETS ===" -ForegroundColor Green
Write-Host "TF_STATE_RG: $RESOURCE_GROUP"
Write-Host "TF_STATE_SA: $STORAGE_ACCOUNT"
```

### Bash
```bash
# Login to Azure
az login

# Set variables
RESOURCE_GROUP="rg-terraform-state"
LOCATION="westus2"
STORAGE_ACCOUNT="stterraformstate$RANDOM"

# Create resources
az group create --name $RESOURCE_GROUP --location $LOCATION
az storage account create \
  --name $STORAGE_ACCOUNT \
  --resource-group $RESOURCE_GROUP \
  --sku Standard_LRS \
  --encryption-services blob

az storage container create \
  --name tfstate \
  --account-name $STORAGE_ACCOUNT

echo "TF_STATE_RG: $RESOURCE_GROUP"
echo "TF_STATE_SA: $STORAGE_ACCOUNT"
```

---

## Step 3: Create GitHub OIDC Identity

Create a Microsoft Entra app registration, service principal, and federated credential for GitHub Actions. The workflow uses OIDC and does not need a long-lived client secret.

```bash
SUBSCRIPTION_ID=$(az account show --query id -o tsv)
TENANT_ID=$(az account show --query tenantId -o tsv)
APP_ID=$(az ad app create --display-name "sp-github-actions-terraform" --query appId -o tsv)

az ad sp create --id "$APP_ID"
az role assignment create \
  --assignee "$APP_ID" \
  --role "Contributor" \
  --scope "/subscriptions/$SUBSCRIPTION_ID"

cat > federated-credential.json <<EOF
{
  "name": "github-main",
  "issuer": "https://token.actions.githubusercontent.com",
  "subject": "repo:<OWNER>/<REPO>:ref:refs/heads/main",
  "audiences": ["api://AzureADTokenExchange"]
}
EOF

az ad app federated-credential create \
  --id "$APP_ID" \
  --parameters federated-credential.json

echo "AZURE_CLIENT_ID: $APP_ID"
echo "AZURE_SUBSCRIPTION_ID: $SUBSCRIPTION_ID"
echo "AZURE_TENANT_ID: $TENANT_ID"
```

---

## Step 4: Add GitHub Secrets

1. Go to your GitHub repository
2. Navigate to **Settings** → **Secrets and variables** → **Actions**
3. Click **New repository secret** and add each secret:

| Secret Name | Description | Example |
|-------------|-------------|---------|
| `AZURE_CLIENT_ID` | Entra app client ID for GitHub OIDC | `xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx` |
| `AZURE_SUBSCRIPTION_ID` | Your Azure subscription ID | `xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx` |
| `AZURE_TENANT_ID` | Your Entra tenant ID | `xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx` |
| `TF_STATE_RG` | Resource group for state storage | `rg-terraform-state` |
| `TF_STATE_SA` | Storage account name | `stterraformstate1234` |

---

## Step 5: Create GitHub Environments (Optional but Recommended)

1. Go to **Settings** → **Environments**
2. Create these environments:

| Environment | Protection Rules |
|-------------|------------------|
| `lab` | None (auto-deploy) |
| `dev` | Optional: Require reviewer |
| `prod` | Required: Require reviewer + wait timer |
| `lab-destroy` | Required: Require reviewer |
| `dev-destroy` | Required: Require reviewer |

---

## Step 6: Test the Pipeline

### Option A: Push to trigger validation
```bash
git add .
git commit -m "feat: configure CI/CD pipeline"
git push
```

The **Terraform Validate** workflow will run automatically.

### Option B: Manual trigger
1. Go to **Actions** tab
2. Select **Terraform Plan** or **Terraform Apply**
3. Click **Run workflow**
4. Select environment (`cheap-lab`, `lab`, `dev`, or `prod`)

---

## Workflow Overview

| Workflow | Trigger | Description |
|----------|---------|-------------|
| **Terraform Validate** | Push/PR to main | Format, validate, security scans |
| **Terraform Plan** | PR to main | Generate and comment plan on PR |
| **Terraform Apply** | Merge to main / Manual | Deploy infrastructure |
| **Terraform Destroy** | Manual only | Destroy with "DESTROY" confirmation |

---

## Customizing Environments

Edit the files in `environments/` folder:

- `lab.tfvars` - Minimal cost deployment for testing
- `dev.tfvars` - Development environment
- `prod.tfvars` - Full production deployment

---

## Troubleshooting

### "Error: No configuration files"
- Ensure you're in the repository root
- Check that `.tf` files exist

### "Error: Authorization failed"
- Verify service principal has Contributor role
- Check secrets are correctly set in GitHub

### "Error: Backend initialization failed"
- Verify storage account exists
- Check `TF_STATE_RG` and `TF_STATE_SA` secrets

### "Error: Resource provider not registered"
Run:
```bash
az provider register --namespace Microsoft.Network
az provider register --namespace Microsoft.Compute
az provider register --namespace Microsoft.Storage
```

---

## Security Best Practices

1. **Rotate secrets regularly** - Update service principal credentials every 90 days
2. **Use environment protection** - Require approval for prod deployments
3. **Review security scans** - Check tfsec and Checkov results in Actions
4. **Enable branch protection** - Require PR reviews before merge

---

## Cost Management

The `lab.tfvars` is optimized for minimal cost:
- Auto-shutdown enabled (7 PM daily)
- Firewall disabled (~$300/month savings)
- VPN Gateway disabled (~$140/month savings)
- Smaller VM sizes (B2s)

Estimated lab cost: **~$50-100/month** with auto-shutdown
