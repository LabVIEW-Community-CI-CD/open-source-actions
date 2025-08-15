# Unified Dispatcher (Cross‑Platform)

This package adds a single, stable entrypoint to run LabVIEW CI/CD scripts.

- **Entry script:** `actions/Invoke-OSAction.ps1`
- **Module:** `actions/OpenSourceActions.psm1/.psd1`
- **Composite Action:** `action.yml` (repository root)
- **Adapters included:** See [docs/index.md](index.md#action-reference) for the authoritative list of adapters
- **Discovery:** `-ListActions` and `-Describe <name>`
- **Dry run:** `-DryRun` logs the exact call and skips execution
- **Exit codes:** Leaf script codes are preserved (e.g., `run-unit-tests` returns `0/2/3`)

See [Common Parameters](common-parameters.md) for a complete list of dispatcher flags and environment variables.

## Cross‑platform

Works on **Windows and Linux** as long as LabVIEW and [g-cli](https://github.com/ni/g-cli) are installed and available on `PATH`. For non‑standard installs, pass `gcliPath` in `args_yaml`. Legacy `args_json` is deprecated but still supported; adapters will prepend it to `PATH`.

## Example (CLI)

```powershell
$yaml = @'
MinimumSupportedLVVersion: "2021"
SupportedBitness: "64"
gcliPath: "/opt/gcli/bin"
'@
pwsh ./actions/Invoke-OSAction.ps1 -ActionName run-unit-tests -ArgsYaml (ConvertFrom-Yaml $yaml) -LogLevel INFO
```

## Composite Action usage

```yaml
- uses: ./run-unit-tests
  with:
    minimum_supported_lv_version: '2021'
    supported_bitness: '64'
    gcli_path: /opt/gcli/bin
```

## Matrix example (Windows and Linux)

```yaml
jobs:
  unit-tests:
    strategy:
      matrix:
        os: [windows-latest, ubuntu-latest]
    runs-on: ${{ matrix.os }}
    steps:
      - uses: actions/checkout@v4
      - uses: ./run-unit-tests
        with:
          minimum_supported_lv_version: '2021'
          supported_bitness: '64'
          gcli_path: /opt/gcli/bin
```

## SemVer policy

- **MAJOR**: breaking parameter/type changes, removing or renaming actions.
- **MINOR**: adding new adapter actions or optional parameters.
- **PATCH**: backwards‑compatible fixes and docs.
For the current module version, refer to `actions/OpenSourceActions.psd1`.
