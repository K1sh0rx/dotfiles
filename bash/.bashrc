
# ~/.bashrc

# ------------------------- INTERACTIVE CHECK ------------------------#
# Exit if not running interactively
[[ $- != *i* ]] && return

# ------------------------- ENVIRONMENT VARIABLES -------------------#

# Editor
export EDITOR=nvim
export VISUAL=nvim

# FZF default options
export FZF_DEFAULT_OPTS='
  --color=bg:#0a0f1f,bg+:#111a33,fg:#c8d3f5,fg+:#ffffff
  --color=hl:#82aaff,hl+:#89ddff,info:#a6accd,prompt:#89ddff,pointer:#ff757f,marker:#c3e88d,spinner:#82aaff
  --border=rounded --layout=reverse --height=65% --prompt="❯ " --margin=1,2 --padding=0,1
'

# Node.js (NVM)
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"

# Pyenv
eval "$(pyenv init -)"

# Rust / Cargo (only if not already loaded)
if ! command -v cargo >/dev/null 2>&1; then
    [ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"
fi

# Go
export PATH="$PATH:$(go env GOPATH)/bin"

# System PATH additions
export PATH="$PATH:/sbin"
export PATH="$HOME/.wasmtime/bin:$PATH"

# ------------------------- ZOXIDE (safe) ---------------------------#
if ! type _zoxide_init >/dev/null 2>&1; then
    export _ZO_DOCTOR=0
    eval "$(zoxide init bash)"
    export _ZO_MATCH_MODE="exact"
fi

# ------------------------- PROMPT / SHELL ---------------------------#
# Starship prompt
eval "$(starship init bash)"
PS1='[\u@\h \W]\$ '

# ------------------------- TOOLS / PLUGINS --------------------------#

# ------------------------- ALIASES ----------------------------------#
[ -f ~/.bash_alias ] && source ~/.bash_alias
[ -f ~/.bash_functions ] && source ~/.bash_functions

# ------------------------- FASTFETCH --------------------------------#
ff

