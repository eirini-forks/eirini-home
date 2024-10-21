alias fixnload='fix-ssh && load-key'

ensure-ssh-identity() {
  killall ssh-agent 2>/dev/null
  local ssh_sock
  ssh_sock="${1:-$(ls -dt /tmp/ssh*/* | head -1)}"
  if [[ -z "$ssh_sock" ]]; then
      eval "$(ssh-agent -s)"
      return
  fi
  export SSH_AUTH_SOCK="$ssh_sock"
}

fix-ssh() {
  args=()
  ids=()
  for sock in /tmp/ssh*/*; do
    id=$(SSH_AUTH_SOCK=$sock ssh-add -L 2>/dev/null | awk '{ print $3 }')
    if [ -z "$id" ]; then
      continue
    fi
    ids+=("$id")
    args+=(--arg "$id" "$sock")
  done

  socks_by_id="$(jq -n ${args[@]} '$ARGS.named')"

  PS3='Select id: '
  select id in "${ids[@]}"; do
    sock="$(jq -r --arg ID "$id" '.[$ID]' <<<$socks_by_id)"
    if [[ "$sock" != "null" ]]; then
      break
    fi
  done

  ensure-ssh-identity "$sock"
}

ssh-agent-socket-available() {
  test -S "$SSH_AUTH_SOCK"
}

pssh() {
  username=$(whoami)
  session=$(tmux display-message -p '#S')
  echo "ssh -A ${username}@${STATION_IP} -t 'tmux a -t ${session}'"
}
