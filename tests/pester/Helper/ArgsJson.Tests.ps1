#requires -Version 7.0
$env:PSModulePath = (Join-Path $PSScriptRoot 'Modules') + [System.IO.Path]::PathSeparator + $env:PSModulePath
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Import-Module (Join-Path $PSScriptRoot 'ArgsJson.psm1')

Describe 'Get-LabVIEWIconEditorArgsJson' {
    It 'throws when LABVIEW_ICON_EDITOR_PATH is invalid' {
        $orig = $env:LABVIEW_ICON_EDITOR_PATH
        try {
            $env:LABVIEW_ICON_EDITOR_PATH = Join-Path $PSScriptRoot 'NoSuchDir'
            $err = { Get-LabVIEWIconEditorArgsJson } | Should -Throw -PassThru
            $err.Exception.Message | Should -Match 'Clone.*LABVIEW_ICON_EDITOR_PATH'
        }
        finally {
            if ($null -eq $orig) {
                Remove-Item Env:LABVIEW_ICON_EDITOR_PATH -ErrorAction SilentlyContinue
            } else {
                $env:LABVIEW_ICON_EDITOR_PATH = $orig
            }
        }
    }
}

