# az-kv-update.ps1
# PowerShell script to update Azure Key Vault with user secrets (translation of az-kv-update.sh)

# Usage:
# .\az-kv-update.ps1

$ProjectFile="../Configuration/Configuration.csproj"
$SettingsFile="../AppWebApi/appsettings.json"

$ApplicationProjectFile=Resolve-Path $ProjectFile | Select-Object -ExpandProperty Path
$ApplicationSettingsFile=Resolve-Path $SettingsFile | Select-Object -ExpandProperty Path

# Save current location and change to cli-bash
Push-Location ./azure/cli-ps1

try {
    Write-Host "`nStarting Azure Key Vault update workflow...`n"
    
    # Read the AzureSettings path from appsettings.json
    Write-Host "Reading Azure settings from: $ApplicationSettingsFile"
    
    # Read the file and remove JSON comments using regex
    $RawContent = Get-Content $ApplicationSettingsFile -Raw
    # Remove // comments (both standalone and inline)
    $CleanContent = $RawContent -replace '//.*', ''
    $AppSettingsContent = $CleanContent | ConvertFrom-Json
    $AzureSettings = $AppSettingsContent.ApplicationSecrets.AzureSettings
    
    if (-not $AzureSettings) {
        throw "AzureSettings not found in appsettings.json under ApplicationSecrets.AzureSettings"
    }
       
    Write-Host "Executing az-login.ps1..."
    .\az-login.ps1 $AzureSettings
    
    Write-Host "`nExecuting az-kv-sec-copy.ps1..."
    .\az-kv-sec-copy.ps1 $AzureSettings $ApplicationProjectFile
    

    Write-Host "`n`nSet SecretStorage to 'AzureKeyVault' in appsettings.json..."
    $AppSettingsPath = "..\..\..\AppWebApi\appsettings.json"
    $Content = Get-Content $AppSettingsPath -Raw
    $UpdatedContent = $Content -replace '"SecretStorage":\s*"[^"]*"', '"SecretStorage": "AzureKeyVault"'
    Set-Content $AppSettingsPath $UpdatedContent

    Write-Host "`n`nSuccess! Azure Key Vault update completed successfully!`n"
}
catch {
    Write-Host "`n`nError: $($_.Exception.Message)`n"
    exit 1
}
finally {

    # Restore original location
    Pop-Location
}
