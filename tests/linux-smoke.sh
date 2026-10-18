#!/usr/bin/env bash
set -euo pipefail

dotfiles_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
home_dir="$HOME"
shopt -s nullglob

assert_link() {
  local source_path="$1"
  local target_path="$2"

  [[ -L "$target_path" ]] && [[ "$source_path" -ef "$target_path" ]] ||
    { printf 'Expected link %s -> %s\n' "$target_path" "$source_path" >&2; exit 1; }
}

assert_command() {
  command -v "$1" >/dev/null 2>&1 ||
    { printf 'Expected command not found: %s\n' "$1" >&2; exit 1; }
}

mkdir -p "$home_dir"
printf 'existing vim configuration\n' > "$home_dir/.vimrc"

"$dotfiles_dir/install.sh"

# Standalone installers (bun/uv/fnm/agy) put binaries outside a fresh shell's
# default PATH; a real login shell picks this up via .zshenv, but this smoke
# test runs in plain bash, so export it explicitly before checking commands.
export PATH="$home_dir/.bun/bin:$home_dir/.local/bin:$home_dir/.local/share/fnm:$PATH"

# fnm installs Node under its own prefix; the `default` alias is what
# `fnm env --use-on-cd` resolves to in a real shell.
export PATH="$home_dir/.local/share/fnm/aliases/default/bin:$PATH"

for command in bash bun claude codex copilot curl eza fd fdfind fx fzf gcc gh git go \
  lazygit node nvim rg tree-sitter uv zoxide zsh; do
  assert_command "$command"
done

# `time` is a shell keyword, so command -v can't prove GNU time is installed.
[[ -x /usr/bin/time ]] ||
  { printf 'Expected GNU time at /usr/bin/time\n' >&2; exit 1; }

[[ "$(getent passwd "$(id -un)" | cut -d: -f7)" == "$(command -v zsh)" ]] ||
  { printf 'Expected zsh to be the default shell\n' >&2; exit 1; }

[[ -x "$home_dir/.local/share/fnm/fnm" ]] || command -v fnm >/dev/null 2>&1
[[ -d "$home_dir/.oh-my-zsh" ]]
[[ -d "$home_dir/.oh-my-zsh/custom/plugins/zsh-autosuggestions" ]]
[[ -d "$home_dir/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting" ]]
[[ -d "$home_dir/.oh-my-zsh/custom/plugins/you-should-use" ]]

assert_link "$dotfiles_dir/home/.config/nvim" "$home_dir/.config/nvim"
assert_link "$dotfiles_dir/home/.zshenv" "$home_dir/.zshenv"
assert_link "$dotfiles_dir/home/.zshrc" "$home_dir/.zshrc"
assert_link "$dotfiles_dir/home/.vimrc" "$home_dir/.vimrc"
assert_link "$dotfiles_dir/home/.gitconfig" "$home_dir/.gitconfig"

backups=("$home_dir"/.dotfiles_backup-*)
[[ "${#backups[@]}" -eq 1 ]]
[[ -f "${backups[0]}/.vimrc" ]]
[[ "$(cat "${backups[0]}/.vimrc")" == "existing vim configuration" ]]

# Neovim: nvim-treesitter's main branch compiles parsers in the background, and
# `Lazy! sync` exits 0 even when a parser build fails. Block on install() in the
# same process: quitting early orphans tree-sitter compiles that race a later
# nvim's install of the same parser (ENOTEMPTY on the cache dir). The check
# below uses site/parser, since Nvim bundles its own lua.so in the runtime.
parsers=(lua bash json typescript)
wanted="$(printf '"%s",' "${parsers[@]}")"
echo "linux-smoke: syncing Neovim plugins and parsers..."
timeout 900 nvim --headless "+Lazy! sync" \
  "+lua require('nvim-treesitter').install({${wanted%,}}):wait(600000)" +qa

for parser in "${parsers[@]}"; do
  [[ -f "$home_dir/.local/share/nvim/site/parser/$parser.so" ]] ||
    { printf 'Treesitter parser was not compiled: %s\n' "$parser" >&2; exit 1; }
done

# Rerunning is safe: no duplicate backups, links stay put.
"$dotfiles_dir/install.sh"
backups=("$home_dir"/.dotfiles_backup-*)
[[ "${#backups[@]}" -eq 1 ]]

echo "linux-smoke: OK"
