#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"

# Sourced: install-common.sh's PATH export stays in scope
source "$script_dir/install.sh"

if [[ "$(uname -s)" != "Darwin" ]]; then
    echo "==> Skipping work layer: macOS only."
    exit 0
fi

echo "==> [macOS/Work] Installing GUI apps & Docker..."

# === terminal ===
brew install --cask "wezterm@nightly"   # nightly on purpose; use "wezterm" for stable

# === containers ===
brew install colima             # container runtime for macOS, alternative to docker desktop
brew install docker
brew install docker-buildx      # `docker build` (BuildKit) — needs the links below
brew install docker-compose     # `docker compose` — same

# devcontainer CLI — via bun, not brew: the formula depends_on "node" and would
# pull a second Node.js alongside the fnm-managed one. Same npm package either way.
if ! command -v devcontainer &>/dev/null; then
    bun add --global @devcontainers/cli   # `devcontainer up`/`exec`
fi

# === fun / misc ===
brew tap peonping/tap
brew install peon-ping          # https://www.peonping.com — run `peon-ping-setup` once
brew install cowsay
brew install fortune

# === apps ===
brew install --cask battery             # menu-bar app + CLI: `battery maintain 70-80`
brew install --cask jetbrains-toolbox   # enable "Shell scripts" to get goland/webstorm on PATH
brew install --cask google-chrome
brew install --cask keepassxc
brew install --cask appcleaner
brew install --cask keycastr            # keystroke visualiser
brew install --cask "logi-options+"

# docker-buildx/compose are CLI plugins: `docker` only finds them under
# ~/.docker/cli-plugins. Without these links `docker build` falls back to the
# legacy builder and `docker compose` is missing.
mkdir -p "$HOME/.docker/cli-plugins"
ln -sfn "$(brew --prefix)/lib/docker/cli-plugins/docker-buildx" "$HOME/.docker/cli-plugins/docker-buildx"
ln -sfn "$(brew --prefix)/lib/docker/cli-plugins/docker-compose" "$HOME/.docker/cli-plugins/docker-compose"

echo "==> Work install complete."
