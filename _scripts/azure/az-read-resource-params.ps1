# az-read-resource-params.ps1
# Usage:
# .\az-read-resource-params.ps1 ./az-resource-params/data-access "../../Configuration/Configuration.csproj"

param (
    [Parameter(Mandatory = $true)]
    [string]$AzureProjectSettings,
    [Parameter(Mandatory = $true)]
    [string]$ApplicationProjectFile
)


$AzureProjectSettings = Resolve-Path $AzureProjectSettings
$ApplicationProjectFile = Resolve-Path $ApplicationProjectFile

Write-Host "`nReading all the Azure parameters of $AzureProjectSettings`n"

Push-Location ./cli-ps1


try {
    
    # az-access.ps1 calls
    .\az-access.ps1 $AzureProjectSettings docker-azure-container
    .\az-access.ps1 $AzureProjectSettings tenantId
    .\az-access.ps1 $AzureProjectSettings resourceGroup
    .\az-access.ps1 $AzureProjectSettings kvUri
    .\az-access.ps1 $AzureProjectSettings kvName
    .\az-access.ps1 $AzureProjectSettings kvSecret
    .\az-access.ps1 $AzureProjectSettings kvReadClient
    .\az-access.ps1 $AzureProjectSettings sqlServer
    .\az-access.ps1 $AzureProjectSettings sqlDb
    .\az-access.ps1 $AzureProjectSettings appservicePlanName
    .\az-access.ps1 $AzureProjectSettings appserviceName
    .\az-access.ps1 $AzureProjectSettings path
    .\az-access.ps1 $AzureProjectSettings file
    .\az-access.ps1 $AzureProjectSettings template
    .\az-access.ps1 $AzureProjectSettings fname

    # az-access-secrets.ps1 calls
    .\az-access-secrets.ps1 $AzureProjectSettings app appId
    .\az-access-secrets.ps1 $AzureProjectSettings app displayName
    .\az-access-secrets.ps1 $AzureProjectSettings app password
    .\az-access-secrets.ps1 $AzureProjectSettings app path
    .\az-access-secrets.ps1 $AzureProjectSettings app file
    .\az-access-secrets.ps1 $AzureProjectSettings app fname

    .\az-access-secrets.ps1 $AzureProjectSettings sql sqlRootUser
    .\az-access-secrets.ps1 $AzureProjectSettings sql sqlRootPassword
    .\az-access-secrets.ps1 $AzureProjectSettings sql path
    .\az-access-secrets.ps1 $AzureProjectSettings sql file
    .\az-access-secrets.ps1 $AzureProjectSettings sql fname
    .\az-access-secrets.ps1 $AzureProjectSettings sql cstring
    .\az-access-secrets.ps1 $AzureProjectSettings sql cstringfile

    .\az-access-secrets.ps1 $AzureProjectSettings usrsec path $ApplicationProjectFile
    .\az-access-secrets.ps1 $AzureProjectSettings usrsec file $ApplicationProjectFile
    .\az-access-secrets.ps1 $AzureProjectSettings usrsec fname $ApplicationProjectFile
    .\az-access-secrets.ps1 $AzureProjectSettings usrsec file $ApplicationProjectFile
    .\az-access-secrets.ps1 $AzureProjectSettings usrsec path $ApplicationProjectFile
    .\az-access-secrets.ps1 $AzureProjectSettings usrsec fname $ApplicationProjectFile

    Pop-Location
}
catch {
    <#Do this if a terminating exception happens#>
    Write-Host "`n`nError: $($_.Exception.Message)`n"
    Pop-Location
    exit
}

Write-Host "`n`nSuccess! All commands completed successfully!`n`n"
