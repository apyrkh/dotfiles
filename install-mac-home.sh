#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"

source "$script_dir/install-mac-work.sh"

if [[ "$(uname -s)" != "Darwin" ]]; then
    echo "==> Skipping home layer: macOS only."
    exit 0
fi

echo "==> [macOS/Home] Installing personal media & gaming apps..."

# === media processing ===
brew install ffmpeg             # video/audio processing
brew install ghostscript        # pdf processing
brew install pngquant           # lossy png compression
brew install jpegoptim          # jpeg compression
brew install webp               # cwebp/dwebp; was a transitive dep, now explicit
brew install libheif            # heic decoding (iphone photos)

# === cli ===
brew install mtr                # my trace route

# === apps ===
brew install --cask google-drive
brew install --cask notion
brew install --cask chatgpt
brew install --cask opera
brew install --cask adobe-acrobat-reader
brew install --cask iina
brew install --cask obs
brew install --cask upscayl
brew install --cask openmtp             # android-file-transfer
brew install --cask balenaetcher        # flash OS images to SD cards & USB drives

# === fun / misc ===
brew install --cask battle-net
brew install --cask steam
brew install --cask frankea/whisky/whisky
brew install --cask discord
brew install --cask telegram
brew install --cask whatsapp
brew install --cask zoom

# Deliberately not installed:
#   blackhole-2ch      — macOS virtual audio loopback driver, install by hand
#   mongodb-community  — was tapped from mongodb/brew; not used any more
#   mongodb-compass    — same
#   paintbrush         — removed 2026-08-31

echo "==> Home install complete."
