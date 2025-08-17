#requires -Version 7.0
$env:PSModulePath = (Join-Path $PSScriptRoot 'Modules') + [System.IO.Path]::PathSeparator + $env:PSModulePath
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Describe 'RunPesterTests.SelfHosted.Workflow' {
    $meta = @{
        requirement = 'REQ-034'
        Owner       = 'DevTools'
        Evidence    = 'tests/pester/RunPesterTests.SelfHosted.Workflow.Tests.ps1'
    }

    It 'returns non-zero exit code when tests fail' -Tag 'REQ-034' {
        $repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..' '..')).Path
        $dispatcher = Join-Path $repoRoot 'actions' 'Invoke-OSAction.ps1'
        $fixture = Join-Path $repoRoot 'tests/pester/Fixtures/run-pester-tests'
        pwsh -NoProfile -File $dispatcher -ActionName run-pester-tests -ArgsYaml "@{ WorkingDirectory = '$fixture' }" *> $null
        $LASTEXITCODE | Should -Not -Be 0
    }

    It 'returns zero exit code when all tests pass' -Tag 'REQ-034' {
        $repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..' '..')).Path
        $dispatcher = Join-Path $repoRoot 'actions' 'Invoke-OSAction.ps1'
        $fixture = Join-Path $repoRoot 'tests/pester/Fixtures/run-pester-tests'
        $temp = Join-Path ([System.IO.Path]::GetTempPath()) ([System.IO.Path]::GetRandomFileName())
        Copy-Item -Recurse $fixture $temp
        Remove-Item (Join-Path $temp 'tests/pester/Failing.Tests.ps1')
        pwsh -NoProfile -File $dispatcher -ActionName run-pester-tests -ArgsYaml "@{ WorkingDirectory = '$temp' }" *> $null
        $LASTEXITCODE | Should -Be 0
    }

    It 'prints dry-run information' -Tag 'REQ-034' {
        $repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..' '..')).Path
        $dispatcher = Join-Path $repoRoot 'actions' 'Invoke-OSAction.ps1'
        $fixture = Join-Path $repoRoot 'tests/pester/Fixtures/run-pester-tests'
        $info = pwsh -NoProfile -File $dispatcher -ActionName run-pester-tests -ArgsYaml "@{ WorkingDirectory = '$fixture' }" -DryRun 6>&1 | Out-String
        $info | Should -Match 'DryRun: & .*RunPesterTests.ps1'
    }
}
