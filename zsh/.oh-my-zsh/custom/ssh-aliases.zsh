alias fixnload='fix-ssh && load-key'

fix-ssh() {
  killall ssh-agent 2>/dev/null
  local ssh_sock
  ssh_sock="$(ls -dt /tmp/ssh*/* | head -1)"
  if [[ -z "$ssh_sock" ]]; then
      eval "$(ssh-agent -s)"
      return
  fi
  export SSH_AUTH_SOCK="$ssh_sock"
}

ssh-agent-socket-available() {
  test -S "$SSH_AUTH_SOCK"
}

pssh() {
  username=$(whoami)
  session=$(tmux display-message -p '#S')
  echo "ssh -A ${username}@${STATION_IP} -t 'tmux a -t ${session}'"
}
