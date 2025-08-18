# ExecWithThrow.ps1
# Helper function to run a command and throw if it fails
function ExecWithThrow {
    param (
        [string]$Command,
        [switch]$NoThrow
    )
    $result =  Invoke-Expression $Command
    if (-not $NoThrow -and $LASTEXITCODE -ne 0) {
        throw "`nError: Command failed - $($Command.ToString())"
    }
    return $result
}
