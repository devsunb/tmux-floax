#!/usr/bin/env bash

envvar_value() {
  tmux showenv -g "$1" | cut -d '=' -f 2-
}

tmux_option_or_fallback() {
  local option_value
  option_value="$(tmux show-option -gqv "$1")"
  if [ -z "$option_value" ]; then
    option_value="$2"
  fi
  echo "$option_value"
}

FLOAX_BORDER=$(envvar_value FLOAX_BORDER)
FLOAX_BORDER_COLOR=$(envvar_value FLOAX_BORDER_COLOR)
FLOAX_X=$(envvar_value FLOAX_X)
FLOAX_Y=$(envvar_value FLOAX_Y)
FLOAX_WIDTH=$(envvar_value FLOAX_WIDTH)
FLOAX_HEIGHT=$(envvar_value FLOAX_HEIGHT)
CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FLOAX_TITLE=$(envvar_value FLOAX_TITLE)
DEFAULT_TITLE=''
FLOAX_SESSION_NAME=$(envvar_value FLOAX_SESSION_NAME)
DEFAULT_SESSION_NAME='scratch'

set_bindings() {
  tmux bind C-M-e run "$CURRENT_DIR/embed.sh embed_or_pop"
  tmux bind C-M-s run "$CURRENT_DIR/zoom-options.sh in"
  tmux bind C-M-b run "$CURRENT_DIR/zoom-options.sh out"
  tmux bind C-M-r run "$CURRENT_DIR/zoom-options.sh reset"
}

unset_bindings() {
  tmux unbind C-M-e
  tmux unbind C-M-s
  tmux unbind C-M-b
  tmux unbind C-M-r
}

create_session() {
  if ! tmux has-session -t "$FLOAX_SESSION_NAME" 2>/dev/null; then
    tmux new-session -d -c "$(tmux display-message -p '#{pane_current_path}')" -s "$FLOAX_SESSION_NAME"
  fi
}

move_window() {
  FROM_WINDOW="$1"
  TO_SESSION="$2"
  TO_WIN_NUM="$(($(tmux list-windows -t "$TO_SESSION" | wc -l) + 1))"
  tmux neww -t "$TO_SESSION:$TO_WIN_NUM"
  tmux swapw -s "$FROM_WINDOW" -t "$TO_SESSION:$TO_WIN_NUM"
  tmux killw -t "$FROM_WINDOW"
}

tmux_popup() {
  FLOAX_WIDTH=$(envvar_value FLOAX_WIDTH)
  FLOAX_HEIGHT=$(envvar_value FLOAX_HEIGHT)

  FLOAX_TITLE=$(envvar_value FLOAX_TITLE)
  if [ -z "$FLOAX_TITLE" ]; then
    FLOAX_TITLE="$DEFAULT_TITLE"
  fi

  FLOAX_SESSION_NAME=$(envvar_value FLOAX_SESSION_NAME)
  if [ -z "$FLOAX_SESSION_NAME" ]; then
    FLOAX_SESSION_NAME="$DEFAULT_SESSION_NAME"
  fi

  tmux set-option -t "$FLOAX_SESSION_NAME" detach-on-destroy on
  tmux popup \
    -T "$FLOAX_TITLE" \
    -x "$FLOAX_X" \
    -y "$FLOAX_Y" \
    -w "$FLOAX_WIDTH" \
    -h "$FLOAX_HEIGHT" \
    -b "$FLOAX_BORDER" \
    -S fg="$FLOAX_BORDER_COLOR" \
    -E "tmux attach-session -t \"$FLOAX_SESSION_NAME\""
}
