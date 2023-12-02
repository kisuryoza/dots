#!/usr/bin/env bash

declare -a LIST
mapfile -t LIST < <(fd -td --max-depth=1 . ~/dots ~/Coding ~/Downloads ~/Anime)
LIST+=(~/dots ~/Coding ~/Downloads ~/Anime)
SELECTED=$(printf "%s\n" "${LIST[@]}" | fzf)
SELECTED_NAME=$(basename "$SELECTED" | tr . _)

if ! tmux has-session -t="$SELECTED_NAME" 2> /dev/null; then
    tmux new-session -ds "$SELECTED_NAME" -c "$SELECTED"
fi

tmux switch-client -t "$SELECTED_NAME"
