# az-kv-user-create.ps1
# Usage: .\az-kv-user-create.ps1 ..\az-resource-params\data-access

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
    $AzureResourceGroup = .\az-access.ps1 $ResourceParamsPath resourceGroup
    $AzureKeyVaultName = .\az-access.ps1 $ResourceParamsPath kvName
    $ApplicationName = .\az-access.ps1 $ResourceParamsPath kvReadClient
    $ApplicationFile = .\az-access-secrets.ps1 $ResourceParamsPath app file

    $DockerCmd = DockerCmd $ResourceParamsPath



    # Setting role and rolescope to the resource
    # Azure built-in role id for Key Vault Secrets User
    $Role = '4633458b-17de-408a-b874-0445c86b69e6'

    # Get the scope of $AzureResourceGroup (simplified and robust)
    $GroupIdCmd = "$DockerCmd exec $AzureCliContainer az group show --name $AzureResourceGroup --query id -o tsv"
    $RoleScope = ExecWithThrow $GroupIdCmd
    if (-not $RoleScope) {
        throw "Resource group $AzureResourceGroup not found."
    }

    Write-Host "`nRegistering application $ApplicationName with Microsoft Entra ID...`n"
    $CreateAppCmd = "$DockerCmd exec $AzureCliContainer az ad sp create-for-rbac -n '$ApplicationName' --role '$Role' --scope '$RoleScope'"
    $AppJson = ExecWithThrow $CreateAppCmd
    $AppJson | Out-File -Encoding utf8 $ApplicationFile

    Write-Host "`nAccess keys to $AzureKeyVaultName are stored in $ApplicationFile`n"
    Write-Host "`nSuccess! All commands completed successfully!`n"
}
catch {
    throw "`n`nError: $($_.Exception.Message)`n"
}
