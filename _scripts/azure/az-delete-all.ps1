# az-delete-all.ps1
# PowerShell script to delete all necessary Azure resources (translation of az-rg-delete.sh and az-kv-users-delete.sh)

# Usage:
# .\az-delete-all.ps1 .\az-resource-params\data-access

param(
    [Parameter(Mandatory = $true)]
    [string]$AzureProjectSettings
)

# Resolve absolute paths
$AzureProjectSettings = Resolve-Path $AzureProjectSettings | Select-Object -ExpandProperty Path

# Save current location and change to cli-ps1
Push-Location ./cli-ps1

Write-Host "`nStarting the Azure resource deletion workflow for $AzureProjectSettings`n"

try {
    
    ./az-login.ps1 $AzureProjectSettings

    #remove the resource group and all assets in it
    ./az-rg-delete.ps1 $AzureProjectSettings

    ./az-logout.ps1 $AzureProjectSettings
    Pop-Location
}
catch {
    Pop-Location
    Write-Host "`n`nError: $($_.Exception.Message)`n"
}

Write-Host "`n`nSuccess! Workflow completed successfully!`n"
