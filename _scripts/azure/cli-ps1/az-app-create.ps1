# az-app-create.ps1
# Usage: .\az-app-create.ps1 ..\az-resource-params\data-access

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
    $AppServicePlan = .\az-access.ps1 $ResourceParamsPath appservicePlanName
    $AppService = .\az-access.ps1 $ResourceParamsPath appserviceName

    $DockerCmd = DockerCmd $ResourceParamsPath


    # Create the app service plan
    Write-Host "`nCreating app service plan $AppServicePlan..."
    $CreatePlanCmd = "$DockerCmd exec $CliContainer az appservice plan create -g $ResourceGroup -n $AppServicePlan --sku F1"
    ExecWithThrow $CreatePlanCmd

    # Create the web app service
    Write-Host "`nCreating web app service $AppService using plan $AppServicePlan..."
    $CreateAppCmd = "$DockerCmd exec $CliContainer az webapp create -g $ResourceGroup -p $AppServicePlan -n $AppService"
    ExecWithThrow $CreateAppCmd

    Write-Host "`n`nSuccess! All commands completed successfully!`n"
}
catch {
    throw "`n`nError: $($_.Exception.Message)`n"
}
