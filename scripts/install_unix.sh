#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
AUDIT_SCRIPT="$SCRIPT_DIR/audit_env.py"
PLAN_MD_DEFAULT="$ROOT_DIR/output/install-plan.md"
DRY_RUN=0
NON_INTERACTIVE=0
YES_ALL=0
BOOTSTRAP_ZSH=0
INSTALL_FONTS=0
INSTALL_TERMINAL_TOOLS=1
INSTALL_AGENT_TOOLS=1
PLAN_MD="$PLAN_MD_DEFAULT"

# NOTE: node/npm are included for npm-based agent CLIs (Claude Code, OpenCode, etc.).
# If you use a version manager (nvm, fnm), install node/npm through that instead.
CORE_TERMINAL_TOOLS=(git curl zsh fzf zoxide eza bat fd ripgrep starship uv pipx node npm)
AGENT_TOOLS=(hermes opencode claude codex aider gemini ollama gh)
SELECTED_AGENT_TOOLS=()
SELECTED_TERMINAL_TOOLS=()
PACKAGE_MANAGER=""

usage() {
  cat <<'EOF'
Usage: install_unix.sh [options]

Options:
  --dry-run               Print planned commands without executing them
  --non-interactive       Do not prompt; combine with --yes to proceed automatically
  --yes                   Auto-approve prompts
  --plan-md PATH          Write Markdown plan to PATH
  --with-zsh-bootstrap    Run bootstrap_zsh_config.sh at the end
  --with-fonts            Include Nerd Font recommendations / install hints
  --skip-terminal-tools   Skip terminal tool installation phase
  --skip-agent-tools      Skip agent CLI installation phase
  -h, --help              Show this help message
EOF
}

log() { printf '%s\n' "$*"; }
warn() { printf 'WARN: %s\n' "$*" >&2; }

has_cmd() {
  command -v "$1" >/dev/null 2>&1
}

run_or_echo() {
  log "→ $*"
  if [[ "$DRY_RUN" -eq 1 ]]; then
    return 0
  fi
  "$@"
}

run_shell_or_echo() {
  local cmd="$1"
  log "→ $cmd"
  if [[ "$DRY_RUN" -eq 1 ]]; then
    return 0
  fi
  bash -lc "$cmd"
}

ask_yes_no() {
  local prompt="$1"
  if [[ "$YES_ALL" -eq 1 ]]; then
    return 0
  fi
  if [[ "$NON_INTERACTIVE" -eq 1 ]]; then
    return 1
  fi
  if [[ ! -t 0 ]]; then
    warn "Cannot prompt interactively (no TTY). Use --non-interactive --yes to proceed."
    return 1
  fi
  local reply
  while true; do
    read -r -p "$prompt [y/n]: " reply
    case "${reply,,}" in
      y|yes) return 0 ;;
      n|no) return 1 ;;
      *) echo "Please answer y or n." ;;
    esac
  done
}

choose_pkg_manager() {
  if has_cmd apt-get || has_cmd apt; then
    echo apt
  elif has_cmd dnf; then
    echo dnf
  elif has_cmd yum; then
    echo yum
  elif has_cmd pacman; then
    echo pacman
  elif has_cmd brew; then
    echo brew
  else
    echo manual
  fi
}

# WARNING: This case statement duplicates the PACKAGE_MAP dict in audit_env.py.
# Keep both in sync when adding or changing package name mappings.
pkg_name_for() {
  local manager="$1"
  local tool="$2"
  case "$manager:$tool" in
    apt:git) echo git ;;
    apt:curl) echo curl ;;
    apt:zsh) echo zsh ;;
    apt:fzf) echo fzf ;;
    apt:zoxide) echo zoxide ;;
    apt:bat) echo bat ;;
    apt:fd) echo fd-find ;;
    apt:ripgrep) echo ripgrep ;;
    apt:node) echo nodejs ;;
    apt:npm) echo npm ;;
    apt:uv) echo uv ;;
    apt:pipx) echo pipx ;;
    dnf:git) echo git ;;
    dnf:curl) echo curl ;;
    dnf:zsh) echo zsh ;;
    dnf:fzf) echo fzf ;;
    dnf:zoxide) echo zoxide ;;
    dnf:eza) echo eza ;;
    dnf:bat) echo bat ;;
    dnf:fd) echo fd-find ;;
    dnf:ripgrep) echo ripgrep ;;
    dnf:starship) echo starship ;;
    dnf:node) echo nodejs ;;
    dnf:npm) echo npm ;;
    dnf:uv) echo uv ;;
    dnf:pipx) echo pipx ;;
    dnf:gh) echo gh ;;
    yum:git) echo git ;;
    yum:curl) echo curl ;;
    yum:zsh) echo zsh ;;
    yum:ripgrep) echo ripgrep ;;
    yum:node) echo nodejs ;;
    yum:npm) echo npm ;;
    yum:pipx) echo pipx ;;
    pacman:git) echo git ;;
    pacman:curl) echo curl ;;
    pacman:zsh) echo zsh ;;
    pacman:fzf) echo fzf ;;
    pacman:zoxide) echo zoxide ;;
    pacman:eza) echo eza ;;
    pacman:bat) echo bat ;;
    pacman:fd) echo fd ;;
    pacman:ripgrep) echo ripgrep ;;
    pacman:starship) echo starship ;;
    pacman:node) echo nodejs ;;
    pacman:npm) echo npm ;;
    pacman:uv) echo uv ;;
    pacman:pipx) echo python-pipx ;;
    pacman:gh) echo github-cli ;;
    brew:git) echo git ;;
    brew:curl) echo curl ;;
    brew:zsh) echo zsh ;;
    brew:fzf) echo fzf ;;
    brew:zoxide) echo zoxide ;;
    brew:eza) echo eza ;;
    brew:bat) echo bat ;;
    brew:fd) echo fd ;;
    brew:ripgrep) echo ripgrep ;;
    brew:starship) echo starship ;;
    brew:node) echo node ;;
    brew:npm) echo node ;;
    brew:uv) echo uv ;;
    brew:pipx) echo pipx ;;
    brew:gh) echo gh ;;
    *) echo "" ;;
  esac
}

install_packages() {
  local manager="$1"
  shift
  if [[ $# -eq 0 ]]; then
    return 0
  fi
  case "$manager" in
    apt) run_or_echo sudo apt-get update; run_or_echo sudo apt-get install -y "$@" ;;
    dnf) run_or_echo sudo dnf install -y "$@" ;;
    yum) run_or_echo sudo yum install -y "$@" ;;
    pacman) run_or_echo sudo pacman -Sy --noconfirm "$@" ;;
    brew) run_or_echo brew install "$@" ;;
    *) warn "No supported package manager for automatic install."; return 1 ;;
  esac
}

cmd_for_tool() {
  case "$1" in
    eza) echo eza ;;
    bat) if has_cmd batcat; then echo batcat; else echo bat; fi ;;
    fd) if has_cmd fdfind; then echo fdfind; else echo fd; fi ;;
    gh) echo gh ;;
    *) echo "$1" ;;
  esac
}

is_installed_tool() {
  local tool="$1"
  local cmd
  cmd="$(cmd_for_tool "$tool")"
  has_cmd "$cmd"
}

install_agent() {
  local tool="$1"
  case "$tool" in
    hermes)
      run_shell_or_echo "curl -fsSL https://raw.githubusercontent.com/NousResearch/hermes-agent/main/scripts/install.sh | bash"
      ;;
    opencode)
      if has_cmd brew && ask_yes_no "Use Homebrew for OpenCode instead of npm?"; then
        run_or_echo brew install anomalyco/tap/opencode
      else
        run_or_echo npm install -g opencode-ai@latest
      fi
      ;;
    claude)
      run_or_echo npm install -g @anthropic-ai/claude-code
      ;;
    codex)
      run_or_echo npm install -g @openai/codex
      ;;
    aider)
      if has_cmd uv; then
        run_or_echo uv tool install aider-chat
      elif has_cmd pipx; then
        run_or_echo pipx install aider-chat
      else
        warn "Cannot install aider: neither uv nor pipx is available."
      fi
      ;;
    gemini)
      run_or_echo npm install -g @google/gemini-cli
      ;;
    ollama)
      run_shell_or_echo "curl -fsSL https://ollama.com/install.sh | sh"
      ;;
    gh)
      local pkg
      pkg="$(pkg_name_for "$PACKAGE_MANAGER" gh)"
      if [[ -n "$pkg" ]]; then
        install_packages "$PACKAGE_MANAGER" "$pkg"
      else
        warn "No package mapping for gh on this platform."
      fi
      ;;
    *)
      warn "Unknown agent tool: $tool"
      ;;
  esac
}

write_plan_md() {
  mkdir -p "$(dirname "$PLAN_MD")"
  if [[ "$DRY_RUN" -eq 1 ]]; then
    log "→ python3 $AUDIT_SCRIPT --plan-md $PLAN_MD"
  else
    python3 "$AUDIT_SCRIPT" --plan-md "$PLAN_MD"
    log "Markdown plan written to: $PLAN_MD"
  fi
}

parse_args() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --dry-run) DRY_RUN=1 ;;
      --non-interactive) NON_INTERACTIVE=1 ;;
      --yes) YES_ALL=1 ;;
      --plan-md) PLAN_MD="$2"; shift ;;
      --with-zsh-bootstrap) BOOTSTRAP_ZSH=1 ;;
      --with-fonts) INSTALL_FONTS=1 ;;
      --skip-terminal-tools) INSTALL_TERMINAL_TOOLS=0 ;;
      --skip-agent-tools) INSTALL_AGENT_TOOLS=0 ;;
      -h|--help) usage; exit 0 ;;
      *) warn "Unknown option: $1"; usage; exit 1 ;;
    esac
    shift
  done
}

check_prerequisites() {
  if ! has_cmd python3 && ! has_cmd python; then
    warn "Python 3 is required for the audit script. Install python3 first."
  fi
  if [[ "$PACKAGE_MANAGER" =~ ^(apt|dnf|yum|pacman)$ ]]; then
    if ! sudo -n true 2>/dev/null; then
      log "Note: some package manager operations may require sudo. You may be prompted."
    fi
  fi
}

main() {
  parse_args "$@"

  log "== Terminal Setup Installer (Unix / WSL / Linux / macOS) =="
  PACKAGE_MANAGER="$(choose_pkg_manager)"
  log "Detected package manager: $PACKAGE_MANAGER"
  check_prerequisites

  if [[ -f "$AUDIT_SCRIPT" ]]; then
    log
    log "Current audit:"
    python3 "$AUDIT_SCRIPT" || true
    write_plan_md
  fi

  if [[ "$INSTALL_FONTS" -eq 1 ]]; then
    log
    log "Nerd Font recommendation: JetBrainsMono Nerd Font"
    log "Unix install hint: download the font release, copy .ttf files to ~/.local/share/fonts, then run fc-cache -fv"
    if grep -qi microsoft /proc/version 2>/dev/null; then
      log "WSL hint: configure the font in Windows Terminal, not inside Linux itself."
    fi
  fi

  SELECTED_TERMINAL_TOOLS=()
  if [[ "$INSTALL_TERMINAL_TOOLS" -eq 1 ]]; then
    for tool in "${CORE_TERMINAL_TOOLS[@]}"; do
      if ! is_installed_tool "$tool"; then
        SELECTED_TERMINAL_TOOLS+=("$tool")
      fi
    done

    if [[ ${#SELECTED_TERMINAL_TOOLS[@]} -gt 0 ]]; then
      log
      log "Missing terminal tools: ${SELECTED_TERMINAL_TOOLS[*]}"
      if ask_yes_no "Install missing terminal tools now?"; then
        packages=()
        for tool in "${SELECTED_TERMINAL_TOOLS[@]}"; do
          pkg="$(pkg_name_for "$PACKAGE_MANAGER" "$tool")"
          if [[ -n "$pkg" ]]; then
            packages+=("$pkg")
          else
            warn "No package mapping for terminal tool '$tool' on $PACKAGE_MANAGER; leaving for manual install."
          fi
        done
        install_packages "$PACKAGE_MANAGER" "${packages[@]}"

        if ! has_cmd starship && [[ " ${SELECTED_TERMINAL_TOOLS[*]} " == *" starship "* ]]; then
          if ask_yes_no "Install Starship with its official installer?"; then
            run_shell_or_echo "curl -fsSL https://starship.rs/install.sh | sh -s -- -y"
          fi
        fi
      fi
    else
      log "All core terminal tools already seem present."
    fi
  fi

  SELECTED_AGENT_TOOLS=()
  if [[ "$INSTALL_AGENT_TOOLS" -eq 1 ]]; then
    for tool in "${AGENT_TOOLS[@]}"; do
      if ! is_installed_tool "$tool"; then
        SELECTED_AGENT_TOOLS+=("$tool")
      fi
    done

    log
    log "Optional agent tools missing: ${SELECTED_AGENT_TOOLS[*]:-none}"
    if [[ ${#SELECTED_AGENT_TOOLS[@]} -gt 0 ]]; then
      if ask_yes_no "Install optional missing agent tools now?"; then
        for tool in "${SELECTED_AGENT_TOOLS[@]}"; do
          if [[ "$tool" =~ ^(opencode|claude|codex|gemini)$ ]] && ! has_cmd npm; then
            warn "Skipping $tool because npm is not available."
            continue
          fi
          if [[ "$tool" == "aider" ]] && ! has_cmd uv && ! has_cmd pipx; then
            warn "Skipping aider because neither uv nor pipx is available."
            continue
          fi
          if ask_yes_no "Install $tool?"; then
            install_agent "$tool"
          fi
        done
      fi
    fi
  fi

  if [[ "$BOOTSTRAP_ZSH" -eq 1 ]]; then
    if ! has_cmd zsh; then
      warn "Zsh is not installed. Install Zsh before applying the Zsh bootstrap scaffold."
    elif ask_yes_no "Run the Zsh bootstrap scaffold now?"; then
      run_or_echo bash "$SCRIPT_DIR/bootstrap_zsh_config.sh"
    fi
  fi

  log
  log "== Post-install verification =="
  python3 "$AUDIT_SCRIPT" || true
  if [[ "$DRY_RUN" -eq 0 ]]; then
    python3 "$AUDIT_SCRIPT" --plan-md "$PLAN_MD" >/dev/null 2>&1 || true
  fi

  log
  log "Next manual steps may still be required:"
  log "- run 'claude' to complete login if Claude Code was installed"
  log "- run 'opencode auth login' if OpenCode was installed"
  log "- run 'hermes setup' if Hermes was installed"
  log "- run 'gemini' to authenticate Gemini CLI if installed"
  log "- run 'ollama pull <model>' if Ollama was installed"
}

main "$@"
