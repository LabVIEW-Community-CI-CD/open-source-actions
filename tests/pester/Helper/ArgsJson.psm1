function Get-LabVIEWIconEditorArgsJson {
    [OutputType([pscustomobject])]
    param()

    $repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..' '..' '..')).Path
    if ($env:LABVIEW_ICON_EDITOR_PATH) {
        $workingDir = $env:LABVIEW_ICON_EDITOR_PATH
    } elseif ($IsWindows) {
        $workingDir = Join-Path $repoRoot 'labview-icon-editor'
    } elseif ($IsLinux) {
        $workingDir = Join-Path $repoRoot 'labview-icon-editor'
    } elseif ($IsMacOS) {
        $workingDir = Join-Path $repoRoot 'labview-icon-editor'
    } else {
        throw 'Unsupported platform'
    }

    if (-not (Test-Path -Path $workingDir)) {
        throw 'labview-icon-editor repository not found. Clone https://github.com/LabVIEW-Community-CI-CD/labview-icon-editor or set LABVIEW_ICON_EDITOR_PATH to its location.'
    }

    $args = @{
        MinimumSupportedLVVersion = '2021'
        SupportedBitness          = '64'
        RelativePath              = '.'
    }

    return [pscustomobject]@{
        ArgsJson        = ($args | ConvertTo-Json -Compress)
        WorkingDirectory = $workingDir
    }
}

Export-ModuleMember -Function Get-LabVIEWIconEditorArgsJson
