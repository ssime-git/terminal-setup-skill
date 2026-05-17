---
name: terminal-setup-skill
description: Use when setting up a terminal or agent CLI environment on WSL, Linux, macOS, or Windows and expecting an audit-first process rather than a blind script.
---

# Terminal Setup Skill

## Overview

This skill provides an audit-first, confirmation-driven terminal and agent CLI setup workflow for WSL, Linux, macOS, and Windows.

Covers:
- **terminal tooling**: Zsh, Starship, fzf, zoxide, eza, bat, fd, ripgrep, uv, pipx
- **agent tooling**: Hermes, OpenCode, Claude Code, Codex, Aider, Gemini CLI, Ollama, GitHub CLI
- **shell bootstraps**: Zsh and PowerShell
- **terminal polish**: Nerd Font and terminal recommendations

## Quick Reference

| Step | Action | Command |
|---|---|---|
| Audit | Run full audit | `python3 scripts/audit_env.py` |
| Audit (Markdown plan) | Generate install plan | `python3 scripts/audit_env.py --plan-md output/install-plan.md` |
| Install (Unix) | Full install | `bash scripts/install_unix.sh` |
| Install (Unix) | Dry run | `bash scripts/install_unix.sh --dry-run` |
| Install (Windows) | Full install | `powershell -ExecutionPolicy Bypass -File scripts/install_windows.ps1` |
| Bootstrap Zsh | Zsh config scaffold | `bash scripts/bootstrap_zsh_config.sh` |
| Bootstrap PowerShell | PowerShell config scaffold | `powershell -ExecutionPolicy Bypass -File scripts/bootstrap_powershell.ps1` |

## When to Use

Use this skill when:

- the user wants a modern terminal setup
- the user wants a reproducible agent-ready environment
- the user is on WSL, Linux, macOS, or Windows
- the user wants guided installation instead of a blind shell script
- the user wants a current-state audit before installing anything
- the user wants a Markdown install plan before proceeding

Do **not** use this skill when:

- the user only wants one small package installed
- the user already has a mature bootstrap/dotfiles system and only needs a small patch
- the user does not want confirmation-driven setup

## Mandatory Interaction Contract

The skill must follow this order.

### Step 1 — Ask whether explanations are wanted

> Do you want explanations for everything we may install and configure before we start?

If **yes**: explain each category briefly and why each tool matters.
If **no**: skip explanations and move directly to audit.

### Step 2 — Run a precise audit

```bash
python3 scripts/audit_env.py
```

Output modes:

```bash
python3 scripts/audit_env.py --json
python3 scripts/audit_env.py --markdown
python3 scripts/audit_env.py --plan-md output/install-plan.md
```

The audit captures:
- OS family, distro, WSL detection
- shell and package managers available
- install status for each terminal tool and agent CLI
- versions where possible
- auth/config readiness for agent CLIs
- package-name mapping for the recommended package manager
- Markdown install plan

### Step 3 — Present the audit clearly

Show:
- what is installed (with versions)
- what is missing
- what is optional
- what needs authentication/setup
- what package manager or installer path will be used
- which parts are package-manager installs vs manual/dedicated installers

### Step 4 — Build the final plan

Summarize:
- packages to install (with exact package names)
- CLIs to install (with installer commands)
- config scaffolding to create
- terminal/font recommendations
- OS-specific limitations
- risky actions (e.g. changing the default shell)

### Step 5 — Ask for confirmation

> I have the full plan. Do you want me to proceed with installation/configuration?

If the user wants per-step approval, keep asking before each grouped action.

### Step 6 — Execute with validation

#### Unix / WSL / Linux / macOS

```bash
bash scripts/install_unix.sh
```

Options:

```bash
bash scripts/install_unix.sh --dry-run
bash scripts/install_unix.sh --non-interactive --yes --with-zsh-bootstrap --with-fonts
bash scripts/install_unix.sh --plan-md output/install-plan.md
```

#### Windows PowerShell

```powershell
powershell -ExecutionPolicy Bypass -File scripts/install_windows.ps1
```

Options:

```powershell
powershell -ExecutionPolicy Bypass -File scripts/install_windows.ps1 -DryRun
powershell -ExecutionPolicy Bypass -File scripts/install_windows.ps1 -NonInteractive -Yes -WithPowerShellBootstrap -WithFonts
```

Optional shell scaffolds:

```bash
bash scripts/bootstrap_zsh_config.sh
```

```powershell
powershell -ExecutionPolicy Bypass -File scripts/bootstrap_powershell.ps1
```

### Step 7 — Verify after installation

```bash
python3 scripts/audit_env.py
python3 scripts/audit_env.py --plan-md output/install-plan.md
```

Then summarize:
- what succeeded
- what was skipped
- what still needs manual login/auth
- which next commands the user should run

## Scripts Reference

All scripts are in `scripts/`:

| Script | Purpose |
|---|---|
| `audit_env.py` | Cross-platform audit, package mapping, Markdown plan, JSON/text output |
| `install_unix.sh` | Interactive installer for WSL/Linux/macOS with dry-run, non-interactive, Zsh bootstrap, font hints |
| `install_windows.ps1` | Interactive installer for Windows (winget/choco/scoop) with dry-run, PowerShell bootstrap, font hints |
| `bootstrap_zsh_config.sh` | Idempotent Zsh config scaffold under `~/.config/zsh` (zshenv, zshrc, aliases, prompt, fzf, starship) |
| `bootstrap_powershell.ps1` | Idempotent PowerShell scaffold with Starship, zoxide, aliases |

## Explanation Block (if user wants explanations)

- **Zsh**: a stronger interactive shell than stock Bash for many users
- **PowerShell**: the native Windows-first shell, better than plain CMD for scripting and terminal customization
- **Starship**: a modern, cross-shell prompt
- **fzf**: fuzzy search for files and history
- **zoxide**: faster directory jumping
- **eza**: modern `ls` with icons and better formatting
- **bat**: readable `cat` replacement
- **fd**: ergonomic `find` replacement
- **ripgrep**: fast recursive search
- **uv / pipx**: cleaner CLI/tool installation for Python-based workflows
- **Hermes / OpenCode / Claude Code / Codex / Aider / Gemini CLI / Ollama**: agent and local-model tooling
- **GitHub CLI**: GitHub operations from the terminal
- **Nerd Fonts**: required for many icons in prompts and file listings

## Common Pitfalls

1. **Changing the default shell too early**
   - Do not change the default shell without explicit user approval.

2. **Installing npm-based agent CLIs without checking Node/npm**
   - Audit first. If the user uses nvm/fnm, installing Node via system packages may conflict.

3. **Ignoring auth state after install**
   - Installation success does not mean the CLI is ready to use.

4. **Assuming Windows should use Zsh natively**
   - Prefer WSL for Unix/Zsh-heavy workflows.

5. **Assuming package names are identical everywhere**
   - `bat` vs `batcat`, `fd` vs `fdfind`, package names vary per ecosystem.

6. **Forgetting terminal font requirements**
   - Prompt icons and file icons often require a Nerd Font.

7. **Running without sudo access**
   - System package managers (apt, dnf, yum, pacman) require sudo. Check before attempting install.

8. **No rollback plan**
   - The installers make changes without built-in undo. Advise the user to back up their dotfiles first if they have existing configs.

9. **Skipping the audit**
   - Never install without running the audit first. The audit determines the correct package names and detects already-installed tools.

## Verification Checklist

- [ ] Asked whether the user wants explanations
- [ ] Ran audit before installation
- [ ] Presented installed vs missing clearly
- [ ] Presented auth/setup status for installed agent CLIs
- [ ] Presented a final install plan
- [ ] Asked for confirmation before changes
- [ ] Executed only approved install/config actions
- [ ] Re-ran audit after changes
- [ ] Summarized remaining auth or manual steps
