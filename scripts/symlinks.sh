#!/usr/bin/env bash
set -euo pipefail

dotfiles_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
source_home="$dotfiles_dir/home"
backup_dir=""

info() { printf '==> %s\n' "$*"; }
die()  { printf 'Error: %s\n' "$*" >&2; exit 1; }

# Tracked configuration: zsh, neovim, wezterm, git, and Claude assets.
files=(
    ".claude/CLAUDE.md"
    ".claude/skills/bun-performance"
    ".claude/skills/compress-media"
    ".claude/statusline.js"
    ".config/nvim"
    ".config/wezterm"
    ".config/zsh"
    ".gitconfig"
    ".vimrc"
    ".zshenv"
    ".zshrc"
)

create_backup_dir() {
    if [[ -z "$backup_dir" ]]; then
        backup_dir="$HOME/.dotfiles_backup-$(date +%Y%m%d_%H%M%S)"
        mkdir -p "$backup_dir"
    fi
}

info "Linking managed configuration"

for file in "${files[@]}"; do
    source_path="$source_home/$file"
    target_path="$HOME/$file"

    [[ -e "$source_path" ]] || die "managed source is missing: $source_path"

    if [[ -L "$target_path" ]] && [[ "$source_path" -ef "$target_path" ]]; then
        info "Up to date: ~/$file"
        continue
    fi

    mkdir -p "$(dirname "$target_path")"

    if [[ -e "$target_path" || -L "$target_path" ]]; then
        create_backup_dir
        mkdir -p "$backup_dir/$(dirname "$file")"
        mv "$target_path" "$backup_dir/$file"
        info "Backed up: ~/$file"
    fi

    ln -s "$source_path" "$target_path"
    info "Linked: ~/$file"
done

# Paths this repo used to manage. Their links would dangle forever on machines
# installed before the file was dropped (zsh silently skips a dangling
# ~/.zprofile - which is how Homebrew fell off PATH). Only links pointing into
# this repo are removed; real files are left alone.
obsolete=(
    ".zprofile"
)

for file in "${obsolete[@]}"; do
    target_path="$HOME/$file"
    if [[ -L "$target_path" ]] && [[ "$(readlink "$target_path")" == "$source_home/"* ]]; then
        rm "$target_path"
        info "Removed obsolete link: ~/$file"
    fi
done

if [[ -n "$backup_dir" ]]; then
    info "Backups saved to: $backup_dir"
fi
