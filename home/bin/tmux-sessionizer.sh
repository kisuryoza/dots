#!/usr/bin/env bash

SELECTED=$(
    (
        echo "$HOME/dots"
        fd -td --max-depth=1 --full-path . ~/dev ~/Sync ~/Anime
    ) | sd "^$HOME/" "" | sk --margin 20% --color="bw"
)

if [[ -z $SELECTED ]]; then
    exit 0
fi

SELECTED="$HOME/$SELECTED"
SELECTED_NAME=$(basename "$SELECTED" | tr . _)
TMUX_RUNNING=$(pgrep tmux)

if ! tmux has-session -t "$SELECTED_NAME" 2>/dev/null; then
    tmux new-session -ds "$SELECTED_NAME" -c "$SELECTED"
fi

tmux switch-client -t "$SELECTED_NAME"
