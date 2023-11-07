precmd_kubectl_context() {
  local lineup=$'\e[1A'
  local linedown=$'\e[1B'

  RPROMPT=""

  local kubeconfig context
  kubeconfig="${KUBECONFIG:-$HOME/.kube/config}"
  if [[ ! -f "$kubeconfig" ]]; then
    return
  fi

  if context="$(kubectl config current-context 2>/dev/null)"; then
    context="$(yq ".contexts | map(select(.name == \"$(kubectl config current-context)\"))| .[].context.cluster" ${KUBECONFIG:-$HOME/.kube/config})"
    RPROMPT="%{${lineup}%}%{$fg[blue]%}⎈${context}⎈%{$reset_color%}%{${linedown}%}"
  fi
}

add-zsh-hook precmd precmd_kubectl_context
