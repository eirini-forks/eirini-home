# Show current kubectl cluster and namespace
precmd_kubectl_context() {
    local context
    RPROMPT=""
    if context="$(kubectl config current-context 2>/dev/null)"; then
      context="$(yq ".contexts | map(select(.name == \"$(kubectl config current-context)\"))| .[].context.cluster" ~/.kube/config)"
      RPROMPT="%{$fg[blue]%}[${context}]%{$reset_color%}"
    fi
}
add-zsh-hook precmd precmd_kubectl_context
