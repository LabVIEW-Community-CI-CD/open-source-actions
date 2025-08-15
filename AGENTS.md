# AGENTS.md

## Testing
- Run `npm install` to ensure Node dependencies are available.
- Execute `npm test`.
- Install PowerShell 7.5.2 and the Pester module, then run `pwsh -NoLogo -Command "Invoke-Pester -CI -Path ./tests/pester"`.
- All tests above are mandatory; they must pass before committing.

## Development Notes
- Composite actions live at the repository root (e.g., `run-unit-tests/action.yml`) and dispatch to scripts in `actions/`.
- Use a single commit; do not create new branches.
