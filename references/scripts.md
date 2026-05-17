# Terminal Setup Skill Scripts

This directory contains the operational scripts for the `terminal-setup-skill`.

## Files

- `audit_env.py`
  - Cross-platform audit of terminal tooling, package managers, shells, terminal recommendations, and agent CLIs.
  - Detects both install state and finer auth/setup state for several agent CLIs.
  - Supports human-readable, JSON, and Markdown output.

- `install_unix.sh`
  - Interactive installer for WSL, Linux, and macOS.
  - Supports `--dry-run`, `--non-interactive`, `--yes`, `--with-zsh-bootstrap`, `--with-fonts`, and Markdown plan generation.

- `install_windows.ps1`
  - Interactive installer for Windows.
  - Supports `-DryRun`, `-NonInteractive`, `-Yes`, `-WithPowerShellBootstrap`, and `-WithFonts`.

- `bootstrap_zsh_config.sh`
  - Optional idempotent scaffold for a structured Zsh config under `~/.config/zsh`.

- `bootstrap_powershell.ps1`
  - Optional PowerShell scaffold with Starship + zoxide initialization and a small alias layer.

## Typical flow

1. Audit:

```bash
python3 scripts/audit_env.py
python3 scripts/audit_env.py --markdown
python3 scripts/audit_env.py --plan-md output/install-plan.md
```

2. Review the resulting plan with the user.

3. Install on Unix / WSL / macOS:

```bash
bash scripts/install_unix.sh
bash scripts/install_unix.sh --dry-run
bash scripts/install_unix.sh --non-interactive --yes --with-zsh-bootstrap --with-fonts
```

4. Install on Windows:

```powershell
powershell -ExecutionPolicy Bypass -File scripts/install_windows.ps1
powershell -ExecutionPolicy Bypass -File scripts/install_windows.ps1 -DryRun
powershell -ExecutionPolicy Bypass -File scripts/install_windows.ps1 -NonInteractive -Yes -WithPowerShellBootstrap -WithFonts
```

5. Optional shell scaffolds:

```bash
bash scripts/bootstrap_zsh_config.sh
```

```powershell
powershell -ExecutionPolicy Bypass -File scripts/bootstrap_powershell.ps1
```

6. Re-audit:

```bash
python3 scripts/audit_env.py
```

## Notes

- The scripts are interactive on purpose unless explicitly switched to non-interactive mode.
- They are intended to support the skill workflow, not bypass it.
- Agent-specific auth often still needs to be completed manually after installation.
- Prompt/file icons often require a Nerd Font in the terminal host.
- For Windows users who want Zsh-first workflows, WSL remains the recommended path.
