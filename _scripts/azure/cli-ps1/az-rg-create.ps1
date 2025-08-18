# az-rg-create.ps1
# Usage: .\az-rg-create.ps1 ..\az-resource-params\data-access

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


    Write-Host "`nCreating resource group $AzureResourceGroup...`n"
    ExecWithThrow "$DockerCmd exec $AzureCliContainer az group create --name $AzureResourceGroup --location swedencentral"
}
catch {
    throw "`n`nError: $($_.Exception.Message)`n"
}

Write-Host "`n`nSuccess! All commands completed successfully!`n"
