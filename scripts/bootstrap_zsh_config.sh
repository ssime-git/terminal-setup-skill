#!/usr/bin/env bash
set -euo pipefail

ZDOTDIR="${ZDOTDIR:-$HOME/.config/zsh}"
mkdir -p "$ZDOTDIR"
mkdir -p "$HOME/.cache/zsh" "$HOME/.local/state/zsh"

write_if_missing() {
  local path="$1"
  local content="$2"
  if [[ -e "$path" ]]; then
    echo "skip: $path already exists"
  else
    printf '%s' "$content" > "$path"
    echo "created: $path"
  fi
}

write_if_missing "$HOME/.zshenv" 'export XDG_CONFIG_HOME="$HOME/.config"\nexport XDG_CACHE_HOME="$HOME/.cache"\nexport XDG_STATE_HOME="$HOME/.local/state"\nexport ZDOTDIR="$XDG_CONFIG_HOME/zsh"\n'

write_if_missing "$ZDOTDIR/.zshenv" 'export EDITOR="${EDITOR:-vim}"\nexport GPG_TTY=$(tty)\nexport PATH="$HOME/.local/bin:$PATH"\nexport STARSHIP_CONFIG="$ZDOTDIR/starship.toml"\n'

write_if_missing "$ZDOTDIR/.zshrc" '# history\nHISTFILE="$XDG_STATE_HOME/zsh/history"\nHISTSIZE=100000\nSAVEHIST=100000\nsetopt APPEND_HISTORY SHARE_HISTORY HIST_IGNORE_DUPS HIST_IGNORE_SPACE HIST_EXPIRE_DUPS_FIRST HIST_FIND_NO_DUPS\nsetopt AUTO_CD NO_BEEP NUMERIC_GLOB_SORT\n\nautoload -Uz compinit\ncompinit -d "$XDG_CACHE_HOME/zsh/zcompdump"\nzstyle '"'"':completion:*'"'"' menu select\n\ncommand -v zoxide >/dev/null 2>&1 && eval "$(zoxide init zsh)"\n\nfor base in /usr/share/fzf /opt/homebrew/opt/fzf/shell /usr/local/opt/fzf/shell; do\n  [ -f "$base/key-bindings.zsh" ] && source "$base/key-bindings.zsh"\n  [ -f "$base/completion.zsh" ] && source "$base/completion.zsh"\ndone\n\n[ -f "$ZDOTDIR/aliases.zsh" ] && source "$ZDOTDIR/aliases.zsh"\n[ -f "$ZDOTDIR/fzf.zsh" ] && source "$ZDOTDIR/fzf.zsh"\n[ -f "$ZDOTDIR/prompt.zsh" ] && source "$ZDOTDIR/prompt.zsh"\n'

write_if_missing "$ZDOTDIR/aliases.zsh" 'command -v eza >/dev/null 2>&1 && alias ls="eza --icons"\ncommand -v eza >/dev/null 2>&1 && alias ll="eza --icons -lh"\ncommand -v eza >/dev/null 2>&1 && alias la="eza --icons -lha"\ncommand -v eza >/dev/null 2>&1 && alias tree="eza --icons --tree"\ncommand -v rg >/dev/null 2>&1 && alias grep="rg"\ncommand -v fd >/dev/null 2>&1 && alias find="fd"\ncommand -v fdfind >/dev/null 2>&1 && alias find="fdfind"\ncommand -v bat >/dev/null 2>&1 && alias cat="bat"\ncommand -v batcat >/dev/null 2>&1 && alias cat="batcat"\nalias -=\"cd -\"\n'

write_if_missing "$ZDOTDIR/fzf.zsh" 'export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border"\ncommand -v bat >/dev/null 2>&1 && export FZF_CTRL_T_OPTS="--preview '\''bat --style=numbers --color=always {}'\''"\n'

write_if_missing "$ZDOTDIR/prompt.zsh" 'command -v starship >/dev/null 2>&1 && eval "$(starship init zsh)"\n'

write_if_missing "$ZDOTDIR/starship.toml" 'add_newline = false\nformat = "$directory$git_branch$git_status$python$nodejs$character"\n\n[directory]\nstyle = "blue bold"\n\n[git_branch]\nsymbol = " "\nstyle = "purple bold"\n\n[git_status]\nstyle = "red bold"\n\n[python]\nsymbol = " "\nstyle = "yellow"\n\n[nodejs]\nsymbol = " "\nstyle = "green"\n\n[character]\nsuccess_symbol = "[❯](bold green)"\nerror_symbol = "[❯](bold red)"\n'

echo
echo "Minimal Zsh scaffold ready in $ZDOTDIR"
echo "Reload with: source $ZDOTDIR/.zshrc"
