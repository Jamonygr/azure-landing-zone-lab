[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [ValidateSet('fmt', 'validate', 'tflint', 'trivy', 'checkov')]
    [string]$Check
)

$ErrorActionPreference = 'Stop'
$repoRoot = Split-Path -Parent $PSScriptRoot
Set-Location $repoRoot

switch ($Check) {
    'fmt' {
        & terraform fmt -check -recursive
    }
    'validate' {
        & terraform validate -no-color
    }
    'tflint' {
        & tflint --recursive --format compact
    }
    'trivy' {
        & trivy config --severity MEDIUM,HIGH,CRITICAL --exit-code 1 --ignorefile .trivyignore.yaml .
    }
    'checkov' {
        & checkov -d . --config-file .checkov.yml --compact --quiet
    }
}

if ($LASTEXITCODE -ne 0) {
    throw "$Check failed with exit code $LASTEXITCODE."
}
