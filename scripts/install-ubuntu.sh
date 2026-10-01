#!/usr/bin/env bash
set -euo pipefail

echo "==> [Linux/DevContainer] Installing Base CLI tools via apt-get & standalone installers..."

# `sudo` drops env vars, so DEBIAN_FRONTEND must be passed via `sudo env ...`
# (see apt_install) to stop debconf prompts like tzdata's. Default tz is Etc/UTC.
export DEBIAN_FRONTEND=noninteractive

# Standalone installers drop binaries here; put them on PATH so rerun checks
# and the `fd` alias resolve.
export PATH="$HOME/.bun/bin:$HOME/.local/bin:$HOME/.local/share/fnm:$PATH"
mkdir -p "$HOME/.local/bin"

# One-line wrapper so each category below reads like the macOS script.
apt_install() {
    sudo env DEBIAN_FRONTEND=noninteractive apt-get install -y "$@"
}

sudo env DEBIAN_FRONTEND=noninteractive apt-get update -y

# === prerequisites ===
# macOS has no equivalent section: Homebrew requires the Xcode command line
# tools, which already provide curl, git and a compiler.
apt_install ca-certificates
apt_install curl                # every standalone installer below is `curl | sh`
apt_install git
apt_install build-essential     # compiles Treesitter parsers and native modules
apt_install unzip

# === fonts ===
# None. The container has no GUI, so the Nerd Font is installed on the macOS
# host only — your terminal renders the glyphs, not the machine you ssh into.

# === shell ===
apt_install zsh
# Make zsh the login shell so `devcontainer exec` and VS Code terminals land
# in the configured shell instead of bash.
current_user="$(id -un)"
if [[ "$(getent passwd "$current_user" | cut -d: -f7)" != "$(command -v zsh)" ]]; then
    echo "==> Setting zsh as the default shell..."
    sudo chsh -s "$(command -v zsh)" "$current_user"
fi

# === dev tools ===
apt_install cmake
apt_install golang-go

# fnm — not packaged for Ubuntu; use its own installer
if ! command -v fnm &>/dev/null; then
    echo "==> Installing FNM..."
    curl -fsSL https://fnm.vercel.app/install | bash -s -- --skip-shell
fi

# uv — not packaged for Ubuntu; use its own installer
if ! command -v uv &>/dev/null; then
    echo "==> Installing UV..."
    curl -LsSf https://astral.sh/uv/install.sh | sh
fi

apt_install postgresql-client   # psql, pg_dump — macOS gets these from libpq

# === neovim (runtime deps) ===
# apt's Neovim is too old, so grab the latest release tarball. Keep it intact
# (nvim locates runtime/ relative to the real binary): unpack to ~/.local/share,
# symlink only the binary into ~/.local/bin.
if ! command -v nvim &>/dev/null; then
    echo "==> Installing Neovim..."
    arch="$(uname -m)"; [[ "$arch" == "aarch64" ]] && arch="arm64" || arch="x86_64"
    mkdir -p "$HOME/.local/share"
    rm -rf "$HOME/.local/share/nvim-linux-${arch}"
    curl -fsSL "https://github.com/neovim/neovim/releases/latest/download/nvim-linux-${arch}.tar.gz" \
        | tar -xz -C "$HOME/.local/share"
    ln -sf "$HOME/.local/share/nvim-linux-${arch}/bin/nvim" "$HOME/.local/bin/nvim"
fi

# tree-sitter-cli — not in apt; single gzipped binary
if ! command -v tree-sitter &>/dev/null; then
    echo "==> Installing tree-sitter-cli..."
    arch="$(uname -m)"; [[ "$arch" == "aarch64" ]] && arch="arm64" || arch="x64"
    curl -fsSL "https://github.com/tree-sitter/tree-sitter/releases/latest/download/tree-sitter-linux-${arch}.gz" \
        | gunzip > "$HOME/.local/bin/tree-sitter"
    chmod +x "$HOME/.local/bin/tree-sitter"
fi
apt_install luarocks
apt_install fzf
apt_install fd-find             # ships the binary as "fdfind" (name clash), aliased below
if ! command -v fd &>/dev/null; then
    ln -sf "$(command -v fdfind)" "$HOME/.local/bin/fd"
fi
apt_install ripgrep

# === cli ===
# git is installed in prerequisites above - the curl installers need it there.
apt_install gh                  # GitHub CLI
# lazygit — not in apt; the release URL needs the version number, so look it up
if ! command -v lazygit &>/dev/null; then
    echo "==> Installing lazygit..."
    arch="$(uname -m)"; [[ "$arch" == "aarch64" ]] && arch="arm64" || arch="x86_64"
    lazygit_version="$(curl -fsSL "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | sed -n 's/.*"tag_name": *"v\([^"]*\)".*/\1/p')"
    curl -fsSL "https://github.com/jesseduffield/lazygit/releases/download/v${lazygit_version}/lazygit_${lazygit_version}_linux_${arch}.tar.gz" \
        | tar -xz -C "$HOME/.local/bin" lazygit
fi

apt_install git-filter-repo     # rewrite history across all commits (purge a secret, drop refs)
apt_install tree
# eza — not in apt; tarball with a single binary inside
if ! command -v eza &>/dev/null; then
    echo "==> Installing eza..."
    arch="$(uname -m)"; [[ "$arch" == "aarch64" ]] && arch="aarch64" || arch="x86_64"
    curl -fsSL "https://github.com/eza-community/eza/releases/latest/download/eza_${arch}-unknown-linux-gnu.tar.gz" \
        | tar -xz -C "$HOME/.local/bin" ./eza
fi

apt_install zoxide              # zi
# fx — not in apt; raw static binary, no archive
if ! command -v fx &>/dev/null; then
    echo "==> Installing fx..."
    arch="$(uname -m)"; [[ "$arch" == "aarch64" ]] && arch="arm64" || arch="amd64"
    curl -fsSL "https://github.com/antonmedv/fx/releases/latest/download/fx_linux_${arch}" \
        -o "$HOME/.local/bin/fx"
    chmod +x "$HOME/.local/bin/fx"
fi

apt_install time                # /usr/bin/time; macOS gets this as gnu-time

# No macOS counterpart - the Mac gets these for free:
apt_install sqlite3             # macOS ships /usr/bin/sqlite3
apt_install xclip               # clipboard provider; macOS has pbcopy

# Each block re-detects `uname -m` its own way — upstreams disagree on arch
# names (arm64 / aarch64 / x64 / x86_64 / amd64). Not worth factoring out.
#
# Deliberately not installed:
#   font-*    — no GUI in the container; see the fonts section above
#   libpq     — apt's postgresql-client covers psql/pg_dump
#   bun       — scripts/install-common.sh uses bun's own installer, as on macOS
