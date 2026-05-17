# Terminal Setup Skill

Audit-first, confirmation-driven terminal and agent CLI setup for **WSL, Linux, macOS, and Windows**.

---

## Quick start

```bash
# 1. Audit what's already installed
python3 scripts/audit_env.py

# 2. Backup current dotfiles
bash scripts/backup_dotfiles.sh

# 3. Install missing tools
bash scripts/install_unix.sh

# 4. Apply Zsh config scaffold
bash scripts/bootstrap_zsh_config.sh
```

> **Always audit first.** The skill never installs without showing you the full plan.

---

## Tools installed

| Tool | Purpose | How to use |
|------|---------|------------|
| **Starship** | Fast, customizable prompt with git status and metrics | Automatic. Customize in `~/.config/zsh/starship.toml` |
| **zoxide** | Smarter `cd` — learns your most used dirs | `z project` or just `cd` as usual |
| **eza** | Modern `ls` with icons, colors, and tree view | `ls`, `ll`, `la`, `tree` — all aliased automatically |
| **bat** | `cat` with syntax highlighting and line numbers | `cat <file>` (aliased automatically) |
| **fd** | Blazing fast `find` replacement | `find <pattern>` (aliased automatically) |
| **ripgrep (rg)** | Fast recursive grep | `grep <pattern>` (aliased automatically) |
| **fzf** | Fuzzy search for files, history, git | `Ctrl+T` (files), `Ctrl+R` (history) |
| **pipx / uv** | Install and run Python CLI tools in isolation | `pipx install <tool>` or `uv tool install <tool>` |

> **Icons not showing in VS Code terminal?** VS Code uses its own font setting, separate from Windows Terminal. To add this to your VS Code `settings.json` :
> 1.  Open it via `Ctrl+Shift+P` → `Preferences: Open User Settings (JSON)`
> 2.  Add this to your VS Code `settings.json`:
>
> ```json
> "terminal.integrated.fontFamily": "JetBrainsMono Nerd Font"
> ```

### Agent CLIs (optional)

| Tool | What for |
|------|----------|
| **Hermes** | Agent orchestration |
| **OpenCode** | AI coding assistant in the terminal |
| **Claude Code** | Anthropic's CLI coding agent |
| **Codex** | OpenAI CLI coding agent |
| **Aider** | AI pair programming in the terminal |
| **Gemini CLI** | Google Gemini from the terminal |
| **Ollama** | Run local LLMs |
| **GitHub CLI** | PRs, issues, repos from the terminal |
| **DeepSeek CLI** | DeepSeek API from the terminal |

---

## What the skill does

1. **Audits** your current setup — OS, shell, package managers, installed tools, versions
2. **Plans** what to install based on what's missing
3. **Backs up** your existing dotfiles before any change
4. **Installs** tools via your system package manager (apt, brew, etc.)
5. **Configures** your shell with Starship prompt, aliases, and smart defaults
6. **Verifies** everything works and shows you the result

---

## Workflow

```
audit_env.py  ──►  backup_dotfiles.sh  ──►  install_unix.sh  ──►  bootstrap_zsh_config.sh
```

Each step is interactive and asks for confirmation. Use `--non-interactive --yes` for automation.

---

## Script reference

| Script | What it does |
|--------|-------------|
| `audit_env.py` | Full system audit: OS, shells, package managers, tool versions, auth state |
| `backup_dotfiles.sh` | Timestamped backup of `.zshrc`, `.zshenv`, `.oh-my-zsh/custom`, `.config/zsh` |
| `install_unix.sh` | Interactive installer for Linux/WSL/macOS |
| `install_windows.ps1` | Interactive installer for Windows (winget/choco/scoop) |
| `bootstrap_zsh_config.sh` | Idempotent Zsh scaffold: aliases, fzf, starship, zoxide, history |
| `bootstrap_powershell.ps1` | Idempotent PowerShell scaffold |

---

## Kickstart with Claude Code

Open Claude Code in this directory and paste one of these prompts to start a guided setup session.

**New machine — full setup:**
```
Use the terminal-setup-skill to set up my terminal. Start by asking whether I want explanations, then run the audit and show me the results before doing anything.
```

**Audit only — no changes:**
```
Use the terminal-setup-skill audit step only. Run scripts/audit_env.py and show me what is installed, what is missing, and which agent CLIs need auth configuration.
```

**Check and repair an existing setup:**
```
Use the terminal-setup-skill to audit my current terminal setup and tell me what is drifted, broken, or missing from the expected configuration.
```

---

## Full specification

See [SKILL.md](SKILL.md) for the complete skill spec, including mandatory interaction contract, common pitfalls, and verification checklist.
