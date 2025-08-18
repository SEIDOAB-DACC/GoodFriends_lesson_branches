# az-login.ps1
# Usage: .\az-login.ps1 ..\az-resource-params\data-access

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
    $AzureHomeTenantId = .\az-access.ps1 $ResourceParamsPath tenantId

    $DockerCmd = DockerCmd $ResourceParamsPath

    # Start the container in Docker Desktop
    $ContainerId = ExecWithThrow "$DockerCmd ps -a" | Select-String $AzureCliContainer | ForEach-Object {
        $_.ToString().Split(" ")[0]
    }
    if ($ContainerId) {
        ExecWithThrow "$DockerCmd start $ContainerId"
    }

    # Test if logged in
    $AccountShow = ExecWithThrow "$DockerCmd exec $AzureCliContainer az account show" -NoThrow 

    $LoggedInTenant = if ($AccountShow) { ($AccountShow | ConvertFrom-Json).homeTenantId } else { "" }

    if ($LoggedInTenant -ne $AzureHomeTenantId) {
        if ($LoggedInTenant) {
            Write-Host "`nLogging out $LoggedInTenant"

            ExecWithThrow "$DockerCmd exec $AzureCliContainer az logout"
        }

        Write-Host "`nLogging in to azure as $AzureHomeTenantId..."
        ExecWithThrow "$DockerCmd exec $AzureCliContainer az login --tenant $AzureHomeTenantId"

    } else {
        Write-Host "`nLogged in as $LoggedInTenant`n"
    }
}

catch {
    <#Do this if a terminating exception happens#>
    throw "`n`nError: $($_.Exception.Message)`n"
}

    

ExecWithThrow "$DockerCmd exec $AzureCliContainer az account show"
Write-Host "`nLogged in as $LoggedInTenant`n"
Write-Host "`n`nSuccess! All commands completed successfully!`n"

# To generate GUID
# [guid]::NewGuid()