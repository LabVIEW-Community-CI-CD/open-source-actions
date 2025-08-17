<#
.SYNOPSIS
    Run Pester tests and output a color-coded table of results.

.DESCRIPTION
    Invokes Pester tests located under tests/pester and prints a table of
    Describe, Name, Result, Duration, and Data for each test. The table uses
    green/yellow/red coloring for pass/skip/fail and exits with 2 if any test
    fails, otherwise 0.
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repoRoot  = (Resolve-Path (Join-Path $PSScriptRoot '..' '..')).Path
$pesterDir = Join-Path $repoRoot 'tests' 'pester'

# Run Pester and capture results
$pesterResult = Invoke-Pester -Path $pesterDir -PassThru

# Export JUnit report with requirement properties derived from tags
$junitPath = Join-Path $repoRoot 'pester-junit.xml'
$pesterResult | Export-JUnitReport -Path $junitPath
[xml]$junitXml = Get-Content -Path $junitPath
foreach ($t in $pesterResult.Tests) {
    $name = ($t.Path -join '.')
    $case = $junitXml.SelectSingleNode("//testcase[@name='${name}']")
    if (-not $case) { continue }
    foreach ($tag in @($t.Tag)) {
        if ($tag -match '^REQ-\d+$') {
            $props = $case.SelectSingleNode('properties')
            if (-not $props) {
                $props = $junitXml.CreateElement('properties')
                $null = $case.AppendChild($props)
            }
            $prop = $junitXml.CreateElement('property')
            $prop.SetAttribute('name', 'requirement')
            $prop.SetAttribute('value', $tag.ToUpper())
            $null = $props.AppendChild($prop)
        }
    }
}
$junitXml.Save($junitPath)
$tests = $null
if ($pesterResult.PSObject.Properties['TestResult']) {
    $tests = $pesterResult.TestResult
}
if (-not $tests -and $pesterResult.PSObject.Properties['Tests']) {
    $tests = $pesterResult.Tests
}
$tests = @($tests)  # ensure array

$col1 = 'Describe'; $col2 = 'Name'; $col3 = 'Result'; $col4 = 'Duration'; $col5 = 'Data'
$max1 = $col1.Length; $max2 = $col2.Length; $max3 = $col3.Length; $max4 = $col4.Length; $max5 = $col5.Length
$rows = @()
$hadFail = $false

foreach ($t in $tests) {
    $describe = if ($t.PSObject.Properties['Describe']) { $t.Describe } else { '' }
    $name     = if ($t.PSObject.Properties['Name'])     { $t.Name }     else { '' }
    $result   = if ($t.PSObject.Properties['Result'])   { $t.Result }   else { '' }
    $duration = if ($t.PSObject.Properties['Duration']) { '{0:N3}' -f $t.Duration.TotalSeconds } else { '' }
    $data     = ''
    if ($t.PSObject.Properties['Data'] -and $null -ne $t.Data) {
        $data = $t.Data | ConvertTo-Json -Compress
    }

    if ($describe.Length -gt $max1) { $max1 = $describe.Length }
    if ($name.Length     -gt $max2) { $max2 = $name.Length }
    if ($result.Length   -gt $max3) { $max3 = $result.Length }
    if ($duration.Length -gt $max4) { $max4 = $duration.Length }
    if ($data.Length     -gt $max5) { $max5 = $data.Length }

    $rows += [pscustomobject]@{
        Describe = $describe
        Name     = $name
        Result   = $result
        Duration = $duration
        Data     = $data
    }

    if ($result -ne 'Passed' -and $result -ne 'Skipped') { $hadFail = $true }
}

$header = ($col1.PadRight($max1) + '  ' +
           $col2.PadRight($max2) + '  ' +
           $col3.PadRight($max3) + '  ' +
           $col4.PadRight($max4) + '  ' +
           $col5.PadRight($max5))
Write-Host $header

foreach ($row in $rows) {
    $line = ($row.Describe.PadRight($max1) + '  ' +
             $row.Name.PadRight($max2)     + '  ' +
             $row.Result.PadRight($max3)   + '  ' +
             $row.Duration.PadRight($max4) + '  ' +
             $row.Data.PadRight($max5))
    switch ($row.Result) {
        'Passed'  { Write-Host $line -ForegroundColor Green }
        'Skipped' { Write-Host $line -ForegroundColor Yellow }
        default   { Write-Host $line -ForegroundColor Red }
    }
}

if ($hadFail) { exit 2 } else { exit 0 }
