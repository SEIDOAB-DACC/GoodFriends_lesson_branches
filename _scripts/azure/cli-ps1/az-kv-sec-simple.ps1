# az-kv-sec-simple.ps1
# Usage: .\az-kv-sec-simple.ps1 ..\az-resource-params\data-access

param (
    [Parameter(Mandatory = $true)]
    [string]$ResourceParamsPath
)


# Import helper functions
. "$PSScriptRoot\ExecWithThrow.ps1"
. "$PSScriptRoot\DockerCmd.ps1"


try {
    # Get all access parameters
    $AzureCliContainer = .\az-access.ps1 $ResourceParamsPath docker-azure-container
    $AzureKeyVaultName = .\az-access.ps1 $ResourceParamsPath kvName
    $AzureKeyVaultSecret = .\az-access.ps1 $ResourceParamsPath kvSecret

    $DockerCmd = DockerCmd $ResourceParamsPath


    $SecretMessage="Super-secret-Hello-from-Seido"

    Write-Host "`nCreating a test secret, $AzureKeyVaultSecret, in vault $AzureKeyVaultName...`n"
    $SetSecretCmd = $DockerCmd + " exec " + $AzureCliContainer + " az keyvault secret set --vault-name " + $AzureKeyVaultName + " --name " + $AzureKeyVaultSecret + " --value " + $SecretMessage
    ExecWithThrow $SetSecretCmd

    Write-Host "`nSuccess! All commands completed successfully!`n"
}   
catch {
    throw "`n`nError: $($_.Exception.Message)`n"
}
