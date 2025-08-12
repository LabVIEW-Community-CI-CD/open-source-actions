Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Add-GCliToPath {
  [CmdletBinding()]
  param([string]$PathToAdd)
  if ($PSBoundParameters.ContainsKey('PathToAdd') -and $PathToAdd) {
    $env:PATH = "$PathToAdd$([IO.Path]::PathSeparator)$env:PATH"
  }
}

function ConvertTo-SafeJson {
  [CmdletBinding()]
  param([hashtable]$Args)
  $masked = @{}
  foreach ($k in $Args.Keys) {
    $v = $Args[$k]
    if ($k -match '(?i)(token|secret|password|key)') { $v = '***' }
    $masked[$k] = $v
  }
  return ($masked | ConvertTo-Json -Compress)
}

<#
.SYNOPSIS
  Pretty-prints a LabVIEW UnitTestReport.xml and returns result objects.
#>
function Format-UnitTestReport {
  [CmdletBinding()]
  param([Parameter(Mandatory)][string]$ReportPath)

  if (-not (Test-Path -LiteralPath $ReportPath)) {
    Write-Warning "Report file '$ReportPath' not found."
    return @()
  }
  try {
    [xml]$xmlDoc = Get-Content -LiteralPath $ReportPath -ErrorAction Stop
  } catch {
    Write-Warning "Could not parse XML: $($_.Exception.Message)"
    return @()
  }

  $testCases = $xmlDoc.SelectNodes('//testcase')
  if (-not $testCases -or $testCases.Count -eq 0) {
    Write-Warning 'No <testcase> entries found in report.'
    return @()
  }

  $col1='TestCaseName'; $col2='ClassName'; $col3='Status'; $col4='Time(s)'; $col5='Assertions'
  $maxName=$col1.Length; $maxClass=$col2.Length; $maxStatus=$col3.Length; $maxTime=$col4.Length; $maxAssert=$col5.Length
  $results=@()

  foreach ($case in $testCases) {
    $name       = $case.GetAttribute('name')
    $className  = $case.GetAttribute('classname')
    $status     = $case.GetAttribute('status')
    $time       = $case.GetAttribute('time')
    $assertions = $case.GetAttribute('assertions')
    if ([string]::IsNullOrWhiteSpace($status)) { $status = 'Skipped' }

    if ($name.Length       -gt $maxName)   { $maxName   = $name.Length }
    if ($className.Length  -gt $maxClass)  { $maxClass  = $className.Length }
    if ($status.Length     -gt $maxStatus) { $maxStatus = $status.Length }
    if ($time.Length       -gt $maxTime)   { $maxTime   = $time.Length }
    if ($assertions.Length -gt $maxAssert) { $maxAssert = $assertions.Length }

    $results += [pscustomobject]@{
      TestCaseName = $name
      ClassName    = $className
      Status       = $status
      Time         = $time
      Assertions   = $assertions
    }
  }

  $header = ($col1.PadRight($maxName) + '  ' + $col2.PadRight($maxClass) + '  ' + $col3.PadRight($maxStatus) + '  ' + $col4.PadRight($maxTime) + '  ' + $col5.PadRight($maxAssert))
  Write-Host $header
  foreach ($res in $results) {
    $line = ($res.TestCaseName.PadRight($maxName) + '  ' +
             $res.ClassName.PadRight($maxClass)   + '  ' +
             $res.Status.PadRight($maxStatus)     + '  ' +
             $res.Time.PadRight($maxTime)         + '  ' +
             $res.Assertions.PadRight($maxAssert))
    switch ($res.Status) {
      'Passed'  { Write-Host $line -ForegroundColor Green }
      'Skipped' { Write-Host $line -ForegroundColor Yellow }
      default   { Write-Host $line -ForegroundColor Red }
    }
  }
  return $results
}

function InvokeApplyVIPC {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory)][string]$MinimumSupportedLVVersion,
    [Parameter(Mandatory)][string]$VIP_LVVersion,
    [Parameter(Mandatory)][string]$SupportedBitness,
    [Parameter(Mandatory)][string]$RelativePath,
    [Parameter(Mandatory)][string]$VIPCPath,
    [string]$LogLevel = 'INFO',
    [switch]$DryRun,
    [string]$gcliPath
  )
  Write-Information "ApplyVIPC: DryRun=$DryRun"
  Add-GCliToPath -PathToAdd $gcliPath

  $scriptPath = Join-Path (Join-Path $PSScriptRoot 'apply-vipc') 'ApplyVIPC.ps1'
  $args = @{
    MinimumSupportedLVVersion = $MinimumSupportedLVVersion
    VIP_LVVersion             = $VIP_LVVersion
    SupportedBitness          = $SupportedBitness
    RelativePath              = $RelativePath
    VIPCPath                  = $VIPCPath
  }

  if ($DryRun) {
    Write-Information "DryRun: would run $scriptPath with args $(ConvertTo-SafeJson $args)"
    return 0
  }

  & $scriptPath @args
  $code = if ($LASTEXITCODE -is [int]) { [int]$LASTEXITCODE } else { if ($?) { 0 } else { 1 } }
  return $code
}

function InvokeBuildLvlibp {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory)][string]$MinimumSupportedLVVersion,
    [Parameter(Mandatory)][string]$SupportedBitness,
    [Parameter(Mandatory)][string]$RelativePath,
    [Parameter(Mandatory)][string]$LabVIEW_Project,
    [Parameter(Mandatory)][string]$Build_Spec,
    [Parameter(Mandatory)][int]$Major,
    [Parameter(Mandatory)][int]$Minor,
    [Parameter(Mandatory)][int]$Patch,
    [Parameter(Mandatory)][int]$Build,
    [Parameter(Mandatory)][string]$Commit,
    [string]$LogLevel = 'INFO',
    [switch]$DryRun,
    [string]$gcliPath
  )
  Write-Information "BuildLvlibp: DryRun=$DryRun"
  Add-GCliToPath -PathToAdd $gcliPath

  $scriptPath = Join-Path (Join-Path $PSScriptRoot 'build-lvlibp') 'Build_lvlibp.ps1'
  $args = @{
    MinimumSupportedLVVersion = $MinimumSupportedLVVersion
    SupportedBitness          = $SupportedBitness
    RelativePath              = $RelativePath
    LabVIEW_Project           = $LabVIEW_Project
    Build_Spec                = $Build_Spec
    Major                     = $Major
    Minor                     = $Minor
    Patch                     = $Patch
    Build                     = $Build
    Commit                    = $Commit
  }

  if ($DryRun) {
    Write-Information "DryRun: would run $scriptPath with args $(ConvertTo-SafeJson $args)"
    return 0
  }

  & $scriptPath @args
  $code = if ($LASTEXITCODE -is [int]) { [int]$LASTEXITCODE } else { if ($?) { 0 } else { 1 } }
  return $code
}

function InvokeMissingInProject {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory)][string]$LVVersion,
    [Parameter(Mandatory)][ValidateSet('32','64')][string]$Arch,
    [Parameter(Mandatory)][string]$ProjectFile,
    [string]$LogLevel = 'INFO',
    [switch]$DryRun,
    [string]$gcliPath
  )
  Write-Information "MissingInProject: DryRun=$DryRun"
  Add-GCliToPath -PathToAdd $gcliPath

  $scriptPath = Join-Path (Join-Path $PSScriptRoot 'missing-in-project') 'Invoke-MissingInProjectCLI.ps1'
  $args = @{ LVVersion=$LVVersion; Arch=$Arch; ProjectFile=$ProjectFile }

  if ($DryRun) {
    Write-Information "DryRun: would run $scriptPath with args $(ConvertTo-SafeJson $args)"
    return 0
  }

  & $scriptPath @args
  $code = if ($LASTEXITCODE -is [int]) { [int]$LASTEXITCODE } else { if ($?) { 0 } else { 1 } }
  return $code
}

function InvokeRunUnitTests {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory)][string]$MinimumSupportedLVVersion,
    [Parameter(Mandatory)][ValidateSet('32','64')][string]$SupportedBitness,
    [string]$LogLevel = 'INFO',
    [switch]$DryRun,
    [string]$gcliPath
  )
  Write-Information "RunUnitTests: DryRun=$DryRun"
  Add-GCliToPath -PathToAdd $gcliPath

  $scriptPath = Join-Path (Join-Path $PSScriptRoot 'run-unit-tests') 'RunUnitTests.ps1'
  $args = @{ MinimumSupportedLVVersion=$MinimumSupportedLVVersion; SupportedBitness=$SupportedBitness }

  if ($DryRun) {
    Write-Information "DryRun: would run $scriptPath with args $(ConvertTo-SafeJson $args)"
    return 0
  }

  & $scriptPath @args
  $code = if ($LASTEXITCODE -is [int]) { [int]$LASTEXITCODE } else { if ($?) { 0 } else { 1 } }

  # Try to pretty-print the unit test report without changing exit semantics
  $candidatePaths = @(
    'UnitTestReport.xml',
    Join-Path (Split-Path $scriptPath -Parent) 'UnitTestReport.xml'
  )
  foreach ($rp in $candidatePaths) {
    if (Test-Path -LiteralPath $rp) {
      try { Format-UnitTestReport -ReportPath $rp | Out-Null } catch { Write-Warning $_.Exception.Message }
      break
    }
  }

  return $code  # 0=success; 2=test failures; 3=g-cli error (preserved)
}