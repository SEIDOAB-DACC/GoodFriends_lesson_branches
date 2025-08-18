# az-new-settings.ps1
# PowerShell script using the template file az-settings-template.json to create a new az-settings.json file

# Usage:
# .\az-new-settings.ps1 ./az-resource-params/data-access

param(
    [Parameter(Mandatory = $true)]
    [string]$AzureProjectSettings
)

# Resolve absolute paths
$AzureProjectSettings = Resolve-Path $AzureProjectSettings | Select-Object -ExpandProperty Path

$AzureFile = ./cli-ps1/az-access.ps1 $AzureProjectSettings file
$AzureTemplate = ./cli-ps1/az-access.ps1 $AzureProjectSettings template

$Suffix8 = ([guid]::NewGuid().ToString() -replace '^([0-9a-fA-F]{8}).*','$1')
Write-Host "Using suffix8: $Suffix8"

$Suffix4 = ([guid]::NewGuid().ToString() -replace '^([0-9a-fA-F]{4}).*','$1')
Write-Host "Using suffix4: $Suffix4"

$content = Get-Content -Path $AzureTemplate
$content = $content -replace '<suffix8>', $Suffix8
$content = $content -replace '<suffix4>', $Suffix4

# Create backup of existing file if it exists
if (Test-Path $AzureFile) {
    $BackupFile = "$AzureFile.bak.$(Get-Date -Format yyyyMMddHHmmss)"
    Copy-Item $AzureFile $BackupFile
    Write-Host "Backup created: $BackupFile"
}

$content | Set-Content -Path $AzureFile     