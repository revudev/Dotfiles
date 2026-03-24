export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="af-magic"

plugins=(git zsh-syntax-highlighting zsh-autosuggestions)

ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#565f89"
ZSH_AUTOSUGGEST_STRATEGY=(history completion)

source $ZSH/oh-my-zsh.sh

alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

alias ls='eza --color=always --group-directories-first --icons'
alias ll='eza -la --color=always --group-directories-first --icons'
alias la='eza -a --color=always --group-directories-first --icons'
alias lt='eza -aT --color=always --group-directories-first --icons --level=2'

alias cat='bat'

alias df='df -h'
alias du='du -sh'
alias mkdir='mkdir -pv'
alias grep='rg'
alias ip='ip --color=auto'
alias diff='diff --color'
alias cp='cp -iv'
alias mv='mv -iv'
alias find='fd'

source /usr/share/fzf/key-bindings.zsh
source /usr/share/fzf/completion.zsh
export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border --color=bg+:#1e2030,bg:#1a1b26,spinner:#bb9af7,hl:#7aa2f7,fg:#c0caf5,header:#7aa2f7,info:#bb9af7,pointer:#bb9af7,marker:#9ece6a,prompt:#bb9af7,hl+:#7aa2f7'
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

eval "$(thefuck --alias)"

alias paci='sudo pacman -Syu'
alias pacr='sudo pacman -Rns'
alias pacs='pacman -Ss'
alias pacq='pacman -Qi'

alias yayi='yay -Syu'
alias yayr='yay -Rns'
alias yays='yay -Ss'
alias yayq='yay -Qi'

alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git log --oneline --graph --decorate --all'
alias copi='GITHUB_TOKEN='' copilot'
alias cla='codemie-claude'

clipf() { wl-copy < "$1" }
clipl() { kitty @ get-text --extent last_cmd_output | wl-copy }
alias clip='wl-copy'
alias x='exit'

alias vps='ssh deru'

alias reload='source ~/.zshrc'
alias zshrc='$EDITOR ~/.zshrc'
alias top='btop'

export SSH_AUTH_SOCK="$HOME/.ssh/agent/ssh.sock"
if ! ssh-add -l &>/dev/null; then
  ssh-agent -a "$SSH_AUTH_SOCK" > /dev/null 2>&1
  ssh-add ~/.ssh/git-personal 2>/dev/null
fi

[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local
export PATH="$HOME/.npm-global/bin:$PATH"

copilot() { gh copilot "$@"; }

. "$HOME/.local/bin/env"
