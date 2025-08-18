# az-app-set-env.ps1
# Usage: .\az-app-set-env.ps1 ..\az-resource-params\data-access

param (
    [Parameter(Mandatory = $true)]
    [string]$ResourceParamsPath
)

# Import helper functions
. "$PSScriptRoot\ExecWithThrow.ps1"
. "$PSScriptRoot\DockerCmd.ps1"

try {
    # Get all access parameters
    $CliContainer = .\az-access.ps1 $ResourceParamsPath docker-azure-container
    $ResourceGroup = .\az-access.ps1 $ResourceParamsPath resourceGroup
    $AppService = .\az-access.ps1 $ResourceParamsPath appserviceName
    $HomeTenantId = .\az-access.ps1 $ResourceParamsPath tenantId
    $AzureKeyVaultUri = .\az-access.ps1 $ResourceParamsPath kvUri
    $AzureKeyVaultSecret = .\az-access.ps1 $ResourceParamsPath kvSecret
    $AzureClientId = .\az-access-secrets.ps1 $ResourceParamsPath app appId
    $AzureClientSecret = .\az-access-secrets.ps1 $ResourceParamsPath app password

    $DockerCmd = DockerCmd $ResourceParamsPath


    # Setting environment variables to access keyvault
    Write-Host "`nSetting environment variables on web app service $AppService to access keyvault $AzureKeyVaultUri..."
    $SetEnvCmd = "$DockerCmd exec $CliContainer az webapp config appsettings set -g $ResourceGroup -n $AppService --settings AZURE_TENANT_ID=$HomeTenantId AZURE_KeyVaultUri=$AzureKeyVaultUri AZURE_KeyVaultSecret=$AzureKeyVaultSecret AZURE_CLIENT_ID=$AzureClientId AZURE_CLIENT_SECRET=$AzureClientSecret"
    ExecWithThrow $SetEnvCmd

    Write-Host "`n`nSuccess! All commands completed successfully!`n"
}
catch {
    throw "`n`nError: $($_.Exception.Message)`n"
}
