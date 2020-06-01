#!/usr/bin/env bash

cd "$(dirname "${BASH_SOURCE[0]}")" \
  || exit 1

# ------------------------------------------------------------------------------

source "./utils.sh"
source "./spinner.sh"

# ------------------------------------------------------------------------------

declare -r TMP_TOKEN_FILE="$HOME/.vault-token"

declare -r VAULT_ADDR="$(get_tmux_option "@vault-url" "https://vault/")"
declare -r OPT_LOGIN_METHOD="$(get_tmux_option "@vault-login-method" "userpass")"
declare -r OPT_COPY_TO_CLIPBOARD="$(get_tmux_option "@vault-copy-to-clipboard" "off")"
declare -r OPT_ITEMS_JQ_FILTER="$(get_tmux_option "@vault-items-jq-filter" "")"

declare spinner_pid=""

export VAULT_ADDR

# ------------------------------------------------------------------------------

spinner_start() {
  tput civis
  show_spinner "$1" &
  spinner_pid=$!
}

spinner_stop() {
  tput cnorm
  kill "$spinner_pid" &> /dev/null
  spinner_pid=""
}

# ------------------------------------------------------------------------------

vault_login() {
  echo "Username:"
  read username
  vault login -method="$OPT_LOGIN_METHOD" username=$username
  tput clear
}

vault_get_session() {
  cat "$TMP_TOKEN_FILE" 2> /dev/null
}

get_vault_items() {
  vault list -format=json cubbyhole | jq -r '.[]'
}

get_vault_item_password() {
  local -r ITEM_UUID="$1"
  vault read -format=json cubbyhole/$ITEM_UUID | jq -r '.data.password'
}

# ------------------------------------------------------------------------------

main() {
  local -r ACTIVE_PANE="$1"

  local items
  local selected_item_name
  local selected_item_uuid
  local selected_item_password

  spinner_start "Fetching items"
  items="$(get_vault_items)"
  spinner_stop

  if [[ -z "$items" ]]; then

    # Needs to login
    vault_login

    if [[ -z "$(vault_get_session)" ]]; then
      display_message "Vault CLI signin has failed"
      sleep 3
      return 0
    fi

    spinner_start "Fetching items"
    items="$(get_vault_items)"
    spinner_stop
  fi

  selected_item_name="$(echo "$items" | awk -F ',' '{ print $1 }' | fzf --no-multi)"

  if [[ -n "$selected_item_name" ]]; then
    spinner_start "Fetching password"
    selected_item_password="$(get_vault_item_password "$selected_item_name")"
    spinner_stop

    if [[ "$OPT_COPY_TO_CLIPBOARD" == "on" ]]; then

      # Copy password to clipboard
      copy_to_clipboard "$selected_item_password"

      # Clear clipboard
      clear_clipboard 30
    else

      # Use `send-keys`
      tmux send-keys -t "$ACTIVE_PANE" "$selected_item_password"
    fi
  fi
}

main "$@"
