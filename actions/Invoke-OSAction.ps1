param(
  [Parameter(Position=0)] [string] $ActionName,
  [Parameter()] [string] $ArgsJson = '{}',
  [Parameter()] [string] $WorkingDirectory,
  [Parameter()] [ValidateSet('ERROR','WARN','INFO','DEBUG')] [string] $LogLevel = 'INFO',
  [switch] $DryRun,
  [switch] $ListActions,
  [string] $Describe
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Import-Module (Join-Path $PSScriptRoot 'OpenSourceActions.psm1') -Force

# Ordered registry of actions (lowercase keys) → adapter functions
$Registry = [ordered]@{
  'apply-vipc'         = 'InvokeApplyVIPC'
  'build-lvlibp'       = 'InvokeBuildLvlibp'
  'missing-in-project' = 'InvokeMissingInProject'
  'run-unit-tests'     = 'InvokeRunUnitTests'
}

function Set-LogLevel {
  [CmdletBinding()]
  param([string]$Level)
  switch ($Level.ToUpperInvariant()) {
    'ERROR' { $InformationPreference='SilentlyContinue'; $VerbosePreference='SilentlyContinue' }
    'WARN'  { $InformationPreference='SilentlyContinue'; $VerbosePreference='SilentlyContinue' }
    'INFO'  { $InformationPreference='Continue';         $VerbosePreference='SilentlyContinue' }
    'DEBUG' { $InformationPreference='Continue';         $VerbosePreference='Continue' }
    default { $InformationPreference='Continue';         $VerbosePreference='SilentlyContinue' }
  }
}

function Show-List {
  Write-Host 'Available actions:'
  $Registry.Keys | Sort-Object | ForEach-Object { Write-Host " - $_" }
}

function Show-Description {
  [CmdletBinding()]
  param([Parameter(Mandatory)][string]$Name)
  $key = $Name.ToLowerInvariant()
  if (-not $Registry.ContainsKey($key)) { throw "Unknown action '$Name'" }
  $funcName = $Registry[$key]
  $cmd = Get-Command $funcName -ErrorAction Stop
  Write-Host "$key parameters:"
  foreach ($p in $cmd.Parameters.Values) {
    $req = if ($p.IsMandatory) { '(required)' } else { '(optional)' }
    $def = if ($null -ne $p.DefaultValue) { " [default: $($p.DefaultValue)]" } else { '' }
    Write-Host " - $($p.Name): $($p.ParameterType.Name) $req$def"
  }
}

try {
  # Discovery first (no need to parse JSON or push location)
  if ($ListActions) { Show-List; exit 0 }
  if ($Describe)    { Show-Description -Name $Describe; exit 0 }

  if (-not $ActionName) { throw 'ActionName is required unless using -ListActions or -Describe' }

  $key = $ActionName.ToLowerInvariant()
  if (-not $Registry.ContainsKey($key)) { throw "Unknown ActionName '$ActionName'. Use -ListActions to see options." }
  $funcName = $Registry[$key]

  # Parse JSON → case-insensitive hashtable
  $argsHash = @{}
  if ($ArgsJson -and $ArgsJson.Trim()) {
    try {
      $argsHash = ConvertFrom-Json -InputObject $ArgsJson -AsHashtable -ErrorAction Stop
    } catch {
      throw "ArgsJson is not valid JSON: $($_.Exception.Message)"
    }
  }

  # Filter unknown keys against adapter parameters to avoid splat errors
  $funcParams = (Get-Command $funcName -ErrorAction Stop).Parameters.Keys
  $filteredArgs = @{}
  foreach ($k in @($argsHash.Keys)) {
    if ($funcParams -contains $k) {
      $filteredArgs[$k] = $argsHash[$k]
    } else {
      Write-Warning "Ignored unknown argument '$k' for action '$ActionName'"
    }
  }

  # Inject dispatcher-owned params
  if ($DryRun)   { $filteredArgs['DryRun']  = $true }
  if ($LogLevel) { $filteredArgs['LogLevel'] = $LogLevel }

  Set-LogLevel -Level $LogLevel

  if ($WorkingDirectory) { Push-Location -Path $WorkingDirectory }
  try {
    $result = & $funcName @filteredArgs
    $exitCode = if ($result -is [int]) { [int]$result }
                elseif ($LASTEXITCODE -is [int]) { [int]$LASTEXITCODE }
                else { 0 }
  } catch {
    Write-Error $_.Exception.Message
    $exitCode = 1
  } finally {
    if ($WorkingDirectory) { Pop-Location }
  }
  exit $exitCode
} catch {
  Write-Error $_.Exception.Message
  exit 1
}
