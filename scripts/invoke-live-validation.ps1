[CmdletBinding()]
param(
    [string]$Location = "West Europe",
    [string]$Environment = "livetest",
    [string]$Owner = "",
    [string]$SubscriptionId = "",
    [switch]$KeepResources,
    [switch]$SkipSmokeTests,
    [switch]$AllowExistingState
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$RunId = Get-Date -Format "yyyyMMdd-HHmmss"
$RunRoot = Join-Path ([System.IO.Path]::GetTempPath()) "alz-live-validation-$RunId"
$LogRoot = Join-Path $RunRoot "logs"
$TerraformWorkDir = Join-Path $RunRoot "terraform-work"
$TfVarsPath = Join-Path $RunRoot "live-validation.tfvars"
$TfPlanPath = Join-Path $RunRoot "alz-live-validation.tfplan"
$RepoStatePath = Join-Path $RepoRoot "terraform.tfstate"
$StatePath = Join-Path $TerraformWorkDir "terraform.tfstate"

New-Item -ItemType Directory -Force -Path $RunRoot, $LogRoot | Out-Null

function Write-Step {
    param([string]$Message)
    Write-Host ""
    Write-Host "==> $Message"
}

function ConvertTo-LocationShort {
    param([string]$Name)

    $normalized = ($Name -replace " ", "").ToLowerInvariant()
    $map = @{
        "westeurope"         = "weu"
        "northeurope"        = "neu"
        "eastus"             = "eus"
        "eastus2"            = "eus2"
        "westus"             = "wus"
        "westus2"            = "wus2"
        "centralus"          = "cus"
        "uksouth"            = "uks"
        "ukwest"             = "ukw"
        "germanywestcentral" = "gwc"
    }

    if ($map.ContainsKey($normalized)) {
        return $map[$normalized]
    }

    return $normalized.Substring(0, [Math]::Min(4, $normalized.Length))
}

function Invoke-LoggedNative {
    param(
        [string]$Name,
        [string]$FilePath,
        [string[]]$ArgumentList,
        [string]$WorkingDirectory = $RepoRoot,
        [hashtable]$EnvironmentVariables = @{}
    )

    $safeName = $Name -replace "[^A-Za-z0-9_.-]", "_"
    $logPath = Join-Path $LogRoot "$safeName.log"
    Write-Step $Name

    $previousValues = @{}
    foreach ($key in $EnvironmentVariables.Keys) {
        $previousValues[$key] = [Environment]::GetEnvironmentVariable($key, "Process")
        [Environment]::SetEnvironmentVariable($key, [string]$EnvironmentVariables[$key], "Process")
    }

    Push-Location $WorkingDirectory
    try {
        $previousErrorActionPreference = $ErrorActionPreference
        $ErrorActionPreference = "Continue"
        try {
            $capturedOutput = & $FilePath @ArgumentList 2>&1
            $exitCode = if ($null -eq $LASTEXITCODE) { 0 } else { $LASTEXITCODE }
        }
        finally {
            $ErrorActionPreference = $previousErrorActionPreference
        }

        if ($capturedOutput) {
            $capturedOutput | ForEach-Object { $_.ToString() } | Set-Content -LiteralPath $logPath -Encoding UTF8
        }
        else {
            New-Item -ItemType File -Force -Path $logPath | Out-Null
        }
        if ($exitCode -ne 0) {
            Write-Host "Last lines from $logPath"
            Get-Content -LiteralPath $logPath -Tail 80 | ForEach-Object { Write-Host $_ }
            throw "$Name failed with exit code $exitCode. See $logPath"
        }
    }
    finally {
        Pop-Location
        foreach ($key in $EnvironmentVariables.Keys) {
            [Environment]::SetEnvironmentVariable($key, $previousValues[$key], "Process")
        }
    }
}

function Get-NativeOutput {
    param(
        [string]$FilePath,
        [string[]]$ArgumentList,
        [string]$WorkingDirectory = $RepoRoot
    )

    Push-Location $WorkingDirectory
    try {
        $output = & $FilePath @ArgumentList
        $exitCode = if ($null -eq $LASTEXITCODE) { 0 } else { $LASTEXITCODE }
        if ($exitCode -ne 0) {
            throw "$FilePath $($ArgumentList -join ' ') failed with exit code $exitCode"
        }
        return ($output -join "`n")
    }
    finally {
        Pop-Location
    }
}

function Get-TerraformRawOutput {
    param([string]$Name)
    return (Get-NativeOutput -FilePath "terraform" -ArgumentList @("output", "-raw", $Name) -WorkingDirectory $TerraformWorkDir).Trim()
}

function Get-TerraformJsonOutput {
    param([string]$Name)
    $json = Get-NativeOutput -FilePath "terraform" -ArgumentList @("output", "-json", $Name) -WorkingDirectory $TerraformWorkDir
    return $json | ConvertFrom-Json
}

function Get-TerraformStateList {
    Push-Location $TerraformWorkDir
    try {
        $previousErrorActionPreference = $ErrorActionPreference
        $ErrorActionPreference = "Continue"
        try {
            $output = & terraform state list 2>&1
            $exitCode = if ($null -eq $LASTEXITCODE) { 0 } else { $LASTEXITCODE }
        }
        finally {
            $ErrorActionPreference = $previousErrorActionPreference
        }

        $text = ($output | ForEach-Object { $_.ToString() }) -join "`n"
        if ($exitCode -ne 0) {
            if ($text -match "No state file was found") {
                return ""
            }
            throw "terraform state list failed with exit code $exitCode. $text"
        }

        return $text.Trim()
    }
    finally {
        Pop-Location
    }
}

function Initialize-TerraformWorkDir {
    Write-Step "stage temporary Terraform workdir"

    New-Item -ItemType Directory -Force -Path $TerraformWorkDir | Out-Null

    Get-ChildItem -LiteralPath $RepoRoot -File -Filter "*.tf" |
        Where-Object { $_.Name -ne "backend.tf" } |
        Copy-Item -Destination $TerraformWorkDir -Force

    foreach ($fileName in @(".terraform.lock.hcl")) {
        $source = Join-Path $RepoRoot $fileName
        if (Test-Path -LiteralPath $source) {
            Copy-Item -LiteralPath $source -Destination $TerraformWorkDir -Force
        }
    }

    foreach ($dirName in @("landing-zones", "modules")) {
        Copy-Item -LiteralPath (Join-Path $RepoRoot $dirName) -Destination $TerraformWorkDir -Recurse -Force
    }
}

function Assert-AzIdExists {
    param(
        [string]$Id,
        [string]$Label
    )

    if (-not $Id) {
        throw "$Label output is empty."
    }

    $found = (Get-NativeOutput -FilePath "az" -ArgumentList @("resource", "show", "--ids", $Id, "--query", "id", "-o", "tsv")).Trim()
    if ($found -ne $Id) {
        throw "$Label was not found at $Id."
    }
}

function Assert-ResourceGroupExists {
    param([string]$Name)

    $exists = (Get-NativeOutput -FilePath "az" -ArgumentList @("group", "exists", "--name", $Name)).Trim()
    if ($exists -ne "true") {
        throw "Resource group $Name does not exist."
    }
}

function Assert-ResourceGroupDeleted {
    param([string]$Name)

    $exists = (Get-NativeOutput -FilePath "az" -ArgumentList @("group", "exists", "--name", $Name)).Trim()
    if ($exists -ne "false") {
        throw "Resource group $Name still exists after destroy."
    }
}

function Assert-RequiredTags {
    param([string]$Name)

    $group = Get-NativeOutput -FilePath "az" -ArgumentList @("group", "show", "--name", $Name, "-o", "json") | ConvertFrom-Json
    $tagNames = @($group.tags.PSObject.Properties.Name)
    foreach ($tag in @("Environment", "Project", "ManagedBy", "Owner")) {
        if ($tagNames -notcontains $tag) {
            throw "Resource group $Name is missing required tag $tag."
        }
    }
}

function Assert-ResourceTypeCount {
    param(
        [string]$ResourceGroupName,
        [string]$ResourceType,
        [int]$Minimum = 1
    )

    $countText = (Get-NativeOutput -FilePath "az" -ArgumentList @(
        "resource", "list",
        "--resource-group", $ResourceGroupName,
        "--resource-type", $ResourceType,
        "--query", "length(@)",
        "-o", "tsv"
    )).Trim()
    $count = [int]$countText
    if ($count -lt $Minimum) {
        throw "Expected at least $Minimum resource(s) of type $ResourceType in $ResourceGroupName, found $count."
    }
}

function Assert-HubPeerings {
    param([string]$HubVnetId)

    $segments = $HubVnetId -split "/"
    $resourceGroupName = $segments[[Array]::IndexOf($segments, "resourceGroups") + 1]
    $vnetName = $segments[-1]
    $countText = (Get-NativeOutput -FilePath "az" -ArgumentList @(
        "network", "vnet", "peering", "list",
        "--resource-group", $resourceGroupName,
        "--vnet-name", $vnetName,
        "--query", "length(@)",
        "-o", "tsv"
    )).Trim()
    $count = [int]$countText
    if ($count -lt 4) {
        throw "Expected hub VNet to have at least 4 peerings, found $count."
    }
}

function Assert-LoadBalancerHttp {
    param([string]$FrontendIp)

    if (-not $FrontendIp) {
        throw "Load balancer frontend IP output is empty."
    }

    $uri = "http://$FrontendIp"
    for ($attempt = 1; $attempt -le 20; $attempt++) {
        try {
            $response = Invoke-WebRequest -Uri $uri -UseBasicParsing -TimeoutSec 10
            if ([int]$response.StatusCode -ge 200 -and [int]$response.StatusCode -lt 500) {
                return
            }
        }
        catch {
            if ($attempt -eq 20) {
                throw "Load balancer HTTP smoke check failed for $uri after $attempt attempts. Last error: $($_.Exception.Message)"
            }
            Start-Sleep -Seconds 30
        }
    }
}

function Invoke-SmokeChecks {
    param(
        [string[]]$ResourceGroupNames,
        [string]$SubscriptionIdForTests
    )

    Write-Step "Azure smoke checks"

    foreach ($name in $ResourceGroupNames) {
        Assert-ResourceGroupExists -Name $name
        Assert-RequiredTags -Name $name
    }

    $hubRg = "rg-hub-$Environment-$LocationShort"
    $identityRg = "rg-identity-$Environment-$LocationShort"
    $managementRg = "rg-management-$Environment-$LocationShort"
    $sharedRg = "rg-shared-$Environment-$LocationShort"
    $prodRg = "rg-workload-prod-$Environment-$LocationShort"
    $devRg = "rg-workload-dev-$Environment-$LocationShort"

    Assert-AzIdExists -Id (Get-TerraformRawOutput "hub_vnet_id") -Label "Hub VNet"
    Assert-AzIdExists -Id (Get-TerraformRawOutput "identity_vnet_id") -Label "Identity VNet"
    Assert-AzIdExists -Id (Get-TerraformRawOutput "management_vnet_id") -Label "Management VNet"
    Assert-AzIdExists -Id (Get-TerraformRawOutput "shared_services_vnet_id") -Label "Shared services VNet"
    Assert-AzIdExists -Id (Get-TerraformRawOutput "workload_prod_vnet_id") -Label "Workload prod VNet"
    Assert-AzIdExists -Id (Get-TerraformRawOutput "workload_dev_vnet_id") -Label "Workload dev VNet"
    Assert-HubPeerings -HubVnetId (Get-TerraformRawOutput "hub_vnet_id")

    Assert-ResourceTypeCount -ResourceGroupName $hubRg -ResourceType "Microsoft.Network/azureFirewalls"
    Assert-ResourceTypeCount -ResourceGroupName $hubRg -ResourceType "Microsoft.Network/applicationGateways"
    Assert-ResourceTypeCount -ResourceGroupName $managementRg -ResourceType "Microsoft.OperationalInsights/workspaces"
    Assert-ResourceTypeCount -ResourceGroupName $managementRg -ResourceType "Microsoft.Insights/workbooks"

    Assert-ResourceTypeCount -ResourceGroupName $sharedRg -ResourceType "Microsoft.KeyVault/vaults"
    Assert-ResourceTypeCount -ResourceGroupName $sharedRg -ResourceType "Microsoft.Storage/storageAccounts"
    Assert-ResourceTypeCount -ResourceGroupName $sharedRg -ResourceType "Microsoft.Sql/servers"
    Assert-ResourceTypeCount -ResourceGroupName $sharedRg -ResourceType "Microsoft.Network/privateDnsZones" -Minimum 3
    Assert-ResourceTypeCount -ResourceGroupName $sharedRg -ResourceType "Microsoft.Network/privateEndpoints" -Minimum 3

    Assert-ResourceTypeCount -ResourceGroupName $prodRg -ResourceType "Microsoft.Network/loadBalancers"
    Assert-ResourceTypeCount -ResourceGroupName $prodRg -ResourceType "Microsoft.Compute/virtualMachines" -Minimum 2
    Assert-ResourceTypeCount -ResourceGroupName $prodRg -ResourceType "Microsoft.Web/staticSites"
    Assert-ResourceTypeCount -ResourceGroupName $prodRg -ResourceType "Microsoft.Web/sites" -Minimum 2
    Assert-ResourceTypeCount -ResourceGroupName $prodRg -ResourceType "Microsoft.Logic/workflows"
    Assert-ResourceTypeCount -ResourceGroupName $prodRg -ResourceType "Microsoft.EventGrid/topics"
    Assert-ResourceTypeCount -ResourceGroupName $prodRg -ResourceType "Microsoft.ServiceBus/namespaces"
    Assert-ResourceTypeCount -ResourceGroupName $prodRg -ResourceType "Microsoft.DocumentDB/databaseAccounts"
    Assert-ResourceTypeCount -ResourceGroupName $devRg -ResourceType "Microsoft.Network/virtualNetworks"

    Assert-LoadBalancerHttp -FrontendIp (Get-TerraformRawOutput "lb_frontend_ip")

    Invoke-LoggedNative -Name "go live terratest" -FilePath "go" -ArgumentList @("test", "./...", "-timeout", "30m") -WorkingDirectory (Join-Path $RepoRoot "tests") -EnvironmentVariables @{
        ARM_SUBSCRIPTION_ID = $SubscriptionIdForTests
        TEST_ENVIRONMENT    = $Environment
        TEST_LOCATION_SHORT = $LocationShort
    }
}

if ((Test-Path $RepoStatePath) -and -not $AllowExistingState) {
    throw "terraform.tfstate already exists in the repository root. Re-run with -AllowExistingState only if this state belongs to the disposable live validation run."
}

if ($SubscriptionId) {
    Invoke-LoggedNative -Name "az account set" -FilePath "az" -ArgumentList @("account", "set", "--subscription", $SubscriptionId)
}

$account = Get-NativeOutput -FilePath "az" -ArgumentList @("account", "show", "-o", "json") | ConvertFrom-Json
if (-not $Owner) {
    $Owner = $account.user.name
}

$LocationShort = ConvertTo-LocationShort -Name $Location
$expectedResourceGroups = @(
    "rg-hub-$Environment-$LocationShort",
    "rg-identity-$Environment-$LocationShort",
    "rg-management-$Environment-$LocationShort",
    "rg-shared-$Environment-$LocationShort",
    "rg-workload-prod-$Environment-$LocationShort",
    "rg-workload-dev-$Environment-$LocationShort"
)

$shouldDestroy = $false
$destroySucceeded = $false

$tfvars = @"
subscription_id = "$($account.id)"
project         = "azlab"
environment     = "$Environment"
location        = "$Location"
owner           = "$Owner"
repository_url  = "https://github.com/Jamonygr/azure-landing-zone-lab"

admin_username     = "azureadmin"
admin_password     = null
sql_admin_login    = "sqladmin"
sql_admin_password = null
vpn_shared_key     = null

deploy_firewall            = true
firewall_sku_tier          = "Standard"
deploy_vpn_gateway         = false
deploy_onprem_simulation   = false
deploy_application_gateway = true
deploy_nat_gateway         = false

deploy_secondary_dc       = false
enable_jumpbox_public_ip  = false
allowed_jumpbox_source_ips = []
allow_public_rdp_from_internet = false

deploy_log_analytics      = true
log_retention_days        = 30
log_daily_quota_gb        = 1
deploy_workbooks          = true
deploy_connection_monitor = false
enable_scheduled_startstop = false

deploy_keyvault            = true
deploy_storage             = true
deploy_sql                 = true
deploy_private_dns_zones   = true
deploy_private_endpoints   = true

deploy_workload_prod       = true
deploy_workload_dev        = true
deploy_load_balancer       = true
enable_lb_rdp_nat_rules    = false
lb_type                    = "public"
lb_web_server_count        = 2
lb_web_server_size         = "Standard_B1ms"

deploy_aks             = false
deploy_container_apps  = false
deploy_functions       = true
deploy_static_web_app  = true
deploy_logic_apps      = true
deploy_event_grid      = true
deploy_service_bus     = true
deploy_app_service     = true
deploy_cosmos_db       = true
paas_alternative_location = "northeurope"
cosmos_location           = "northeurope"

enable_vnet_flow_logs    = false
enable_traffic_analytics = false
create_network_watcher   = false

deploy_azure_policy              = true
policy_allowed_locations         = ["westeurope", "northeurope", "eastus2", "global"]
policy_required_tags             = {}
enable_audit_public_network_access = true
enable_require_https_storage     = true
enable_require_nsg_on_subnet     = false
deploy_management_groups         = false
deploy_cost_management           = false
deploy_regulatory_compliance     = false
deploy_rbac_custom_roles         = false
deploy_backup                    = false

enable_auto_shutdown = true
enable_vm_encryption_at_host = false
vm_size              = "Standard_B2s"
sql_vm_size          = "Standard_B2s"
"@

Set-Content -LiteralPath $TfVarsPath -Value $tfvars -Encoding UTF8

try {
    Initialize-TerraformWorkDir
    Invoke-LoggedNative -Name "terraform fmt check" -FilePath "terraform" -ArgumentList @("fmt", "-check", "-recursive")
    Invoke-LoggedNative -Name "terraform init local workdir" -FilePath "terraform" -ArgumentList @("init", "-backend=false", "-input=false") -WorkingDirectory $TerraformWorkDir
    Invoke-LoggedNative -Name "terraform validate" -FilePath "terraform" -ArgumentList @("validate") -WorkingDirectory $TerraformWorkDir

    Invoke-LoggedNative -Name "go mod download" -FilePath "go" -ArgumentList @("mod", "download") -WorkingDirectory (Join-Path $RepoRoot "tests")
    Invoke-LoggedNative -Name "go tests skip without azure" -FilePath "go" -ArgumentList @("test", "./...") -WorkingDirectory (Join-Path $RepoRoot "tests")

    if (Get-Command "checkov" -ErrorAction SilentlyContinue) {
        Invoke-LoggedNative -Name "checkov" -FilePath "checkov" -ArgumentList @("-d", ".", "--config-file", ".checkov.yml")
    }
    else {
        Write-Step "checkov skipped"
        Write-Host "checkov is not installed locally; GitHub Actions remains the blocking Checkov gate."
    }

    if (Get-Command "gitleaks" -ErrorAction SilentlyContinue) {
        Invoke-LoggedNative -Name "gitleaks" -FilePath "gitleaks" -ArgumentList @("detect", "--config", ".gitleaks.toml", "--source", ".", "--no-git", "--redact", "--verbose")
    }
    else {
        Write-Step "gitleaks skipped"
        Write-Host "gitleaks is not installed locally; GitHub Actions remains the blocking secret-scan gate."
    }

    Invoke-LoggedNative -Name "terraform plan" -FilePath "terraform" -ArgumentList @("plan", "-input=false", "-var-file=$TfVarsPath", "-out=$TfPlanPath") -WorkingDirectory $TerraformWorkDir
    $shouldDestroy = $true
    Invoke-LoggedNative -Name "terraform apply" -FilePath "terraform" -ArgumentList @("apply", "-input=false", $TfPlanPath) -WorkingDirectory $TerraformWorkDir

    $resourceGroupNames = @(Get-TerraformJsonOutput "resource_group_names")
    $outputLocationShort = Get-TerraformRawOutput "location_short"
    if ($outputLocationShort -ne $LocationShort) {
        throw "Expected location_short $LocationShort but Terraform output returned $outputLocationShort."
    }

    if (-not $SkipSmokeTests) {
        Invoke-SmokeChecks -ResourceGroupNames $resourceGroupNames -SubscriptionIdForTests $account.id
    }
}
finally {
    if (-not $KeepResources -and $shouldDestroy) {
        try {
            Invoke-LoggedNative -Name "terraform destroy" -FilePath "terraform" -ArgumentList @("destroy", "-input=false", "-auto-approve", "-var-file=$TfVarsPath") -WorkingDirectory $TerraformWorkDir

            foreach ($name in $expectedResourceGroups) {
                Assert-ResourceGroupDeleted -Name $name
            }

            $stateList = Get-TerraformStateList
            if ($stateList) {
                throw "Terraform state is not empty after destroy: $stateList"
            }

            $destroySucceeded = $true
            Remove-Item -LiteralPath (Join-Path $RepoRoot "terraform.tfstate"), (Join-Path $RepoRoot "terraform.tfstate.backup"), (Join-Path $RepoRoot ".terraform.tfstate.lock.info") -Force -ErrorAction SilentlyContinue
            Get-ChildItem -Path $RepoRoot -Filter "*.tfplan" -File | Remove-Item -Force -ErrorAction SilentlyContinue
            Get-ChildItem -Path $TerraformWorkDir -Filter "*.tfplan" -File | Remove-Item -Force -ErrorAction SilentlyContinue
            Remove-Item -LiteralPath (Join-Path $TerraformWorkDir "terraform.tfstate"), (Join-Path $TerraformWorkDir "terraform.tfstate.backup"), (Join-Path $TerraformWorkDir ".terraform.tfstate.lock.info") -Force -ErrorAction SilentlyContinue
        }
        finally {
            if (-not $destroySucceeded) {
                Write-Host "Destroy verification did not complete. Evidence logs: $LogRoot"
            }
        }
    }
}

Write-Host ""
Write-Host "Live validation logs: $LogRoot"
if ($KeepResources) {
    Write-Host "Resources were kept because -KeepResources was set."
}
elseif ($destroySucceeded) {
    Write-Host "Live validation completed and resources were destroyed."
}
