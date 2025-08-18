# az-create-all.ps1
# PowerShell script to create all necessary Azure resources (translation of az-create-all.sh)

# Usage:
# .\az-create-all.ps1 ./az-resource-params/data-access "../../Configuration/Configuration.csproj"

param(
    [Parameter(Mandatory = $true)]
    [string]$AzureProjectSettings,
    [Parameter(Mandatory = $true)]
    [string]$ApplicationProjectFile
)

# Resolve absolute paths
$AzureProjectSettings = Resolve-Path $AzureProjectSettings | Select-Object -ExpandProperty Path
$ApplicationProjectFile = Resolve-Path $ApplicationProjectFile | Select-Object -ExpandProperty Path

# Save current location and change to cli-bash
Push-Location ./cli-ps1

Write-Host "`nStarting the Azure resource creation workflow for $AzureProjectSettings`n"

try {
    # Run scripts (uncomment as needed)
    ./az-login.ps1 $AzureProjectSettings
    ./az-rg-create.ps1 $AzureProjectSettings
    ./az-kv-create.ps1 $AzureProjectSettings
    ./az-app-create.ps1 $AzureProjectSettings
    ./az-kv-sec-simple.ps1 $AzureProjectSettings
    ./az-kv-sec-copy.ps1 $AzureProjectSettings $ApplicationProjectFile
    ./az-sqlserver-create.ps1 $AzureProjectSettings
    ./az-sqlserver-db-create.ps1 $AzureProjectSettings
    ./az-kv-user-create.ps1 $AzureProjectSettings
    ./az-app-set-env.ps1 $AzureProjectSettings
    
    $SqlDbCStringFile = ./az-access-secrets.ps1 $AzureProjectSettings sql cstringfile
    Write-Host "`nSql Server Connection string is:`n"
    Get-Content $SqlDbCStringFile

    # Restore original location
    Pop-Location
}
catch {
    Pop-Location
    Write-Host "`n`nError: $($_.Exception.Message)`n"
}

Write-Host "`n`nSuccess! Workflow completed successfully!`n"
