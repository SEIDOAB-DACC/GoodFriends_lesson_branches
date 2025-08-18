# az-sqlserver-create.ps1
# Usage: .\az-sqlserver-create.ps1 ..\az-resource-params\data-accessk

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
    $ResourceGroup = .\az-access.ps1 $ResourceParamsPath resourceGroup
    $SqlServerName = .\az-access.ps1 $ResourceParamsPath sqlServer
    $SqlServerSa = .\az-access-secrets.ps1 $ResourceParamsPath sql sqlRootUser
    $SqlServerSaPassword = .\az-access-secrets.ps1 $ResourceParamsPath sql sqlRootPassword

    $DockerCmd = DockerCmd $ResourceParamsPath


    Write-Host "`nCreating $SqlServerName in $ResourceGroup...`n"
    $CreateCmd = "$DockerCmd exec $AzureCliContainer az sql server create --name $SqlServerName --resource-group $ResourceGroup --location 'swedencentral' --admin-user $SqlServerSa --admin-password $SqlServerSaPassword"
    ExecWithThrow $CreateCmd

    # Setting up the firewall
    . "$PSScriptRoot/az-sqlserver-fw-open-myip.ps1" $ResourceParamsPath

    Write-Host "`n`nSuccess! All commands completed successfully!`n"
}
catch {
    throw "`n`nError: $($_.Exception.Message)`n"
}
