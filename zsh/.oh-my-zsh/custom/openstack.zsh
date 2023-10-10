export PATH=$PATH:$HOME/.local/bin

BOT_ENV_FILE="$HOME/.oh-my-zsh/custom/korifi-dev-bot.zsh"

openstack-login() {
  if [[ ! -f "$BOT_ENV_FILE" ]]; then
    unset -m "OS_*"
    export OS_AUTH_URL=https://identity-3.eu-de-1.cloud.sap/v3
    export OS_IDENTITY_API_VERSION=3
    export OS_PROJECT_NAME="korifi-dev"
    export OS_PROJECT_DOMAIN_NAME="monsoon3"
    export OS_USER_DOMAIN_NAME="monsoon3"
    export OS_REGION_NAME=eu-de-1
    export OS_COMPUTE_API_VERSION=2.60

    echo Enter your SAP I/D user:
    read -r OS_USERNAME
    export OS_USERNAME
    trap "unset OS_USERNAME" EXIT

    echo Enter the SAP password for $OS_USERNAME:
    read -sr OS_PASSWORD
    export OS_PASSWORD
    trap "unset OS_PASSWORD" EXIT

    bot_secret_id="$(openstack secret list --name korifi-dev-bot -c "Secret href" --format value)"
    if [[ $? -ne 0 ]]; then
        return 1
    fi

    bot_secret=$(openstack secret get -d "$bot_secret_id" -f value)
    if [[ $? -ne 0 ]]; then
        return 1
    fi

    local app_credential_id=$(jq -r .id <<<$bot_secret)
    if [[ $? -ne 0 ]] || [[ "$app_credential_id" == "null" ]]; then
        echo "Failed to get app credential id"
        return 1
    fi
    local app_credential_secret=$(jq -r .secret <<<$bot_secret)
    if [[ $? -ne 0 ]] || [[ "$app_credential_secret" == "null" ]]; then
        echo "Failed to get app credential secret"
        return 1
    fi
   cat << EOF > "$BOT_ENV_FILE"
export OS_AUTH_URL=https://identity-3.eu-de-1.cloud.sap/v3
export OS_AUTH_TYPE=v3applicationcredential
export OS_APPLICATION_CREDENTIAL_ID=$app_credential_id
export OS_APPLICATION_CREDENTIAL_SECRET=$app_credential_secret
EOF
  fi

  unset -m "OS_*"
  source "$HOME/.zshrc"
}

openstack-logout() {
  unset -m "OS_*"
  rm -f "$BOT_ENV_FILE"
}

openstack-secret-create() {
  local name=$1
  shift

  if [[ -z "$name" ]]; then
    echo "Missing secret name"
    echo "Usage: openstack-secret-create <secret-name> [key=value]..."
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
    echo "Usage: openstack-secret-get <secret-name>"
    return 1
  fi

  local id="$(openstack secret list --name $name -c "Secret href" --format value)"
  openstack secret get -d "$id" -f value | jq .
}

openstack-secret-update() {
  local name=$1
  shift
  if [[ -z "$name" ]]; then
    echo "Missing secret name"
    echo "Usage: openstack-secret-update <secret-name> [key=value]..."
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

  if ! openstack secret delete "$id"; then
      echo "Failed to delete secret $name (id=$id)"
      return 1
  fi
  if ! openstack secret store --name $name --secret-type passphrase --payload "$updated_secret_json"; then
    echo "Failed to update secret with name $name with json content:"
    echo "$updated_secret_json" | jq .
    return 1
  fi
}

openstack-secret-delete() {
  local name=$1
  if [[ -z "$name" ]]; then
    echo "Missing secret name"
    echo "Usage: openstack-secret-delete <secret-name>"
    return 1
  fi

  local id="$(openstack secret list --name $name -c "Secret href" --format value)"
  openstack secret delete "$id"
}
