# az-logout.ps1
# Usage: .\az-logout.ps1 ..\az-resource-params\data-access

param (
    [Parameter(Mandatory = $true)]
    [string]$ResourceParamsPath
)

# Import helper functions
. "$PSScriptRoot\ExecWithThrow.ps1"
. "$PSScriptRoot\DockerCmd.ps1"

try {
    $AzureCliContainer = .\az-access.ps1 $ResourceParamsPath docker-azure-container

    $DockerCmd = DockerCmd $ResourceParamsPath


    Write-Host "`nLogging out from Azure..."
    ExecWithThrow "$DockerCmd exec $AzureCliContainer az logout" -NoThrow

    Write-Host "`nConfirming that you are logged out from Azure"
    ExecWithThrow "$DockerCmd exec $AzureCliContainer az account show" -NoThrow
}
catch {
    throw "`n`nError: $($_.Exception.Message)`n"
}
