# az-access-secrets.ps1
# Usage:
# .\az-access-secrets.ps1 {az-resource-params path} [app|sql|usrsec] [{json-key}|file|path|fname|cstring|cstringfile] [csproj-path-for-usrsec]

param (
    [Parameter(Mandatory = $true)]
    [string]$SecretsPath,
    [Parameter(Mandatory = $true)]
    [string]$Type,
    [string]$Key,
    [string]$CsProjPath
)

if (-not $SecretsPath -or -not $Type -or -not $Key) {
    exit 1
}

# Default locations
$AzureSecretPath = Join-Path (Resolve-Path $SecretsPath) "az-secrets"
$AppFile = Join-Path $AzureSecretPath "az-app-access.json"
$SQLFile = Join-Path $AzureSecretPath "az-sql-access.json"
$CStringFile = Join-Path $AzureSecretPath "az-sql-con-string.json"

$UsrSecPath = ./user-secret-path.ps1

if ($Type -eq "app") {
    $JsonFile = $AppFile
} elseif ($Type -eq "sql") {
    $JsonFile = $SQLFile
} elseif ($Type -eq "usrsec") {
    if (-not $CsProjPath) {
        throw "Path to csproj with UserSecretsId not provided"
    }
    # Extract UserSecretsId from csproj
    $UsrSecId = Select-String -Path $CsProjPath -Pattern '<UserSecretsId>(.*?)</UserSecretsId>' | ForEach-Object {
        $_.Matches[0].Groups[1].Value
    }
    #$UsrSecPath = & ..\cli-ps1\az-access.ps1 $SecretsPath usrSecPath
    if (-not $UsrSecPath -or -not $UsrSecId) {
        throw "Failed to retrieve UserSecretsId or path to csproj"
    }
    $JsonFile = Join-Path $UsrSecPath "$UsrSecId\secrets.json"
} else {
    throw "Invalid Type: $Type. Use 'app', 'sql', or 'usrsec'."
}

if ($Key) {
    if ($Key -in @("file", "path", "fname", "cstring", "cstringfile")) {
        switch ($Key) {
            "file"      { Write-Output $JsonFile; exit 0 }
            "path"      { Write-Output (Split-Path $JsonFile -Parent); exit 0 }
            "fname"     { Write-Output (Split-Path $JsonFile -Leaf); exit 0 }
            "cstring"   { Get-Content $CStringFile; exit 0 }
            "cstringfile" { Write-Output $CStringFile; exit 0 }
        }
    } else {
        $JsonContent = Get-Content $JsonFile -Raw | ConvertFrom-Json
        if ($JsonContent.PSObject.Properties.Name -contains $Key) {
            Write-Output $JsonContent.$Key
            exit
        }
    }
}

# Exit with error to catch in the test script
throw "Failed to retrieve $Key"
