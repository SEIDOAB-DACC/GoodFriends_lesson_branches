# az-access.ps1
# Usage: .\az-access.ps1 {az-resource-params path} [{json-key}|file|path|fname]

param (
    [Parameter(Mandatory = $true)]
    [string]$AccessPath,
    [Parameter(Mandatory = $true)]
    [string]$Key
)

# Resolve absolute path and set JSON file path
$AbsPath = Resolve-Path $AccessPath
$AzAccessPath = Join-Path $AbsPath "az-access"
$JsonFile = Join-Path $AzAccessPath "az-settings.json"
$TemplateFile = Join-Path $AzAccessPath "az-settings-template.json"

if ($Key) {
    $JsonContent = Get-Content $JsonFile -Raw | ConvertFrom-Json

    if ($JsonContent.PSObject.Properties.Name -contains $Key) {
        Write-Output $JsonContent.$Key
        exit
    } elseif ($Key -eq "file") {
        Write-Output $JsonFile
        exit
    } elseif ($Key -eq "template") {
        Write-Output $TemplateFile
        exit
    } elseif ($Key -eq "path") {
        Write-Output (Split-Path $JsonFile -Parent)
        exit
    } elseif ($Key -eq "fname") {
        Write-Output (Split-Path $JsonFile -Leaf)
        exit
    }
}

# Exit with error to catch in the test script
throw "Key '$Key' not in settings"