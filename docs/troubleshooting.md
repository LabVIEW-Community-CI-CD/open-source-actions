# Troubleshooting
Use this guide to diagnose common problems encountered when running the actions.

## Setup issues
- Ensure NI LabVIEW and g-cli are installed and accessible.
- Verify PowerShell 7+ (`pwsh`) is available on the PATH.
- Confirm the working directory and file paths are correct.

## Missing dependencies
- Check that required packages and toolkits are installed.
- Install any missing modules or scripts referenced by the action.
- Review action parameters for typos that could hide dependencies.

## Interpreting exit codes
- `0` indicates success; any non-zero code signals a failure.
- Consult each action's documentation for specific return codes.
- Use verbose logs to pinpoint the cause of unexpected codes.
