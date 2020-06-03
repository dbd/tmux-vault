#!/usr/bin/env bash

cd "$(dirname "${BASH_SOURCE[0]}")" \
  || exit 1

source "./scripts/utils.sh"

declare -r CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

declare -a REQUIRED_COMMANDS=(
  'vault'
  'jq'
  'fzf'
)

main() {
  for cmd in "${REQUIRED_COMMANDS[@]}"; do
    if ! is_cmd_exists "$cmd"; then
      display_message "command '$cmd' not found"
      return 1
    fi
  done

  local -r opt_key="$(get_tmux_option "@vault-key" "u")"
  local -r opt_new_key="$(get_tmux_option "@vault-new-key" "N")"

  tmux bind-key "$opt_key" \
    run "tmux split-window -l 10 \"$CURRENT_DIR/scripts/main.sh '#{pane_id}'\""

  tmux bind-key "$opt_new_key" \
    run "tmux split-window -l 10 \"$CURRENT_DIR/scripts/new.sh '#{pane_id}'\""
}

main "$@"
