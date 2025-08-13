#requires -Version 7.0
# Verify that each action script exists in the expected location.

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..' '..')).Path
$scriptRoot = Join-Path $repoRoot 'scripts'

$cases = @(
    @{ Name = 'add-token-to-labview';      Path = Join-Path $scriptRoot 'add-token-to-labview/AddTokenToLabVIEW.ps1' },
    @{ Name = 'apply-vipc';               Path = Join-Path $scriptRoot 'apply-vipc/ApplyVIPC.ps1' },
    @{ Name = 'build';                    Path = Join-Path $scriptRoot 'build/Build.ps1' },
    @{ Name = 'build-lvlibp';             Path = Join-Path $scriptRoot 'build-lvlibp/Build_lvlibp.ps1' },
    @{ Name = 'build-vi-package';         Path = Join-Path $scriptRoot 'build-vi-package/build_vip.ps1' },
    @{ Name = 'close-labview';            Path = Join-Path $scriptRoot 'close-labview/Close_LabVIEW.ps1' },
    @{ Name = 'generate-release-notes';   Path = Join-Path $scriptRoot 'generate-release-notes/GenerateReleaseNotes.ps1' },
    @{ Name = 'missing-in-project';       Path = Join-Path $scriptRoot 'missing-in-project/Invoke-MissingInProjectCLI.ps1' },
    @{ Name = 'modify-vipb-display-info'; Path = Join-Path $scriptRoot 'modify-vipb-display-info/ModifyVIPBDisplayInfo.ps1' },
    @{ Name = 'prepare-labview-source';   Path = Join-Path $scriptRoot 'prepare-labview-source/Prepare_LabVIEW_source.ps1' },
    @{ Name = 'rename-file';              Path = Join-Path $scriptRoot 'rename-file/Rename-file.ps1' },
    @{ Name = 'restore-setup-lv-source';  Path = Join-Path $scriptRoot 'restore-setup-lv-source/RestoreSetupLVSource.ps1' },
    @{ Name = 'revert-development-mode';  Path = Join-Path $scriptRoot 'revert-development-mode/RevertDevelopmentMode.ps1' },
    @{ Name = 'run-unit-tests';           Path = Join-Path $scriptRoot 'run-unit-tests/RunUnitTests.ps1' },
    @{ Name = 'set-development-mode';     Path = Join-Path $scriptRoot 'set-development-mode/Set_Development_Mode.ps1' }
)

Describe 'Action script paths' {
    It 'has script for <Name>' -TestCases $cases {
        param($Name, $Path)
        Test-Path $Path | Should -BeTrue
    }
}

