#!/usr/bin/env bash

cd "$(dirname "${BASH_SOURCE[0]}")" \
  || exit 1

# ------------------------------------------------------------------------------

source "./utils.sh"
source "./spinner.sh"

# ------------------------------------------------------------------------------

declare -r TMP_TOKEN_FILE="$HOME/.vault-token"

declare -r VAULT_ADDR="$(get_tmux_option "@vault-url" "https://vault/")"

declare spinner_pid=""

export VAULT_ADDR

# ------------------------------------------------------------------------------


vault_get_session() {
  cat "$TMP_TOKEN_FILE" 2> /dev/null
}

# ------------------------------------------------------------------------------

main() {
  local -r ACTIVE_PANE="$1"

  local items
  local key
  local username
  local password

  if [[ -z "$(vault_get_session)" ]]; then
    display_message "Vault CLI signin has failed"
    sleep 3
    return 0
  fi

  echo "Inserting a new key into the cubbyhole, will prompt for key, username, and password."
  read -p "Key: " key
  read -p "Username: " username
  read -sp "Password (will be hidden): " password

  vault write cubbyhole/$key username=username password="$password"
}

main "$@"
