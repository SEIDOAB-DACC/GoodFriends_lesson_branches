# az-sqlserver-fw-open-myip.ps1
# Usage: .\az-sqlserver-fw-open-myip.ps1 ..\az-resource-params\data-access

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

    $DockerCmd = DockerCmd $ResourceParamsPath


    Write-Host "`nDetecting current public IP address..."
    $CurrentIp = (Invoke-RestMethod -Uri "https://ipinfo.io/ip").Trim()
    if (-not $CurrentIp) {
        throw "Error: Could not detect current IP address"
    }
    Write-Host "Current IP address: $CurrentIp"

    # Create IP range from current IP subnet (0-255 for last octet)
    $IpBase = ($CurrentIp -split '\.')[0..2] -join '.'
    $SqlFirewallStartIp = "$IpBase.0"
    $SqlFirewallEndIp = "$IpBase.255"
    Write-Host "IP range: $SqlFirewallStartIp - $SqlFirewallEndIp"

    Write-Host "`nConfiguring firewall..."
    $Rule1 = "$DockerCmd exec $AzureCliContainer az sql server firewall-rule create --resource-group $ResourceGroup --server $SqlServerName -n AllowYourIp --start-ip-address $SqlFirewallStartIp --end-ip-address $SqlFirewallEndIp"
    ExecWithThrow $Rule1

    $Rule2 = "$DockerCmd exec $AzureCliContainer az sql server firewall-rule create --resource-group $ResourceGroup --server $SqlServerName -n AllowAllWindowsAzureIps --start-ip-address 0.0.0.0 --end-ip-address 0.0.0.0"
    ExecWithThrow $Rule2

    Write-Host "`n`nSuccess! All commands completed successfully!`n"
}
catch {
    throw "`n`nError: $($_.Exception.Message)`n"
}
