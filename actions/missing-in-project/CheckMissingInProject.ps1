param(
    [string]$LVVersion,
    [string]$Arch,
    [string]$ProjectFile
)
$script = Join-Path $PSScriptRoot '..' '..' 'scripts' 'missing-in-project' 'Invoke-MissingInProjectCLI.ps1'
& $script @PSBoundParameters
