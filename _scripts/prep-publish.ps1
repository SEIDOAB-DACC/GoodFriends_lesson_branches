# prep-publish.ps1
# PowerShell script to prepare and publish the application (translation of prep-publish.sh)

# Usage:
# .\prep-publish.ps1 AppWebApi

param(
    [Parameter(Mandatory = $true)]
    [string]$ApplicationToPublish
)

$SettingsFile="../$ApplicationToPublish/appsettings.json"
$ApplicationSettingsFile=Resolve-Path $SettingsFile | Select-Object -ExpandProperty Path

try {
    
    # Step1: Set the Azure Keyvault access parameters as operating system environment variables.
     # Read the file and remove JSON comments using regex
    $RawContent = Get-Content $ApplicationSettingsFile -Raw
    # Remove // comments (both standalone and inline)
    $CleanContent = $RawContent -replace '//.*', ''
    $AppSettingsContent = $CleanContent | ConvertFrom-Json
    $AzureSettings = $AppSettingsContent.ApplicationSecrets.AzureSettings
    
    if (-not $AzureSettings) {
        throw "AzureSettings not found in appsettings.json under ApplicationSecrets.AzureSettings"
    }
    
    Write-Host "`n`nSetting the azure key vault access as environment variables"

    
    # Set environment variables using the PowerShell Azure access scripts
    Push-Location ".\azure\cli-ps1"
    $env:AZURE_TENANT_ID = .\az-access.ps1 $AzureSettings tenantId
    $env:AZURE_KeyVaultUri = .\az-access.ps1 $AzureSettings kvUri
    $env:AZURE_KeyVaultSecret = .\az-access.ps1 $AzureSettings kvSecret
    $env:AZURE_CLIENT_ID = .\az-access-secrets.ps1 $AzureSettings app appId
    $env:AZURE_CLIENT_SECRET = .\az-access-secrets.ps1 $AzureSettings app password
    Pop-Location

    # Verify environment variables
    Write-Host "AZURE_TENANT_ID=" $env:AZURE_TENANT_ID
    Write-Host "AZURE_KeyVaultUri=" $env:AZURE_KeyVaultUri
    Write-Host "AZURE_KeyVaultSecret=" $env:AZURE_KeyVaultSecret
    Write-Host "AZURE_CLIENT_ID=" $env:AZURE_CLIENT_ID
    Write-Host "AZURE_CLIENT_SECRET=" $env:AZURE_CLIENT_SECRET
    

    # Step2: Set production settings in appsettings.json        
    Write-Host "`n`nSet DefaultDataUser to 'gstusr' and SecretStorage to 'AzureKeyVault' in appsettings.json..."
    $AppSettingsPath = "..\AppWebApi\appsettings.json"
    $Content = Get-Content $AppSettingsPath -Raw
    $UpdatedContent = $Content -replace '"DefaultDataUser":\s*"[^"]*"', '"DefaultDataUser": "gstusr"'
    $UpdatedContent = $UpdatedContent -replace '"SecretStorage":\s*"[^"]*"', '"SecretStorage": "AzureKeyVault"'
    Set-Content $AppSettingsPath $UpdatedContent
    
    # Step3: Generate the release files
    Write-Host "`n`nPublish the webapi..."
    
    # Remove any previous publish
    $PublishPath = "..\$ApplicationToPublish\publish"
    if (Test-Path $PublishPath) {
        Remove-Item $PublishPath -Recurse -Force
    }
    
    Push-Location "..\$ApplicationToPublish"
    dotnet publish --configuration Release --output .\publish
    Pop-Location

    # Step4: Ensure any previous instances are stopped
    Write-Host "`n`nEnsure any previous instances are stopped..."
    
    # Kill any processes using port 5001
    try {
        $ProcessIds = Get-NetTCPConnection -LocalPort 5001 -ErrorAction SilentlyContinue | Select-Object -ExpandProperty OwningProcess
        if ($ProcessIds) {
            foreach ($ProcessId in $ProcessIds) {
                Stop-Process -Id $ProcessId -Force -ErrorAction SilentlyContinue
            }
            Write-Host "Stopped existing processes on port 5001"
        }
    }
    catch {
        Write-Host "No processes found on port 5001"
    }
    
    # Step5: Run the application from the folder containing the release files
    Write-Host "`n`nRun the webapi from the published directory..."
    Push-Location "..\$ApplicationToPublish\publish"

    $env:ASPNETCORE_URLS = "https://localhost:5001"
    
    Write-Host "`nStarting $ApplicationToPublish..."
    & ".\$ApplicationToPublish.exe"

    Pop-Location
}
catch {
    Write-Host "`n`nError: $($_.Exception.Message)`n"
    exit 1
}
