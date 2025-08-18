# az-kv-create.ps1
# Usage: .\az-kv-create.ps1 ..\az-resource-params\data-access

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

    $DockerCmd = DockerCmd $ResourceParamsPath


    Write-Host "`nCreating key vault $AzureKeyVaultName...`n"
    ExecWithThrow "$DockerCmd exec $AzureCliContainer az keyvault create --name $AzureKeyVaultName --resource-group $AzureResourceGroup"

    Write-Host "`nAssigning owner credential to $AzureKeyVaultName...`n"
    # 1. Get principal id from signed in user
    $PrincipalIdJson = ExecWithThrow "$DockerCmd exec $AzureCliContainer az ad signed-in-user show"
    $PrincipalId = ($PrincipalIdJson | ConvertFrom-Json).id

    # 2. Define the Role (Id of the role Key Vault Administrator)
    $Role = '00482a5a-887f-4fb3-b363-3b7fe8e74483'


    # 3. Get the scope of $AzureResourceGroup (simplified and robust)
    $GroupIdCmd = "$DockerCmd exec $AzureCliContainer az group show --name $AzureResourceGroup --query id -o tsv"
    $RoleScope = ExecWithThrow $GroupIdCmd
    if (-not $RoleScope) {
        throw "Resource group $AzureResourceGroup not found."
    }
    
    #assign the role and scope to the principal
    $RoleCmd = $DockerCmd + " exec " + $AzureCliContainer + " az role assignment create --assignee " + $PrincipalId + " --role " + $Role + " --scope " + $RoleScope
    ExecWithThrow $RoleCmd
}
catch {
    throw "`n`nError: $($_.Exception.Message)`n"
}

Write-Host "`n`nSuccess! All commands completed successfully!`n"
