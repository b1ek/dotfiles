# completions path — load before compinit
fpath+=/usr/share/zsh/site-functions   # apt-installed completions land here
fpath+=/usr/share/zsh-completions      # zsh-completions package (debian/ubuntu)
fpath+=~/.zsh/completions              # personal/manual completions

autoload -Uz compinit && compinit

zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-z}=A-Z'

setopt autocd
setopt share_history hist_ignore_dups

# begin search history
autoload -Uz up-line-or-beginning-search down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey '^[[A' up-line-or-beginning-search
bindkey '^[[B' down-line-or-beginning-search
# end search history

bindkey '^[[3;5~' kill-word
bindkey '^H' backward-kill-word

# begin plugins
vsc() {
    if [[ -z "$VSCODE" ]]; then
        if command -v code &>/dev/null; then
            VSCODE=code
        elif command -v code-insiders &>/dev/null; then
            VSCODE=code-insiders
        elif command -v codium &>/dev/null; then
            VSCODE=codium
        return
        fi
    fi
    $VSCODE "$@" &
    disown
}

add_path() {
    local dir="$1"
    if [[ "$dir" == ~* ]]; then
        dir="${dir/#\~/$HOME}"
    fi
    export PATH="$PATH:$dir"
}
# end plugins

# begin aliases

alias dc='sudo docker compose'
alias dcup='sudo docker compose up'
alias dcupd='sudo docker compose up -d'
alias dcdn='sudo docker compose down'
alias dcb='sudo docker compose build'
alias dcl='sudo docker compose logs'
alias dcln='sudo docker compose logs -fn20'
alias dclf='sudo docker compose logs -f'
alias dclnf='sudo docker compose logs -fn20'
alias dclfn='sudo docker compose logs -fn20'
alias dcr='sudo docker compose restart'
alias dcp='sudo docker compose pull'
alias dce='sudo docker compose exec'
alias dcs='sudo docker compose ps'
alias dcrn='sudo docker compose run'
alias dcrnr='sudo docker compose run --rm'

alias sbx='sbox zsh'
alias sbc='sbox claude'
alias sbd='sbox deepclaude'

# end aliases

add_path ~/.bin

source ~/.zsh/theme.zsh

fastfetch
