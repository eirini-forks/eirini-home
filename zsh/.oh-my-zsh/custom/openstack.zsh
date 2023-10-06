export PATH=$PATH:$HOME/.local/bin

alias openstacksecret-create="openstack-secret-create"
alias openstacksecret-get="openstack-secret-get"
alias openstacksecret-update="openstack-secret-update"
alias openstacksecret-delete="openstack-secret-delete"

openstack-secret-create() {
  local name=$1
  shift

  if [[ -z "$name" ]]; then
    echo "Missing secret name"
    echo "Usage: openstacksecret-create <secret-name> [key=value]..."
    return 1
  fi

  local id="$(openstack secret list --name $name -c "Secret href" --format value)"
  if [[ -n $id ]]; then
      echo Secret with name $name already exists
      return 1
  fi

  args=()
  for kv in "$@"; do
    key=$(cut -d = -f 1 <<<$kv)
    value=$(cut -d = -f 2 <<<$kv)
    args+=(--arg $key $value)
  done

  openstack secret store --name $name --secret-type passphrase --payload "$(jq -n ${args[@]} '$ARGS.named')"
}

openstack-secret-get() {
  local name=$1
  if [[ -z "$name" ]]; then
    echo "Missing secret name"
    echo "Usage: openstacksecret-get <secret-name>"
    return 1
  fi

  local id="$(openstack secret list --name $1 -c "Secret href" --format value)"
  openstack secret get -d "$id" -f value | jq .
}

openstack-secret-update() {
  local name=$1
  shift
  if [[ -z "$name" ]]; then
    echo "Missing secret name"
    echo "Usage: openstacksecret-update <secret-name> [key=value]..."
    return 1
  fi

  local args=""
  local i=0
  for kv in "$@"; do
    local key=$(cut -d = -f 1 <<<$kv)
    local value=$(cut -d = -f 2 <<<$kv)
    args+=".$key = \"$value\""
    if (($i < ($# - 1))); then
      args+=" | "
    fi
    i=$((i + 1))
  done

  local id="$(openstack secret list --name $name -c "Secret href" --format value)"
  local secret_json=$(openstack secret get -d "$id" -f value)
  local updated_secret_json="$(jq "$args" <<<$secret_json)"

  openstack secret delete "$id"
  if ! openstack secret store --name $name --secret-type passphrase --payload "$updated_secret_json"; then
    echo Failed to update secret with name $name with json content:
    echo $updated_secret_json | jq .
  fi
}

openstack-secret-delete() {
  local name=$1
  if [[ -z "$name" ]]; then
    echo "Missing secret name"
    echo "Usage: openstacksecret-delete <secret-name>"
    return 1
  fi

  local id="$(openstack secret list --name $name -c "Secret href" --format value)"
  openstack secret delete "$id"
}
