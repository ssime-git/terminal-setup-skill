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
| Backup | Backup current dotfiles | `bash scripts/backup_dotfiles.sh` |
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

### Step 4.5 — Backup current setup

Before making changes, run the backup script:

```bash
bash scripts/backup_dotfiles.sh
```

This preserves:
- `~/.zshrc` (main Zsh config)
- `~/.zshenv` (environment variables)
- `~/.oh-my-zsh/custom/` (custom plugins and themes)
- `~/.config/zsh/` (if bootstrap scaffold was already applied)

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

### Step 8 — Present final summary

After verification, present a clear summary with the following structure:

**What was installed / configured:**
- List each tool installed with a one-line purpose (e.g. `starship` — modern prompt, `zoxide` — smart `cd`, etc.)
- Mention which config files were created or modified

**How to use each tool:**
- `starship` — prompt is automatic on next shell; customize in `~/.config/zsh/starship.toml`
- `zoxide` — use `z <dir>` to jump anywhere, `zi` for interactive picker
- `eza` — `ls`, `ll`, `la`, `tree` now use eza with icons automatically
- `fd` — `find` aliased to `fd`; use `fd <pattern>` for fast file search
- `bat` — `cat` aliased to `bat` with syntax highlighting
- `fzf` — `Ctrl+T` for file search, `Ctrl+R` for history search
- `ripgrep` — `grep` aliased to `rg` for fast recursive search
- `pipx` / `uv` — install Python CLI tools with `pipx install` or `uv tool install`

**Backup location:**
```
Your previous shell config was backed up to:
~/.terminal-backup-<timestamp>/

Restore with:
cp ~/.terminal-backup-<timestamp>/zshrc ~/.zshrc
```

**Remaining manual steps (if any):**
- Login/auth commands for agent CLIs (e.g. `opencode auth login`, `claude`, `gh auth login`)
- Font configuration for terminal (if Nerd Font not yet set)
- Any optional tools not installed

## Scripts Reference

All scripts are in `scripts/`:

| Script | Purpose |
|---|---|
| `backup_dotfiles.sh` | Timestamped backup of ~/.zshrc, ~/.zshenv, ~/.oh-my-zsh/custom, ~/.config/zsh |
| `audit_env.py` | Cross-platform audit, package mapping, Markdown plan, JSON/text output |
| `install_unix.sh` | Interactive installer for WSL/Linux/macOS with dry-run, non-interactive, Zsh bootstrap, font hints |
| `install_windows.ps1` | Interactive installer for Windows (winget/choco/scoop) with dry-run, PowerShell bootstrap, font hints |
| `bootstrap_zsh_config.sh` | Idempotent Zsh config scaffold under `~/.config/zsh` (zshenv, zshrc, aliases, prompt, fzf, starship) |
| `bootstrap_powershell.ps1` | Idempotent PowerShell scaffold with Starship, zoxide, aliases |

## Explanation Block (if user wants explanations)

- **Zsh**: a stronger interactive shell than stock Bash for many users
- **PowerShell**: the native Windows-first shell, better than plain CMD for scripting and terminal customization
- **Starship**: a modern, cross-shell prompt with git branch, line-level diff metrics, and per-language indicators
- **fzf**: fuzzy search for files and history
- **zoxide**: faster directory jumping
- **eza**: modern `ls` with icons and better formatting
- **bat**: readable `cat` replacement
- **fd**: ergonomic `find` replacement
- **ripgrep**: fast recursive search
- **uv / pipx**: cleaner CLI/tool installation for Python-based workflows
- **Hermes / OpenCode / Claude Code / Codex / Aider / Gemini CLI / Ollama**: agent and local-model tooling
- **DeepSeek CLI**: terminal access to the DeepSeek API
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

6. **Skipping backup before install**
   - Always back up existing dotfiles before applying config changes. The installers make changes without built-in undo.

7. **Forgetting terminal font requirements**
   - Prompt icons and file icons often require a Nerd Font.

8. **Running without sudo access**
   - System package managers (apt, dnf, yum, pacman) require sudo. Check before attempting install.

9. **Skipping the audit**
   - Never install without running the audit first. The audit determines the correct package names and detects already-installed tools.

10. **Invalid TOML escapes in `starship.toml`**
    - Do not use `\$` in TOML files. TOML does not recognize `\$` as a valid escape.
    - Starship template variables like `${count}` should be written as `"⇡${count}"` (no backslash), not `"⇡\${count}"`.
    - Same applies for standalone `$`: use `"$"`, not `"\$"`.

11. **brew shellenv ordering**
    - If tools like starship, zoxide, eza are installed via Homebrew/Linuxbrew, `eval "$(brew shellenv)"` must be called **before** `command -v starship` or any `command -v` check.
    - The typical error: `command -v starship` returns empty at shell init because brew is not yet in `$PATH`, causing starship to silently skip initialization.
    - Fix: place `eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"` right after Oh My Zsh (or early in `.zshrc`), before any tool init blocks.

12. **`alias -="..."` is invalid in zsh**
    - `-` is parsed as an option flag to the `alias` builtin, not as an alias name.
    - Use `alias -- -='cd -'` if you really want an alias named `-`, or define a function: `function --() { cd -; }`.
    - Better: just omit `-` aliases; zsh already has `cd -` built-in.

13. **Hardcoded `$PATH` overrides**
    - Using `export PATH="/some/dir:/other/dir"` (hardcoded, no `$PATH`) **overwrites** the entire path, silently removing earlier additions (brew, cargo, npm-global, etc.).
    - Tools installed via brew will appear to work at shell start (if init runs before the override) but fail when used later (eza, zoxide, etc.).
    - Fix: always use `export PATH="/new/dir:$PATH"` (prepend) or `export PATH="$PATH:/new/dir"` (append) to preserve existing entries.

## Verification Checklist

- [ ] Asked whether the user wants explanations
- [ ] Ran audit before installation
- [ ] Presented installed vs missing clearly
- [ ] Presented auth/setup status for installed agent CLIs
- [ ] Presented a final install plan
- [ ] Asked for confirmation before changes
- [ ] Backup created before modifying config
- [ ] Executed only approved install/config actions
- [ ] Verified PATH ordering: `brew shellenv` (or equivalent) before `command -v` checks for brew-installed tools
- [ ] Validated `starship.toml` has no invalid TOML escapes (`\$` → `$`)
- [ ] Re-ran audit after changes
- [ ] Did a fresh login (SSH or new terminal) to confirm prompt loads without errors
- [ ] Summarized remaining auth or manual steps
