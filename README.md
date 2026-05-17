# terminal-setup-skill

Audit-first, confirmation-driven terminal and agent CLI setup for WSL, Linux, macOS, and Windows.

## What this project does

This repository provides a reusable setup workflow for building a modern terminal and AI-agent CLI environment with explicit validation before changes are applied.

It covers:
- WSL
- Linux
- macOS
- Windows

It supports:
- terminal tooling: Zsh, Starship, fzf, zoxide, eza, bat, fd, ripgrep, uv, pipx
- agent tooling: Hermes, OpenCode, Claude Code, Codex, Aider, Gemini CLI, Ollama, GitHub CLI
- shell bootstraps: Zsh and PowerShell
- terminal polish: Nerd Font recommendations and terminal recommendations

## Core workflow

1. Ask whether explanations are wanted
2. Audit the machine
3. Generate a final install plan
4. Ask for confirmation
5. Install/configure in controlled steps
6. Re-audit and summarize next steps

## Repository structure

- `SKILL.md`: main skill specification
- `scripts/audit_env.py`: cross-platform audit + Markdown plan generation
- `scripts/install_unix.sh`: installer for WSL / Linux / macOS
- `scripts/install_windows.ps1`: installer for Windows
- `scripts/bootstrap_zsh_config.sh`: minimal Zsh scaffold
- `scripts/bootstrap_powershell.ps1`: minimal PowerShell scaffold
- `references/scripts.md`: script usage notes

## Quick start

### Audit only

```bash
python3 scripts/audit_env.py
python3 scripts/audit_env.py --markdown
python3 scripts/audit_env.py --plan-md output/install-plan.md
```

### Unix / WSL / macOS

```bash
bash scripts/install_unix.sh --dry-run
bash scripts/install_unix.sh --non-interactive --yes --with-zsh-bootstrap --with-fonts
```

### Windows

```powershell
powershell -ExecutionPolicy Bypass -File scripts/install_windows.ps1 -DryRun
powershell -ExecutionPolicy Bypass -File scripts/install_windows.ps1 -NonInteractive -Yes -WithPowerShellBootstrap -WithFonts
```

## Current capabilities

- audit installed tools and package managers
- detect auth/setup state for several agent CLIs
- map package names more precisely by OS/package manager
- generate a final plan in Markdown
- support dry-run and non-interactive modes
- recommend Nerd Fonts and terminal hosts
- support both Zsh and PowerShell bootstrapping

## Notes

- Windows users who want a Zsh-first workflow should generally prefer WSL.
- Agent installation does not guarantee authentication is complete.
- PowerShell runtime validation must still be done on a Windows machine with `pwsh` or `powershell` available.
