# az-kv-sec-copy.ps1
# Usage: .\az-kv-sec-copy.ps1 ..\az-resource-params\data-access ../../../Configuration/Configuration.csproj

param (
    [Parameter(Mandatory = $true)]
    [string]$ResourceParamsPath,
    [Parameter(Mandatory = $true)]
    [string]$CsProjPath
)

# Import helper functions
. "$PSScriptRoot\ExecWithThrow.ps1"
. "$PSScriptRoot\DockerCmd.ps1"


try {
    # Get all access parameters
    $AzureCliContainer = .\az-access.ps1 $ResourceParamsPath docker-azure-container
    $AzureHomeTenantId = .\az-access.ps1 $ResourceParamsPath tenantId
    $AzureKeyVaultName = .\az-access.ps1 $ResourceParamsPath kvName
    $AzureKeyVaultSecret = .\az-access.ps1 $ResourceParamsPath kvSecret

    $DockerCmd = DockerCmd $ResourceParamsPath

    # Get user secret file and name
    $UserSecretFile = .\az-access-secrets.ps1 $ResourceParamsPath usrsec file $CsProjPath
    $UserSecretFileName = .\az-access-secrets.ps1 $ResourceParamsPath usrsec fname $CsProjPath

    if (-not $UserSecretFile -or -not $UserSecretFileName) {
        Write-Host "`n`nAzure secrets parameters error"
        exit 1
    }

    Write-Host "`nKey vault access parameters"
    Write-Host "UserSecretFile=$UserSecretFile"
    Write-Host "AzureKeyVaultSecret=$AzureKeyVaultSecret"
    Write-Host "AzureHomeTenantId=$AzureHomeTenantId"
    Write-Host "AzureKeyVaultName=$AzureKeyVaultName`n"

    # Start the container in Docker Desktop
    $ContainerId = ExecWithThrow "$DockerCmd ps -a" | Select-String $AzureCliContainer | ForEach-Object {
        $_.ToString().Split(" ")[0]
    }
    if ($ContainerId) {
        ExecWithThrow "$DockerCmd start $ContainerId"
    }

    # Create location for user secret in Azure cli container
    Write-Host "`nCreating folder $AzureKeyVaultSecret in container $AzureCliContainer..."
    ExecWithThrow "$DockerCmd exec $AzureCliContainer rm -rf $AzureKeyVaultSecret"
    ExecWithThrow "$DockerCmd exec $AzureCliContainer mkdir $AzureKeyVaultSecret"
    ExecWithThrow "$DockerCmd exec $AzureCliContainer ls"

    # Copy user secrets into Azure cli container at right location
    Write-Host "`nCopying $UserSecretFile to folder $AzureKeyVaultSecret..."

    $DockerAccess = .\az-access.ps1 $ResourceParamsPath docker-access
    if ($DockerAccess -ne "ssh" ){

        # docker runs locally
        # copy user secrets into Azure cli container at right location
        $CopyCmd = "$DockerCmd cp $UserSecretFile ${AzureCliContainer}:$AzureKeyVaultSecret"
        ExecWithThrow $CopyCmd
    }
    else{

        #Cannot copy file directly from client to Docker container. Needs first to be copied to Docker host
        $DockerUser = .\az-access.ps1 $ResourceParamsPath docker-ssh-user
        $DockerHost = .\az-access.ps1 $ResourceParamsPath docker-ssh-host
        $DockerHostTmpDir = .\az-access.ps1 $ResourceParamsPath docker-ssh-host-tmp

        # Copy user secret file to Docker host
        scp $UserSecretFile $DockerUser@${DockerHost}:$DockerHostTmpDir/$UserSecretFileName

        # copy user secrets from Docker host into Azure cli container at right location
        $CopyCmd = "$DockerCmd cp $DockerHostTmpDir/$UserSecretFileName ${AzureCliContainer}:$AzureKeyVaultSecret"
        ExecWithThrow $CopyCmd
    }

    # Create and copy the secret to azkv
    Write-Host "`nCopying $AzureKeyVaultSecret/$UserSecretFileName to secret $AzureKeyVaultSecret in keyvault $AzureKeyVaultName..."
    $SetSecretCmd = "$DockerCmd exec $AzureCliContainer az keyvault secret set --name $AzureKeyVaultSecret --vault-name $AzureKeyVaultName --file $AzureKeyVaultSecret/$UserSecretFileName"
    ExecWithThrow $SetSecretCmd

    # Cleanup: remove location for user secret in Azure cli container
    Write-Host "`nRemoving folder $AzureKeyVaultSecret in container $AzureCliContainer..."
    ExecWithThrow "$DockerCmd exec $AzureCliContainer rm -rf $AzureKeyVaultSecret"
    ExecWithThrow "$DockerCmd exec $AzureCliContainer ls"

    Write-Host "`nSuccess! All commands completed successfully!`n"
}
catch {
    throw "`n`nError: $($_.Exception.Message)`n"
}
