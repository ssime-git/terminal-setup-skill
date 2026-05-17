#!/usr/bin/env bash
set -euo pipefail

BACKUP_DIR="${BACKUP_DIR:-$HOME/.terminal-backup-$(date +%Y%m%d-%H%M%S)}"
mkdir -p "$BACKUP_DIR"

echo "== Backing up current shell config to $BACKUP_DIR =="

cp "$HOME/.zshrc" "$BACKUP_DIR/zshrc" 2>/dev/null && echo "  backed up: ~/.zshrc" || echo "  skip: ~/.zshrc not found"
cp -r "$HOME/.oh-my-zsh/custom" "$BACKUP_DIR/oh-my-zsh-custom" 2>/dev/null && echo "  backed up: ~/.oh-my-zsh/custom" || echo "  skip: ~/.oh-my-zsh/custom not found"
[ -d "$HOME/.config/zsh" ] && cp -r "$HOME/.config/zsh" "$BACKUP_DIR/config-zsh" && echo "  backed up: ~/.config/zsh" || echo "  skip: ~/.config/zsh not found"
[ -f "$HOME/.zshenv" ] && cp "$HOME/.zshenv" "$BACKUP_DIR/zshenv" && echo "  backed up: ~/.zshenv" || echo "  skip: ~/.zshenv not found"

echo "Backup complete: $BACKUP_DIR"
echo "Restore with: cp $BACKUP_DIR/zshrc ~/.zshrc"
