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
$ansiRegex = [regex]'\x1B\[[0-9;]*[A-Za-z]'
$cfg = New-PesterConfiguration
$cfg.Output.NoColor = $true
Invoke-Pester -CI -Configuration $cfg -Path $testPath 2>&1 | ForEach-Object { $ansiRegex.Replace($_, '') }
exit $LASTEXITCODE

