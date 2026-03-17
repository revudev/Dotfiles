export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="af-magic"

plugins=(git zsh-syntax-highlighting zsh-autosuggestions)

source $ZSH/oh-my-zsh.sh

alias ls='ls --color=auto'
alias ll='ls -lah'
alias paci='sudo pacman -Syu'
alias cat='bat'

export SSH_AUTH_SOCK="$HOME/.ssh/agent/ssh.sock"
if ! ssh-add -l &>/dev/null; then
  ssh-agent -a "$SSH_AUTH_SOCK" > /dev/null 2>&1
  ssh-add ~/.ssh/git-personal 2>/dev/null
fi
