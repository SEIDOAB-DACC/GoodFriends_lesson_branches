# az-kv-users-delete.ps1
# Usage: .\az-kv-users-delete.ps1 ..\az-resource-params\data-access

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
    $ApplicationName = .\az-access.ps1 $ResourceParamsPath kvReadClient

    $DockerCmd = DockerCmd $ResourceParamsPath

    # Get all service principal IDs for the given display name
    $ListSpCmd = "$DockerCmd exec $AzureCliContainer az ad sp list --display-name '$ApplicationName' --output json"
    $SpsJson = ExecWithThrow $ListSpCmd
    $Sps = $SpsJson | ConvertFrom-Json

    if (-not $Sps -or $Sps.Count -eq 0) {
        throw "`n`nNo service principals found with display name: $ApplicationName"
    }

    Write-Host "Deleting service principals..."
    foreach ($sp in $Sps) {
        $sp_id = $sp.id
        if ($sp_id) {
            Write-Host "Deleting service principal: $sp_id"
            $DeleteSpCmd = "$DockerCmd exec $AzureCliContainer az ad sp delete --id $sp_id"
            ExecWithThrow $DeleteSpCmd
        }
    }

    Write-Host "`nSuccess! All commands completed successfully!`n"
}
catch {
    throw "`n`nError: $($_.Exception.Message)`n"
}
