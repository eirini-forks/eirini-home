precmd_kubectl_context() {
    RPROMPT=""

    local kubeconfig context
    kubeconfig="${KUBECONFIG:-$HOME/.kube/config}"
    if [[ ! -f "$kubeconfig" ]]; then
        return
    fi

    if context="$(kubectl config current-context 2>/dev/null)"; then
      context="$(yq ".contexts | map(select(.name == \"$(kubectl config current-context)\"))| .[].context.cluster" ${KUBECONFIG:-$HOME/.kube/config})"
      RPROMPT="%{$fg[blue]%}⎈${context}⎈%{$reset_color%}"
    fi
}

add-zsh-hook precmd precmd_kubectl_context
