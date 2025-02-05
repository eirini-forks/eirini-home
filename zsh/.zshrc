# Path to oh-my-zsh installation.
export ZSH=$HOME/.oh-my-zsh

ZSH_THEME=""

plugins=(
  docker
  docker-compose
  kubectl
  z
  zsh-autosuggestions
)

source $ZSH/oh-my-zsh.sh

# Set language environment
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# Git duet
export GIT_DUET_ROTATE_AUTHOR=1
export GIT_DUET_GLOBAL=true
export GIT_DUET_CO_AUTHORED_BY=1

# Vim stuff
export PATH=$PATH:$HOME/.gem/ruby/2.5.0/bin

# Custom scripts
export PATH=$HOME/bin:$PATH


# snap
export PATH=$PATH:/snap/bin

# npm
npm_packages="${HOME}/.npm-packages"
export PATH="$PATH:$npm_packages/bin"

# Show non-zero exit status
precmd_pipestatus() {
    local exit_status="${(j.|.)pipestatus}"
    if [[ $exit_status = 0 ]]; then
           return 0
    fi
    echo -n ${exit_status}' '
}

# Set Pure ZSH theme
fpath+=$HOME/.zsh/pure
autoload -U promptinit; promptinit
prompt pure

# Remove pure theme state (user@hostname) from prompt
prompt_pure_state=()

# Show exit code of last command as a separate prompt character
PROMPT='%(?.%F{#32CD32}.%F{red}❯%F{red})❯%f '

# Show exit status before prompt
PROMPT='%F{red}$(precmd_pipestatus)'$PROMPT

# Fuzzy Find
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
export FZF_DEFAULT_OPTS='--height 15% --border'
export FZF_DEFAULT_COMMAND='rg --files --hidden --follow --glob "!.git/*" --glob "!vendor/"'

# Direnv
eval "$(direnv hook zsh)"

# Fix forwarded sockets socket
if ! ssh-agent-socket-available; then
  ensure-ssh-identity
fi

export VAULT_ADDR=https://vault.korifi.cf-app.com:8200
export VAULT_SKIP_VERIFY=true

autoload -U +X bashcompinit && bashcompinit

complete -o nospace -C $(which vault) vault
