<#
.SYNOPSIS
    Run Pester tests located in a repository.

.DESCRIPTION
    Invokes Pester in CI mode against the tests under the provided working directory.

.PARAMETER WorkingDirectory
    Path to the repository containing tests under `tests/pester`.

.NOTES
    PowerShell 7.5+ assumed for cross-platform support.
#>

param(
    [Parameter(Mandatory=$true)]
    [string]
    $WorkingDirectory
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$testPath = Join-Path $WorkingDirectory 'tests/pester'
Invoke-Pester -CI -Path $testPath
exit $LASTEXITCODE

