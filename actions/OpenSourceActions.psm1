Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

<#
.SYNOPSIS
  Format a LabVIEW UnitTestReport.xml file (best-effort).

.DESCRIPTION
  Parses the XML report produced by run-unit-tests/RunUnitTests.ps1, prints a simple
  table, and returns an array of PSCustomObjects with key fields. Warnings are emitted
  if the file is missing or malformed; this helper never throws.
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

  $rows = @()
  foreach ($case in $testCases) {
    $name       = $case.GetAttribute('name')
    $className  = $case.GetAttribute('classname')
    $time       = $case.GetAttribute('time')
    $assertions = $case.GetAttribute('assertions')
    $status     = 'Passed'
    if ($case.SelectSingleNode('failure') -ne $null -or $case.SelectSingleNode('error') -ne $null) { $status = 'Failed' }
    elseif ($case.SelectSingleNode('skipped') -ne $null) { $status = 'Skipped' }

    $rows += [pscustomobject]@{
      TestCaseName = $name
      ClassName    = $className
      Status       = $status
      Time         = $time
      Assertions   = $assertions
    }
  }

  try {
    $rows | Format-Table -AutoSize TestCaseName,ClassName,Status,@{Label='Time(s)';Expression={$_.Time}},Assertions | Out-String | Write-Host
  } catch {
    foreach ($r in $rows) {
      Write-Host ("{0}  {1}  {2}  {3}  {4}" -f $r.TestCaseName, $r.ClassName, $r.Status, $r.Time, $r.Assertions)
    }
  }
  return $rows
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
  if ($PSBoundParameters.ContainsKey('gcliPath') -and $gcliPath) {
    $env:PATH = "$gcliPath$([IO.Path]::PathSeparator)$env:PATH"
  }
  $scriptPath = Join-Path (Join-Path $PSScriptRoot 'apply-vipc') 'ApplyVIPC.ps1'
  $args = @{
    MinimumSupportedLVVersion = $MinimumSupportedLVVersion
    VIP_LVVersion             = $VIP_LVVersion
    SupportedBitness          = $SupportedBitness
    RelativePath              = $RelativePath
    VIPCPath                  = $VIPCPath
  }
  if ($DryRun) {
    Write-Information "DryRun: would run $scriptPath with args $(($args | ConvertTo-Json -Compress))"
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
  if ($PSBoundParameters.ContainsKey('gcliPath') -and $gcliPath) {
    $env:PATH = "$gcliPath$([IO.Path]::PathSeparator)$env:PATH"
  }
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
    Write-Information "DryRun: would run $scriptPath with args $(($args | ConvertTo-Json -Compress))"
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
  if ($PSBoundParameters.ContainsKey('gcliPath') -and $gcliPath) {
    $env:PATH = "$gcliPath$([IO.Path]::PathSeparator)$env:PATH"
  }
  $scriptPath = Join-Path (Join-Path $PSScriptRoot 'missing-in-project') 'Invoke-MissingInProjectCLI.ps1'
  $args = @{ LVVersion=$LVVersion; Arch=$Arch; ProjectFile=$ProjectFile }
  if ($DryRun) {
    Write-Information "DryRun: would run $scriptPath with args $(($args | ConvertTo-Json -Compress))"
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
  if ($PSBoundParameters.ContainsKey('gcliPath') -and $gcliPath) {
    $env:PATH = "$gcliPath$([IO.Path]::PathSeparator)$env:PATH"
  }
  $scriptPath = Join-Path (Join-Path $PSScriptRoot 'run-unit-tests') 'RunUnitTests.ps1'
  $args = @{ MinimumSupportedLVVersion=$MinimumSupportedLVVersion; SupportedBitness=$SupportedBitness }
  if ($DryRun) {
    Write-Information "DryRun: would run $scriptPath with args $(($args | ConvertTo-Json -Compress))"
    return 0
  }
  & $scriptPath @args
  $code = if ($LASTEXITCODE -is [int]) { [int]$LASTEXITCODE } else { if ($?) { 0 } else { 1 } }
  # Best-effort report formatting; never changes the exit code
  $reportPath = Join-Path (Split-Path $scriptPath -Parent) 'UnitTestReport.xml'
  try { Format-UnitTestReport -ReportPath $reportPath | Out-Null } catch { Write-Warning $_.Exception.Message }
  return $code
}
