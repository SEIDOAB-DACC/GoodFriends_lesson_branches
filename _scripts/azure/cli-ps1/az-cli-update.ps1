# az-cli-update.ps1
# Usage: .\az-cli-update.ps1 ..\az-resource-params\data-access

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

    $DockerCmd = DockerCmd $ResourceParamsPath


    # Stop and remove any already running container
    Write-Host "`nStopping and removing any already running $AzureCliContainer container"
    ExecWithThrow "$DockerCmd stop $AzureCliContainer" -NoThrow
    ExecWithThrow "$DockerCmd rm $AzureCliContainer" -NoThrow

    # Get the latest update of azure cli
    Write-Host "`nPulling the latest update of azure cli"
    ExecWithThrow "$DockerCmd pull mcr.microsoft.com/azure-cli:latest"

    # Run new container
    Write-Host "`nRun $AzureCliContainer container"
    ExecWithThrow "$DockerCmd run -d --name $AzureCliContainer -p 2222:22 -p 8080:8080 mcr.microsoft.com/azure-cli:latest sleep infinity"

    Write-Host "`n`nSuccess! All commands completed successfully!`n"
}
catch {
    throw "`n`nError: $($_.Exception.Message)`n"
}
