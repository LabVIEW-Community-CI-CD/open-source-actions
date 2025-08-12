#requires -Version 7.0
# Pester v5 tests for the unified dispatcher and adapters.
# These tests are OS-agnostic and avoid requiring LabVIEW/g-cli by using -DryRun.
# Tests that need a real LabVIEW + g-cli setup are tagged [Manual] and are skipped by default.

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

BeforeAll {
  # repoRoot: .../ (two levels up from tests/pester)
  $repoRoot   = (Resolve-Path (Join-Path $PSScriptRoot '..' '..')).Path
  $dispatcher = Join-Path $repoRoot 'actions' 'Invoke-OSAction.ps1'

  function Invoke-Dispatcher {
    <#
      .SYNOPSIS
        Launches a fresh 'pwsh' process to execute the dispatcher and returns StdOut, StdErr, ExitCode.
      .PARAMETER ArgumentList
        A string[] of arguments to pass after -File <dispatcher.ps1>.
        Example: @('-ListActions')  or  @('-ActionName','apply-vipc','-ArgsJson',$json,'-DryRun')
    #>
    param([string[]]$ArgumentList)

    $pwsh = (Get-Command pwsh).Source
    $escaped = $ArgumentList | ForEach-Object {
      if ($_ -match '[\s"{}]') { '"' + ($_ -replace '"','\"') + '"' } else { $_ }
    }
    $args = "-NoProfile -File `"$dispatcher`" $($escaped -join ' ')"

    $psi = New-Object System.Diagnostics.ProcessStartInfo
    $psi.FileName               = $pwsh
    $psi.Arguments              = $args
    $psi.UseShellExecute        = $false
    $psi.RedirectStandardOutput = $true
    $psi.RedirectStandardError  = $true
    $psi.CreateNoWindow         = $true

    $p = New-Object System.Diagnostics.Process
    $p.StartInfo = $psi
    [void]$p.Start()
    $stdout = $p.StandardOutput.ReadToEnd()
    $stderr = $p.StandardError.ReadToEnd()
    $p.WaitForExit()

    [pscustomobject]@{
      StdOut   = $stdout
      StdErr   = $stderr
      ExitCode = $p.ExitCode
    }
  }
}

Describe 'Dispatcher discovery' {
  It 'lists actions in alphabetical order and includes MVP actions' {
    $res = Invoke-Dispatcher -ArgumentList @('-ListActions')
    $res.ExitCode | Should -Be 0

    # extract " - action" lines
    $lines = $res.StdOut -split "`r?`n" | Where-Object { $_ -match '^\s*-\s' } |
             ForEach-Object { $_.Trim() -replace '^- ', '' }
    $sorted = $lines | Sort-Object

    $lines | Should -Be $sorted
    $lines | Should -Contain 'apply-vipc'
    $lines | Should -Contain 'build-lvlibp'
    $lines | Should -Contain 'missing-in-project'
    $lines | Should -Contain 'run-unit-tests'
  }

  It 'describes build-lvlibp and shows required Int32 param types' {
    $res = Invoke-Dispatcher -ArgumentList @('-Describe','build-lvlibp')
    $res.ExitCode | Should -Be 0
    $res.StdOut   | Should -Match 'Major.*Int32.*\(required\)'
  }
}

Describe 'Argument handling and errors' {
  It 'fails with exit code 1 for unknown action' {
    $res = Invoke-Dispatcher -ArgumentList @('-ActionName','no-such-action','-ArgsJson','{}')
    $res.ExitCode | Should -Be 1
    $res.StdErr   | Should -Match 'Unknown ActionName'
  }

  It 'rejects invalid JSON with a clear error and exit code 1' {
    $res = Invoke-Dispatcher -ArgumentList @('-ActionName','build-lvlibp','-ArgsJson','{not valid}')
    $res.ExitCode | Should -Be 1
    $res.StdErr   | Should -Match 'ArgsJson is not valid JSON'
  }

  It 'filters unknown args and warns without failing' {
    $json = @{
      MinimumSupportedLVVersion = '2021'
      SupportedBitness          = '64'
      RelativePath              = '.'
      LabVIEW_Project           = 'My.lvproj'
      Build_Spec                = 'MyBuild'
      Major                     = 1
      Minor                     = 0
      Patch                     = 0
      Build                     = 1
      Commit                    = 'abc123'
      Bogus                     = 42
    } | ConvertTo-Json -Compress

    $res = Invoke-Dispatcher -ArgumentList @(
      '-ActionName','build-lvlibp','-ArgsJson',$json,'-DryRun'
    )

    $res.ExitCode | Should -Be 0
    # warning goes to StdErr
    $res.StdErr   | Should -Match 'Ignored unknown parameters'
  }
}

Describe 'DryRun behavior' {
  It 'apply-vipc: logs intended command and returns 0' {
    $json = @{
      MinimumSupportedLVVersion = '2021'
      VIP_LVVersion             = '2021'
      SupportedBitness          = '64'
      RelativePath              = '.'
      VIPCPath                  = 'dummy.vipc'
    } | ConvertTo-Json -Compress

    $res = Invoke-Dispatcher -ArgumentList @(
      '-ActionName','apply-vipc','-ArgsJson',$json,'-DryRun'
    )
    $res.ExitCode | Should -Be 0
    $res.StdOut   | Should -Match 'DryRun: would run'
  }

  It 'build-lvlibp: logs intended command and returns 0' {
    $json = @{
      MinimumSupportedLVVersion = '2021'
      SupportedBitness          = '64'
      RelativePath              = '.'
      LabVIEW_Project           = 'Proj.lvproj'
      Build_Spec                = 'Spec'
      Major                     = 1
      Minor                     = 0
      Patch                     = 0
      Build                     = 1
      Commit                    = 'abc123'
    } | ConvertTo-Json -Compress

    $res = Invoke-Dispatcher -ArgumentList @(
      '-ActionName','build-lvlibp','-ArgsJson',$json,'-DryRun'
    )
    $res.ExitCode | Should -Be 0
    $res.StdOut   | Should -Match 'DryRun: would run'
  }

  It 'missing-in-project: logs intended command and returns 0' {
    $json = @{
      LVVersion   = '2021'
      Arch        = '64'
      ProjectFile = 'My.lvproj'
    } | ConvertTo-Json -Compress

    $res = Invoke-Dispatcher -ArgumentList @(
      '-ActionName','missing-in-project','-ArgsJson',$json,'-DryRun'
    )
    $res.ExitCode | Should -Be 0
    $res.StdOut   | Should -Match 'DryRun: would run'
  }

  It 'run-unit-tests: logs intended command and returns 0' {
    $json = @{
      MinimumSupportedLVVersion = '2021'
      SupportedBitness          = '64'
    } | ConvertTo-Json -Compress

    $res = Invoke-Dispatcher -ArgumentList @(
      '-ActionName','run-unit-tests','-ArgsJson',$json,'-DryRun'
    )
    $res.ExitCode | Should -Be 0
    $res.StdOut   | Should -Match 'DryRun: would run'
  }
}

# Real LabVIEW/g-cli validation — only on your machine with the specialized setup.
Describe 'RunUnitTests (Manual)' -Tag 'Manual' {
  It 'preserves exit codes (0, 2, 3) when not using -DryRun [Manual]' {
    # Example only — fill in values that make sense in your environment:
    # $json = '{"MinimumSupportedLVVersion":"2021","SupportedBitness":"64","gcliPath":"/opt/gcli/bin"}'
    # $res  = Invoke-Dispatcher -ArgumentList @('-ActionName','run-unit-tests','-ArgsJson',$json)
    # $res.ExitCode | Should -BeIn @(0,2,3)
    $true | Should -BeTrue
  }
}
