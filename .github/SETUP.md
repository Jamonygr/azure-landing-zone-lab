# GitHub Actions Pipeline Setup Guide

This guide configures the Terraform pipeline with GitHub Actions OIDC. The repo no longer requires a long-lived Azure client secret JSON.

## Prerequisites

- Azure subscription
- GitHub repository admin access
- Azure CLI installed locally
- Permission to create app registrations, federated credentials, role assignments, and the Terraform state storage account

## 1. Create Azure State Storage

```powershell
az login

$RESOURCE_GROUP = "rg-terraform-state"
$LOCATION = "westus2"
$STORAGE_ACCOUNT = "stterraformstate$(Get-Random -Maximum 9999)"

az group create --name $RESOURCE_GROUP --location $LOCATION

az storage account create `
  --name $STORAGE_ACCOUNT `
  --resource-group $RESOURCE_GROUP `
  --sku Standard_LRS `
  --encryption-services blob `
  --min-tls-version TLS1_2 `
  --allow-blob-public-access false

az storage container create `
  --name tfstate `
  --account-name $STORAGE_ACCOUNT `
  --auth-mode login

Write-Host "TF_STATE_RG=$RESOURCE_GROUP"
Write-Host "TF_STATE_SA=$STORAGE_ACCOUNT"
```

## 2. Create the OIDC App Registration

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

echo "AZURE_CLIENT_ID=$APP_ID"
echo "AZURE_TENANT_ID=$TENANT_ID"
echo "AZURE_SUBSCRIPTION_ID=$SUBSCRIPTION_ID"
```

Grant the app registration the least-privilege roles your selected profile needs. A production-aligned profile usually needs resource deployment permissions plus role assignment and policy assignment permissions.

## 3. Add GitHub Secrets

Add these repository secrets under **Settings -> Secrets and variables -> Actions**:

| Secret | Purpose |
|---|---|
| `AZURE_CLIENT_ID` | App/client ID from the OIDC app registration |
| `AZURE_TENANT_ID` | Azure tenant ID |
| `AZURE_SUBSCRIPTION_ID` | Target Azure subscription |
| `TF_STATE_RG` | Terraform state resource group |
| `TF_STATE_SA` | Terraform state storage account |
| `INFRACOST_API_KEY` | Optional cost-estimation token |

Do not add a client secret or JSON credential secret. The workflow exchanges a GitHub OIDC token for Azure access at run time.

## 4. Create GitHub Environments

Create these environments in **Settings -> Environments**:

| Environment | Protection |
|---|---|
| `lab` | Optional reviewer |
| `dev` | Optional reviewer |
| `prod` | Required reviewer |
| `lab-destroy` | Required reviewer |
| `dev-destroy` | Required reviewer |
| `prod-destroy` | Required reviewer |

## 5. Test the Pipeline

```bash
gh workflow run "Terraform Pipeline" -f action=plan -f environment=lab
gh run watch
```

Apply and destroy are manual only:

```bash
gh workflow run "Terraform Pipeline" -f action=apply -f environment=lab

gh workflow run "Terraform Pipeline" \
  -f action=destroy \
  -f environment=lab \
  -f destroy_confirm=DESTROY
```

## Troubleshooting

| Symptom | Check |
|---|---|
| Azure login fails | Federated credential subject matches the repo and branch or PR event |
| Backend init fails | `TF_STATE_RG`, `TF_STATE_SA`, and `tfstate` container exist |
| Role or policy assignment fails | The OIDC principal has the required Azure RBAC permissions |
| Plan cannot read state | The OIDC principal has Storage Blob Data Contributor on the state storage account |
