#!/usr/bin/env bash

SCRIPT="$(realpath -s "${BASH_SOURCE[0]}")"
SCRIPT_DIR=$(dirname "$SCRIPT")
source "$SCRIPT_DIR"/init

while true; do
    sleep $((60 * 30))

    [[ $(pgrep --exact dunst) ]] && notify-send -i " " "$USER" "fix the poisture"
done
