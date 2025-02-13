#!/usr/bin/env bash

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$CURRENT_DIR/utils.sh"
set_bindings

tmux setenv -g ORIGIN_SESSION "$(tmux display -p '#{session_name}')"
if [ -z "$FLOAX_TITLE" ]; then
  FLOAX_TITLE="$DEFAULT_TITLE"
fi
if [ -z "$FLOAX_SESSION_NAME" ]; then
  FLOAX_SESSION_NAME="$DEFAULT_SESSION_NAME"
fi

if [ "$(tmux display-message -p '#{session_name}')" = "$FLOAX_SESSION_NAME" ]; then
  change_popup_title "$FLOAX_TITLE"
  tmux setenv -g FLOAX_TITLE "$FLOAX_TITLE"
  tmux detach-client
else
  create_session
  tmux_popup
fi
