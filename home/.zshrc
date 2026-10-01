# === OH MY ZSH CORE ===
export ZSH="$HOME/.oh-my-zsh"

# https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="half-life" # current
# ZSH_THEME="robbyrussell" # default

# === PLUGINS ===
# Manually installed plugins in $ZSH_CUSTOM/plugins:
# - you-should-use
# - zsh-autosuggestions
# - zsh-syntax-highlighting
plugins=(
  gitfast                   # completion for git
  history                   # command line history
  you-should-use
  zsh-autosuggestions
  zsh-syntax-highlighting
)

if (( $+commands[cowsay] && $+commands[fortune] )); then
  plugins=(chucknorris "${plugins[@]}")
fi

zstyle ":omz:update" mode auto
zstyle ":omz:update" frequency 7

# === LOAD OhMyZsh
source $ZSH/oh-my-zsh.sh

# === SHELL OPTIONS ===
setopt NO_BEEP
setopt HIST_IGNORE_ALL_DUPS
setopt COMBINING_CHARS  # correct combining-char display; was set by /etc/zshrc

# === USER CONFIGURATION ===
export EDITOR="nvim"

# === TOOLS INIT ===
command -v zoxide >/dev/null && eval "$(zoxide init zsh)"
command -v fnm >/dev/null && eval "$(fnm env --use-on-cd)"
[ -s "$BUN_INSTALL/_bun" ] && source "$BUN_INSTALL/_bun"  # bun completions

# === ALIASES ===
alias ll="eza -l --group-directories-first --icons"
alias lla="ll -a"
cpwd() {
  if command -v pbcopy >/dev/null; then
    pwd | pbcopy
  elif command -v wl-copy >/dev/null; then
    pwd | wl-copy
  elif command -v xclip >/dev/null; then
    pwd | xclip -selection clipboard
  else
    echo "No clipboard provider is available" >&2
    return 1
  fi

  echo "Copied to clipboard"
}

alias v="nvim"
vv() {
  NVIM_APPNAME=ndev \
  nvim "$@"
}
# vv() {
#   VIMRUNTIME=~/@Projects/github.com/neovim/neovim/runtime \
#   NVIM_APPNAME=ndev \
#   ~/@Projects/github.com/neovim/neovim/build/bin/nvim "$@"
# }

# === CUSTOM SCRIPTS ===
source ~/.config/zsh/scripts/timed.zsh  # time wrapper with formatted output (timed)

# === LOCAL OVERRIDES ===
[ -f "$HOME/.zshrc.local" ] && source "$HOME/.zshrc.local"
