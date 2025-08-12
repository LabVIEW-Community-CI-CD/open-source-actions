# run-unit-tests

## Purpose
Run LabVIEW unit tests and report pass/fail/error using standard exit codes.

## Parameters

### Required
- **MinimumSupportedLVVersion** (`string`): LabVIEW version for the test run.
- **SupportedBitness** (`string`): "32" or "64" bitness of LabVIEW.

### Optional
None.

## Usage

### Command line
```powershell
pwsh -File actions/Invoke-OSAction.ps1 -ActionName run-unit-tests -ArgsJson '{
  "MinimumSupportedLVVersion": "2020",
  "SupportedBitness": "64"
}'
```

### GitHub Actions
```yaml
- name: Run LabVIEW Unit Tests
  uses: LabVIEW-Community-CI-CD/open-source-actions/abstract-action@v1
  with:
    action_name: run-unit-tests
    args_json: >-
      {
        "MinimumSupportedLVVersion": "2020",
        "SupportedBitness": "64"
      }
```
