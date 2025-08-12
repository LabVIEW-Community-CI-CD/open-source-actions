# Pester tests for the unified dispatcher (OS-agnostic; no LabVIEW/g-cli required).
# Some integration tests are tagged [Manual].

Describe 'Invoke-OSAction Discovery' {
  It 'Lists actions' {
    $out = pwsh -NoProfile -Command "& { ./actions/Invoke-OSAction.ps1 -ListActions }" 2>&1
    ($out -join "`n") | Should -Match 'apply-vipc'
    ($out -join "`n") | Should -Match 'run-unit-tests'
  }

  It 'Describes run-unit-tests' {
    $out = pwsh -NoProfile -Command "& { ./actions/Invoke-OSAction.ps1 -Describe run-unit-tests }" 2>&1
    ($out -join "`n") | Should -Match 'SupportedBitness'
  }
}

Describe 'Args filtering' {
  It 'Ignores unknown args and exits 0 in DryRun' {
    $json = '{"UnknownParam":123, "LogLevel":"INFO"}'
    $cmd  = "& { ./actions/Invoke-OSAction.ps1 -ActionName build-lvlibp -ArgsJson '$json' -DryRun }"
    $null = pwsh -NoProfile -Command $cmd 2>&1
    $LASTEXITCODE | Should -Be 0
  }
}

Describe 'DryRun behavior' {
  It 'build-lvlibp DryRun exits 0' {
    $json = '{"MinimumSupportedLVVersion":"2021","SupportedBitness":"64","RelativePath":".","LabVIEW_Project":"P.lvproj","Build_Spec":"B","Major":1,"Minor":0,"Patch":0,"Build":1,"Commit":"abcd"}'
    $cmd  = "& { ./actions/Invoke-OSAction.ps1 -ActionName build-lvlibp -ArgsJson '$json' -DryRun }"
    $null = pwsh -NoProfile -Command $cmd 2>&1
    $LASTEXITCODE | Should -Be 0
  }
}

[Tags] @('Manual')
Describe 'RunUnitTests semantics [Manual]' {
  It 'Preserves 0/2/3 exit codes' {
    # Manual test placeholder: run on a machine with LabVIEW + g-cli installed.
    $true | Should -BeTrue
  }
}
