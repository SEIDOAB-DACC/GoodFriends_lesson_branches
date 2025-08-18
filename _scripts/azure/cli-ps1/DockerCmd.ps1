# DockerCmd.ps1
# Helper function to run a command and throw if it fails
function DockerCmd {
    param (
        [Parameter(Mandatory = $true)]
        [string]$ResourceParamsPath
    )

    $DockerAccess = .\az-access.ps1 $ResourceParamsPath docker-access
    if ($DockerAccess -ne "ssh") {
        return "docker"
    }


    $DockerHost = .\az-access.ps1 $ResourceParamsPath docker-ssh-host
    $DockerUser = .\az-access.ps1 $ResourceParamsPath docker-ssh-user
    $DockerCmd = .\az-access.ps1 $ResourceParamsPath docker-ssh-cmd

    return "ssh $DockerUser@$DockerHost $DockerCmd"
}
