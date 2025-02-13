#!/usr/bin/env bash

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$CURRENT_DIR/utils.sh"

embed() {
  number_of_windows=$(tmux list-windows -t "$FLOAX_SESSION_NAME" | wc -l)
  move_window "$(tmux display -p '#{session_name}:#I')" "$ORIGIN_SESSION"
  if [ "$number_of_windows" -ne 1 ]; then
    tmux detach-client
  fi
}

pop() {
  ORIGIN_SESSION="$(tmux display -p '#{session_name}')"
  ORIGIN_WINDOW="$(tmux display -p '#I')"
  create_session
  move_window "$ORIGIN_SESSION:$ORIGIN_WINDOW" "$FLOAX_SESSION_NAME"
  tmux setenv -g ORIGIN_SESSION "$ORIGIN_SESSION"
  tmux_popup
}

embed_or_pop() {
  if [ "$(tmux display-message -p '#{session_name}')" = "$FLOAX_SESSION_NAME" ]; then
    embed
  else
    pop
  fi
}

action=$1
case "$action" in
embed)
  embed
  ;;
pop)
  pop
  ;;
embed_or_pop)
  embed_or_pop
  ;;
esac

ORIGIN_SESSION="$(envvar_value ORIGIN_SESSION)"
