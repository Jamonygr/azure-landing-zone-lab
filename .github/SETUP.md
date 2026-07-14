# GitHub Actions and Azure state setup

The pipeline authenticates with GitHub OIDC and Microsoft Entra ID. Do not add
an Azure client secret, storage account key, or JSON credential secret.

## 1. Create the protected state backend

Run this only in the subscription intended to own Terraform state:

```powershell
az login
az account show --output table

$ResourceGroup = "rg-terraform-state"
$Location = "westus2"
$StorageAccount = "stterraformstate$(Get-Random -Maximum 9999)"

az group create --name $ResourceGroup --location $Location
az storage account create --name $StorageAccount --resource-group $ResourceGroup --location $Location --sku Standard_LRS --kind StorageV2 --https-only true --min-tls-version TLS1_2 --allow-blob-public-access false --allow-shared-key-access false --encryption-services blob

$StateScope = az storage account show --name $StorageAccount --resource-group $ResourceGroup --query id --output tsv
$CurrentUserObjectId = az ad signed-in-user show --query id --output tsv
az role assignment create --assignee-object-id $CurrentUserObjectId --assignee-principal-type User --role "Storage Blob Data Contributor" --scope $StateScope

az storage container create --name tfstate --account-name $StorageAccount --auth-mode login
az storage account blob-service-properties update --account-name $StorageAccount --resource-group $ResourceGroup --enable-versioning true --enable-delete-retention true --delete-retention-days 30 --enable-container-delete-retention true --container-delete-retention-days 30
az lock create --name terraform-state-protection --lock-type CanNotDelete --resource-group $ResourceGroup --resource-name $StorageAccount --resource-type Microsoft.Storage/storageAccounts

Write-Host "TF_STATE_RG=$ResourceGroup"
Write-Host "TF_STATE_SA=$StorageAccount"
```

The public service endpoint remains reachable because GitHub-hosted runners
have changing outbound addresses. Blob anonymous access and shared-key
authentication are disabled; authorization is through Entra RBAC.

## 2. Create the OIDC application

```bash
SUBSCRIPTION_ID=$(az account show --query id -o tsv)
TENANT_ID=$(az account show --query tenantId -o tsv)
REPO="OWNER/REPOSITORY"

APP_ID=$(az ad app create \
  --display-name "terraform-alz-pipeline" \
  --query appId \
  --output tsv)
az ad sp create --id "$APP_ID"

ENVIRONMENTS=(
  cheap-lab lab dev prod
  cheap-lab-destroy lab-destroy dev-destroy prod-destroy
)

for ENVIRONMENT in "${ENVIRONMENTS[@]}"; do
  az ad app federated-credential create \
    --id "$APP_ID" \
    --parameters "{
      \"name\": \"github-${ENVIRONMENT}\",
      \"issuer\": \"https://token.actions.githubusercontent.com\",
      \"subject\": \"repo:${REPO}:environment:${ENVIRONMENT}\",
      \"audiences\": [\"api://AzureADTokenExchange\"]
    }"
done

STATE_SCOPE=$(az storage account show \
  --name "<TF_STATE_SA>" \
  --resource-group "<TF_STATE_RG>" \
  --query id -o tsv)

az role assignment create \
  --assignee "$APP_ID" \
  --role "Storage Blob Data Contributor" \
  --scope "$STATE_SCOPE"
```

Every authenticated workflow job declares an environment, so the federated
subject is always:

```text
repo:OWNER/REPOSITORY:environment:ENVIRONMENT_NAME
```

Grant the service principal only the deployment roles required by the selected
lab profile. Management-group, policy-assignment, and role-assignment features
need additional Azure permissions and should remain disabled unless those
permissions are intentionally granted.

## 3. Configure GitHub

Repository Actions secrets:

| Secret | Purpose |
|---|---|
| AZURE_CLIENT_ID | OIDC application/client ID |
| AZURE_TENANT_ID | Azure tenant ID |
| AZURE_SUBSCRIPTION_ID | Confirmed target subscription |
| TF_STATE_RG | State resource group |
| TF_STATE_SA | State storage account |
| INFRACOST_API_KEY | Optional cost estimate |

Create these environments:

| Environment | Protection |
|---|---|
| cheap-lab, lab, dev | Protected main deployments only |
| prod | Protected main plus one reviewer |
| cheap-lab-destroy, lab-destroy, dev-destroy, prod-destroy | Protected main plus one reviewer |

Self-review is allowed so a single maintainer is not permanently blocked.
Pull requests never receive an Azure token.

## 4. Run safely

```bash
gh workflow run "Terraform Pipeline" --ref main \
  -f action=plan -f environment=lab

gh workflow run "Terraform Pipeline" --ref main \
  -f action=apply -f environment=lab

gh workflow run "Terraform Pipeline" --ref main \
  -f action=destroy -f environment=lab \
  -f destroy_confirm="DESTROY lab"
```

Apply consumes the saved plan created in the same workflow run. State is
downloaded, uploaded to a backup container, and verified before apply or
destroy. Azure blob versioning and soft delete provide a second recovery layer.

## Recovery

1. Stop all apply/destroy runs.
2. Inspect current and deleted versions:

   ```bash
   az storage blob list \
     --account-name "<TF_STATE_SA>" \
     --container-name tfstate \
     --include v,d \
     --auth-mode login \
     --output table
   ```

3. Restore the required blob version or copy the verified backup into a new
   state key.
4. Run terraform init and terraform plan only. Confirm the plan is empty or
   understood before allowing another apply.

Never use terraform state push without an offline copy and peer review.

## Troubleshooting

| Symptom | Check |
|---|---|
| Azure login fails | Federated subject exactly matches the selected GitHub environment |
| Backend initialization fails | Entra role assignment has propagated and shared-key auth is not being requested |
| State cannot be read | Principal has Storage Blob Data Contributor at the state-account scope |
| Apply cannot assign roles/policies | Optional governance features require explicitly granted Azure roles |
| Destroy is skipped | Confirmation must be exactly DESTROY followed by the environment |
