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
compdef _eza ls

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
alias yi='yarn install && yarn dev'
alias pi='pnpm install && pnpm dev'
alias ni='npm install && npm run dev'

clipf() { wl-copy < "$1" }
clipl() { kitty @ get-text --extent last_cmd_output | wl-copy }
alias clip='wl-copy'
alias x='exit'

eval "$(zoxide init zsh --cmd cd)"
chpwd() { ls }

_dir_icon() {
  case "$PWD" in
    "$HOME")                printf $'\uf015' ;;
    "$HOME/.config"*)       printf $'\uf013' ;;
    "$HOME/Dotfiles"*)      printf $'\uf0ad' ;;
    "$HOME/Documents/mm"*)  printf $'\uf0b1' ;;
    "$HOME/Documents/dev"*) printf $'\uf120' ;;
    *)                      printf $'\uf07b' ;;
  esac
}

_prompt_dir() {
  local icon rel
  case "$PWD" in
    "$HOME")                printf $'\uf015'" ~"; return ;;
    "$HOME/.config"*)       icon=$'\uf013'; rel="${PWD#$HOME/.config}" ;;
    "$HOME/Dotfiles"*)      icon=$'\uf0ad'; rel="${PWD#$HOME/Dotfiles}" ;;
    "$HOME/Documents/mm"*)  icon=$'\uf120'; rel="${PWD#$HOME/Documents/mm}" ;;
    "$HOME/Documents/dev"*) icon=$'\uf0b1'; rel="${PWD#$HOME/Documents/dev}" ;;
    "$HOME"*)               icon=$'\uf07b'; rel="${PWD#$HOME}" ;;
    *)                      icon=$'\uf07b'; rel="$PWD" ;;
  esac
  rel="${rel#/}"
  [[ -z "$rel" ]] && rel="${PWD##*/}"
  printf "%s  %s" "$icon" "$rel"
}

_set_tab_title() {
  local dir="${PWD/#$HOME/~}"
  printf "\033]0;$(_dir_icon) %s\007" "$dir"
}

precmd_functions+=(_set_tab_title)
chpwd_functions+=(_set_tab_title)

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
function rr() {
  if [ -z "$1" ]; then
    echo "Debes proporcionar el nombre de la rama"
    return 1
  fi
  branch_name=$1
 
  git stash drop || true
  git fetch origin
  git stash
 
  if git show-ref --verify --quiet "refs/heads/$branch_name" || git show-ref --verify --quiet "refs/remotes/origin/$branch_name"; then
    git checkout "$branch_name"
  else
    echo "La rama '$branch_name' no existe. Creándola..."
    git checkout -b "$branch_name"
  fi
 
  git stash pop
}


. "$HOME/.local/bin/env"
