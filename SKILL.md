---
name: terminal-setup-skill
description: "Use when you want an audit-first, confirmation-driven terminal and agent CLI setup flow across WSL, Linux, macOS, or Windows."
version: 2.0.0
author: Hermes Agent
license: MIT
platforms: [linux, macos, windows]
metadata:
  hermes:
    tags: [terminal, setup, zsh, starship, fzf, zoxide, agents, wsl, macos, windows, powershell]
    related_skills: [hermes-agent, opencode, claude-code, codex]
---

# Terminal Setup Skill

## Overview

This project is the **single source of truth** for a reusable terminal and agent-CLI setup workflow:

- `/home/seb/project/terminal-setup-skill`

It helps a user build a clean, modern, agent-ready environment on:

- WSL
- Linux
- macOS
- Windows

It is designed to be **interactive, explicit, audit-first, and safe**.

The flow is always:

1. optionally explain what will be installed
2. audit the machine precisely
3. build a concrete plan
4. ask for confirmation
5. install/configure in controlled steps
6. verify and summarize what remains

This skill supports both:

- **terminal tooling**: Zsh, Starship, fzf, zoxide, eza, bat, fd, ripgrep, uv, pipx
- **agent tooling**: Hermes, OpenCode, Claude Code, Codex, Aider, Gemini CLI, Ollama, GitHub CLI
- **shell bootstraps**: Zsh and PowerShell
- **terminal polish**: Nerd Font and terminal recommendations

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
Start with this question or equivalent:

> Do you want explanations for everything we may install and configure before we start?

If the user says **yes**:
- explain each category briefly
- keep it concise
- explain why each tool matters

If the user says **no**:
- skip explanations
- move directly to audit

### Step 2 — Run a precise audit
Use the audit script:

```bash
python3 scripts/audit_env.py
```

Useful output modes:

```bash
python3 scripts/audit_env.py --json
python3 scripts/audit_env.py --markdown
python3 scripts/audit_env.py --plan-md output/install-plan.md
```

The audit captures:

- OS family and distro
- whether the machine is WSL
- shell and package managers available
- whether each terminal tool is installed
- whether each agent CLI is installed
- important prerequisites like git, curl, node/npm, uv, pipx
- finer auth/setup status for Hermes, Claude Code, Codex, OpenCode, Aider, Gemini, Ollama
- recommended install strategy for the current machine
- package-name mapping for the recommended package manager
- a Markdown install plan

### Step 3 — Present the audit clearly
The user must see:

- what is already installed
- what is missing
- what is optional
- what still needs authentication/setup
- what package manager or installer path will be used
- which parts are package-manager installs vs manual/dedicated installers

### Step 4 — Build the final install/config plan
The agent must summarize:

- packages to install
- CLIs to install
- config scaffolding to create
- terminal/font recommendations
- any OS-specific limitations
- any risky actions such as changing the default shell

### Step 5 — Ask for confirmation
Before any install or config action, ask for confirmation.

Recommended prompt:

> I have the full plan. Do you want me to proceed with installation/configuration?

If the user wants per-step approval, keep asking before each grouped action.

### Step 6 — Execute with validation
Use the appropriate installer script.

#### Unix / WSL / Linux / macOS
```bash
bash scripts/install_unix.sh
```

Examples:

```bash
bash scripts/install_unix.sh --dry-run
bash scripts/install_unix.sh --non-interactive --yes --with-zsh-bootstrap --with-fonts
bash scripts/install_unix.sh --plan-md output/install-plan.md
```

#### Windows PowerShell
```powershell
powershell -ExecutionPolicy Bypass -File scripts/install_windows.ps1
```

Examples:

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
Re-run the audit:

```bash
python3 scripts/audit_env.py
python3 scripts/audit_env.py --plan-md output/install-plan.md
```

Then summarize:

- what succeeded
- what was skipped
- what still needs manual login/auth
- which next commands the user should run

## What the Scripts Do

### `scripts/audit_env.py`
Cross-platform audit script.

It detects:
- OS / distro / WSL
- package managers
- shells
- terminal tools
- agent CLIs
- versions where possible
- auth/config readiness for multiple agent CLIs
- package-manager mapping for installable tools
- terminal and font recommendations
- Markdown install plan output

### `scripts/install_unix.sh`
Interactive installer for:
- WSL
- Linux
- macOS

Features:
- dry-run mode
- non-interactive mode
- grouped confirmations
- package-name mapping per OS/package manager
- optional Zsh bootstrap
- optional Nerd Font recommendations
- optional agent CLI install flow

### `scripts/install_windows.ps1`
Interactive installer for Windows.

Features:
- `winget` / `choco` / `scoop` support
- dry-run mode
- non-interactive mode
- optional PowerShell bootstrap
- optional Nerd Font recommendations
- agent CLI installation where relevant
- explicit recommendation to prefer WSL for Zsh-first Unix workflows

### `scripts/bootstrap_zsh_config.sh`
Optional scaffold for a minimal structured Zsh setup.

It creates:
- `~/.config/zsh/.zshenv`
- `~/.config/zsh/.zshrc`
- `~/.config/zsh/aliases.zsh`
- `~/.config/zsh/prompt.zsh`
- `~/.config/zsh/fzf.zsh`
- `~/.config/zsh/starship.toml`

The scaffold is intentionally minimal and idempotent.

### `scripts/bootstrap_powershell.ps1`
Optional scaffold for a PowerShell developer setup.

It creates/configures:
- PowerShell profile
- Starship init
- zoxide init
- a small alias/function layer
- `~/.config/powershell/starship.toml`

## Project Files

This project includes:

- `SKILL.md`
- `scripts/audit_env.py`
- `scripts/install_unix.sh`
- `scripts/install_windows.ps1`
- `scripts/bootstrap_zsh_config.sh`
- `scripts/bootstrap_powershell.ps1`
- `references/scripts.md`

## Recommended Conversation Pattern

Use this exact high-level sequence:

1. Ask whether the user wants explanations
2. Run audit
3. Show installed vs missing
4. Show auth/setup status for installed agent CLIs
5. Show the final plan
6. Ask confirmation
7. Execute installation/config in validated groups
8. Re-run audit
9. Summarize next steps

## Example Explanation Block

If the user asked for explanations, explain briefly:

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
- **Nerd Fonts**: required for many icons in prompts and file listings

## Common Pitfalls

1. **Changing the default shell too early**
   - Do not change the default shell without explicit user approval.

2. **Installing npm-based agent CLIs without checking Node/npm**
   - Audit first.

3. **Ignoring auth state after install**
   - Installation success does not mean the CLI is ready to use.

4. **Assuming Windows should use Zsh natively**
   - Prefer WSL for Unix/Zsh-heavy workflows.

5. **Assuming package names are identical everywhere**
   - `bat` vs `batcat`, `fd` vs `fdfind`, package names vary per ecosystem.

6. **Forgetting terminal font requirements**
   - Prompt icons and file icons often require a Nerd Font.

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
