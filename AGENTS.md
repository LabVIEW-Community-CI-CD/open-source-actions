# AGENTS.md

## Testing
- Run `npm install` to ensure Node dependencies are available.
- Execute `npm test`.
- Install PowerShell 7.5.2 and the Pester module. If `pwsh` is not available, install it with `apt-get update && apt-get install -y powershell`. Then run `pwsh -NoLogo -Command "Invoke-Pester -CI -Path ./tests/pester"`.
- All tests above are mandatory; they must pass before committing.

## Development Notes
- Composite actions live at the repository root (e.g., `run-unit-tests/action.yml`) and dispatch to scripts in `actions/`.
- When referencing these composite actions in workflows, use their root-level path (for example, `./setup-mkdocs`).
  Prefixing with `actions/` (such as `./actions/setup-mkdocs`) will fail to resolve the action and can break jobs like `deploy-docs`.
- Use a single commit; do not create new branches.
