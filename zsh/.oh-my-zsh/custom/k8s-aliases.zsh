alias k='kubectl'

purge-kubeconfig() {
  kubectl config get-contexts -o name | grep kind- | xargs -n 1 kubectl config delete-context >/dev/null 2>&1 || true
  kubectl config get-clusters | grep kind- | xargs -n 1 kubectl config delete-cluster >/dev/null 2>&1 || true
  kubectl config get-users | grep kind- | xargs -n 1 kubectl config delete-user >/dev/null 2>&1 || true
  kubectl config unset current-context >/dev/null 2>&1 || true

  local context
  context=$(kubectl config get-contexts -o name | head -1)

  if [[ -n "$context" ]]; then
      kubectl config use-context "$context"
  fi
}

kshell() {
  local name image
  name="shell-$(uuidgen | tr '[:upper:]' '[:lower:]')"
  image="${1:-ubuntu}"

  kubectl apply -f - <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: $name
spec:
  containers:
  - name: shell
    image: $image
    command: ["sleep", "infinity"]
EOF
  trap "kubectl delete pod $name --wait=false" EXIT

  kubectl wait "pods/$name" --for condition=Ready --timeout=90s
  kubectl exec --stdin --tty "$name" -- /bin/bash
}
