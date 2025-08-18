
# az-rg-delete.ps1
# Usage: .\az-rg-delete.ps1 ..\az-resource-params\data-access

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

    $DockerCmd = DockerCmd $ResourceParamsPath

    $ApplicationName = .\az-access-secrets.ps1 $ResourceParamsPath app displayName

    Write-Host "`nRemoving resource group $AzureResourceGroup...`n"
    ExecWithThrow "$DockerCmd exec $AzureCliContainer az group delete --name $AzureResourceGroup --yes"

    Write-Host "`nRemoving application $ApplicationName...`n"
    $AppListJson = ExecWithThrow "$DockerCmd exec $AzureCliContainer az ad app list --display-name $ApplicationName"
    $AppId = $null
    if ($AppListJson) {
        $AppList = $AppListJson | ConvertFrom-Json
        if ($AppList -is [System.Collections.IEnumerable]) {
            $AppId = $AppList[0].appId
        } elseif ($AppList.appId) {
            $AppId = $AppList.appId
        }
    }
    if ($AppId) {
        ExecWithThrow "$DockerCmd exec $AzureCliContainer az ad app delete --id $AppId"
    }
}
catch {
    throw "`n`nError: $($_.Exception.Message)`n"
}

Write-Host "`n`nSuccess! All commands completed successfully!`n"
