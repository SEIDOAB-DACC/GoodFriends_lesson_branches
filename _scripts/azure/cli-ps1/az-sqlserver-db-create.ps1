# az-sqlserver-db-create.ps1
# Usage: .\az-sqlserver-db-create.ps1 ..\az-resource-params\data-access

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
    $SqlDbName = .\az-access.ps1 $ResourceParamsPath sqlDb
    $SqlServerSa = .\az-access-secrets.ps1 $ResourceParamsPath sql sqlRootUser
    $SqlServerSaPassword = .\az-access-secrets.ps1 $ResourceParamsPath sql sqlRootPassword
    $SqlDbCStringFile = .\az-access-secrets.ps1 $ResourceParamsPath sql cstringfile

    $DockerCmd = DockerCmd $ResourceParamsPath


    Write-Host "`nCreating $SqlDbName on $SqlServerName..."
    $CreateDbCmd = "$DockerCmd exec $AzureCliContainer az sql db create --resource-group $ResourceGroup --server $SqlServerName --name $SqlDbName --edition GeneralPurpose --compute-model Serverless --family Gen5 --capacity 1"
    ExecWithThrow $CreateDbCmd

    Write-Host "`nGenerating ADO.Net Connection String..."
    $ConnectionStringCmd = "$DockerCmd exec $AzureCliContainer az sql db show-connection-string --name $SqlDbName --client ado.net --server $SqlServerName"
    $ConnectionString = ExecWithThrow $ConnectionStringCmd

    # Replace placeholders with actual credentials and remove quotes
    $ConnectionString = $ConnectionString -replace '<username>', $SqlServerSa
    $ConnectionString = $ConnectionString -replace '<password>', $SqlServerSaPassword
    $ConnectionString = $ConnectionString -replace '"', ''

    # Create connection strings for all user roles
    $RootConnectionString = $ConnectionString
    $DboConnectionString = $ConnectionString -replace "User ID=$SqlServerSa", "User ID=dboUser" -replace "Password=$SqlServerSaPassword", "Password=pa`$Word1"
    $SupusrConnectionString = $ConnectionString -replace "User ID=$SqlServerSa", "User ID=supusrUser" -replace "Password=$SqlServerSaPassword", "Password=pa`$Word1"
    $UsrConnectionString = $ConnectionString -replace "User ID=$SqlServerSa", "User ID=usrUser" -replace "Password=$SqlServerSaPassword", "Password=pa`$Word1"
    $GstusrConnectionString = $ConnectionString -replace "User ID=$SqlServerSa", "User ID=gstusrUser" -replace "Password=$SqlServerSaPassword", "Password=pa`$Word1"

    # Create JSON structure with all connection strings
    $ConnectionStringsJson = @"
{
    "sql-friends.sqlserver.azure.root": "$RootConnectionString",
    "sql-friends.sqlserver.azure.dbo": "$DboConnectionString",
    "sql-friends.sqlserver.azure.supusr": "$SupusrConnectionString",
    "sql-friends.sqlserver.azure.usr": "$UsrConnectionString",
    "sql-friends.sqlserver.azure.gstusr": "$GstusrConnectionString"
}
"@

    # Save connection strings to file
    $ConnectionStringsJson | Out-File -FilePath $SqlDbCStringFile -Encoding UTF8

    Write-Host "`nRole based connection strings to $SqlDbName on $SqlServerName are stored in $SqlDbCStringFile"
    Write-Host "`nRoot connection string is:"
    Write-Host $RootConnectionString

    Write-Host "`n`nSuccess! All commands completed successfully!`n"
}
catch {
    throw "`n`nError: $($_.Exception.Message)`n"
}
