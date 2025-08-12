# Smoke-DryRun.ps1 - Exercise all actions with -DryRun and verify exit codes.
$overallSuccess = $true

Write-Host "Testing add-token-to-labview..."
pwsh -NoProfile -File "$PSScriptRoot/../actions/Invoke-OSAction.ps1" -ActionName add-token-to-labview -ArgsJson '{"MinimumSupportedLVVersion":"2020","SupportedBitness":"64","RelativePath":"source"}' -DryRun
if ($LASTEXITCODE -ne 0) {
    Write-Error "add-token-to-labview DryRun failed with exit code $LASTEXITCODE"
    $overallSuccess = $false
}

Write-Host "Testing apply-vipc..."
pwsh -NoProfile -File "$PSScriptRoot/../actions/Invoke-OSAction.ps1" -ActionName apply-vipc -ArgsJson '{"MinimumSupportedLVVersion":"2020","VIP_LVVersion":"2020","SupportedBitness":"64","RelativePath":"source","VIPCPath":"MyLib.vipc"}' -DryRun
if ($LASTEXITCODE -ne 0) {
    Write-Error "apply-vipc DryRun failed with exit code $LASTEXITCODE"
    $overallSuccess = $false
}

Write-Host "Testing build..."
pwsh -NoProfile -File "$PSScriptRoot/../actions/Invoke-OSAction.ps1" -ActionName build -ArgsJson '{"RelativePath":"source","Major":1,"Minor":0,"Patch":0,"Build":1,"Commit":"abcd1234","LabVIEWMinorRevision":"0","CompanyName":"ACME Corp","AuthorName":"John Doe"}' -DryRun
if ($LASTEXITCODE -ne 0) {
    Write-Error "build DryRun failed with exit code $LASTEXITCODE"
    $overallSuccess = $false
}

Write-Host "Testing build-lvlibp..."
pwsh -NoProfile -File "$PSScriptRoot/../actions/Invoke-OSAction.ps1" -ActionName build-lvlibp -ArgsJson '{"MinimumSupportedLVVersion":"2020","SupportedBitness":"64","RelativePath":"source","LabVIEW_Project":"MyProject.lvproj","Build_Spec":"My Build","Major":1,"Minor":0,"Patch":0,"Build":1,"Commit":"abcd1234"}' -DryRun
if ($LASTEXITCODE -ne 0) {
    Write-Error "build-lvlibp DryRun failed with exit code $LASTEXITCODE"
    $overallSuccess = $false
}

Write-Host "Testing build-vi-package..."
pwsh -NoProfile -File "$PSScriptRoot/../actions/Invoke-OSAction.ps1" -ActionName build-vi-package -ArgsJson '{"MinimumSupportedLVVersion":"2020","SupportedBitness":"64","LabVIEWMinorRevision":"0","RelativePath":"source","VIPBPath":"MyLib.vipb","Major":1,"Minor":0,"Patch":0,"Build":1,"Commit":"abcd1234","DisplayInformationJSON":"{}","ReleaseNotesFile":"ReleaseNotes.md"}' -DryRun
if ($LASTEXITCODE -ne 0) {
    Write-Error "build-vi-package DryRun failed with exit code $LASTEXITCODE"
    $overallSuccess = $false
}

Write-Host "Testing close-labview..."
pwsh -NoProfile -File "$PSScriptRoot/../actions/Invoke-OSAction.ps1" -ActionName close-labview -ArgsJson '{"MinimumSupportedLVVersion":"2020","SupportedBitness":"64"}' -DryRun
if ($LASTEXITCODE -ne 0) {
    Write-Error "close-labview DryRun failed with exit code $LASTEXITCODE"
    $overallSuccess = $false
}

Write-Host "Testing generate-release-notes..."
pwsh -NoProfile -File "$PSScriptRoot/../actions/Invoke-OSAction.ps1" -ActionName generate-release-notes -ArgsJson '{"OutputPath":"temp/release_notes.md"}' -DryRun
if ($LASTEXITCODE -ne 0) {
    Write-Error "generate-release-notes DryRun failed with exit code $LASTEXITCODE"
    $overallSuccess = $false
}

Write-Host "Testing missing-in-project..."
pwsh -NoProfile -File "$PSScriptRoot/../actions/Invoke-OSAction.ps1" -ActionName missing-in-project -ArgsJson '{"LVVersion":"2020","Arch":"64","ProjectFile":"dummy.lvproj"}' -DryRun
if ($LASTEXITCODE -ne 0) {
    Write-Error "missing-in-project DryRun failed with exit code $LASTEXITCODE"
    $overallSuccess = $false
}

Write-Host "Testing modify-vipb-display-info..."
pwsh -NoProfile -File "$PSScriptRoot/../actions/Invoke-OSAction.ps1" -ActionName modify-vipb-display-info -ArgsJson '{"SupportedBitness":"64","RelativePath":"source","VIPBPath":"MyLib.vipb","MinimumSupportedLVVersion":"2020","LabVIEWMinorRevision":"0","Major":1,"Minor":0,"Patch":0,"Build":1,"Commit":"abcd1234","DisplayInformationJSON":"{}","ReleaseNotesFile":"ReleaseNotes.md"}' -DryRun
if ($LASTEXITCODE -ne 0) {
    Write-Error "modify-vipb-display-info DryRun failed with exit code $LASTEXITCODE"
    $overallSuccess = $false
}

Write-Host "Testing prepare-labview-source..."
pwsh -NoProfile -File "$PSScriptRoot/../actions/Invoke-OSAction.ps1" -ActionName prepare-labview-source -ArgsJson '{"MinimumSupportedLVVersion":"2020","SupportedBitness":"64","RelativePath":"source","LabVIEW_Project":"MyProject.lvproj","Build_Spec":"BuildSpecName"}' -DryRun
if ($LASTEXITCODE -ne 0) {
    Write-Error "prepare-labview-source DryRun failed with exit code $LASTEXITCODE"
    $overallSuccess = $false
}

Write-Host "Testing rename-file..."
pwsh -NoProfile -File "$PSScriptRoot/../actions/Invoke-OSAction.ps1" -ActionName rename-file -ArgsJson '{"CurrentFilename":"old.txt","NewFilename":"new.txt"}' -DryRun
if ($LASTEXITCODE -ne 0) {
    Write-Error "rename-file DryRun failed with exit code $LASTEXITCODE"
    $overallSuccess = $false
}

Write-Host "Testing restore-setup-lv-source..."
pwsh -NoProfile -File "$PSScriptRoot/../actions/Invoke-OSAction.ps1" -ActionName restore-setup-lv-source -ArgsJson '{"MinimumSupportedLVVersion":"2020","SupportedBitness":"64","RelativePath":"source","LabVIEW_Project":"MyProject.lvproj","Build_Spec":"BuildSpecName"}' -DryRun
if ($LASTEXITCODE -ne 0) {
    Write-Error "restore-setup-lv-source DryRun failed with exit code $LASTEXITCODE"
    $overallSuccess = $false
}

Write-Host "Testing revert-development-mode..."
pwsh -NoProfile -File "$PSScriptRoot/../actions/Invoke-OSAction.ps1" -ActionName revert-development-mode -ArgsJson '{"RelativePath":"source"}' -DryRun
if ($LASTEXITCODE -ne 0) {
    Write-Error "revert-development-mode DryRun failed with exit code $LASTEXITCODE"
    $overallSuccess = $false
}

Write-Host "Testing run-unit-tests..."
pwsh -NoProfile -File "$PSScriptRoot/../actions/Invoke-OSAction.ps1" -ActionName run-unit-tests -ArgsJson '{"MinimumSupportedLVVersion":"2020","SupportedBitness":"64"}' -DryRun
if ($LASTEXITCODE -ne 0) {
    Write-Error "run-unit-tests DryRun failed with exit code $LASTEXITCODE"
    $overallSuccess = $false
}

Write-Host "Testing set-development-mode..."
pwsh -NoProfile -File "$PSScriptRoot/../actions/Invoke-OSAction.ps1" -ActionName set-development-mode -ArgsJson '{"RelativePath":"source"}' -DryRun
if ($LASTEXITCODE -ne 0) {
    Write-Error "set-development-mode DryRun failed with exit code $LASTEXITCODE"
    $overallSuccess = $false
}

if (-not $overallSuccess) {
    Write-Error "One or more actions failed the DryRun smoke test."
    exit 1
} else {
    Write-Host "All actions DryRun smoke tests passed."
    exit 0
}