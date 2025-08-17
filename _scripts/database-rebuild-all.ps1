# För att göra .ps1-filen körbar, kör följande kommando i PowerShell (Behöver bara köras första gången):
# Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser


#If EFC tools needs update use:
#dotnet tool update --global dotnet-ef

# To execute:
#.\database-rebuild-all.ps1 sqlserver [docker|azure]
#.\database-rebuild-all.ps1 mysql [docker|azure]
#.\database-rebuild-all.ps1 postgresql [docker|azure]

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("sqlserver", "mysql", "postgresql")]
    [string]$DatabaseType,
    
    [Parameter(Mandatory=$true)]
    [ValidateSet("docker", "azure")]
    [string]$DeploymentTarget
)

#Set Database Context
switch ($DatabaseType) {
    "sqlserver" { $DBContext = "SqlServerDbContext" }
    "mysql" { $DBContext = "mysqlDbContext" }
    "postgresql" { $DBContext = "PostgresDbContext" }
}

#set UseDataSetWithTag to "<db_name>.<db_type>.<env>" in appsettings.json
$AppSettingsPath = "..\AppWebApi\appsettings.json"
$pattern = '"UseDataSetWithTag"\s*:\s*"[^"]*"'
$replacement = '"UseDataSetWithTag": "sql-friends.' + $DatabaseType + '.' + $DeploymentTarget + '"'
(Get-Content -Path $AppSettingsPath) -replace $pattern, $replacement | Set-Content -Path $AppSettingsPath

#set default data user to root in appsettings.json so Users can be seeded
$Content = Get-Content $AppSettingsPath -Raw
$UpdatedContent = $Content -replace '"DefaultDataUser":\s*"[^"]*"', '"DefaultDataUser": "root"'
Set-Content $AppSettingsPath $UpdatedContent

if ($DeploymentTarget -eq "docker") {
    #drop any database
    dotnet ef database drop -f -c $DBContext -p ../DbContext -s ../DbContext
}

#remove any migration
Remove-Item -Recurse -Force ../DbContext/Migrations/$DBContext -ErrorAction SilentlyContinue

#make a full new migration
dotnet ef migrations add miInitial -c $DBContext -p ../DbContext -s ../DbContext -o ../DbContext/Migrations/$DBContext

#update the database from the migration
dotnet ef database update -c $DBContext -p ../DbContext -s ../DbContext

#to initialize the database you need to run the sql scripts
#../DbContext/SqlScripts/<db_type>/initDatabase.sql

