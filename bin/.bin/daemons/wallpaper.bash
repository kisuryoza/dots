#!/usr/bin/env bash

SCRIPT="$(realpath -s "${BASH_SOURCE[0]}")"
SCRIPT_DIR=$(dirname "$SCRIPT")
source "$SCRIPT_DIR"/init

function daemomKill {
    [[ $(pgrep --exact swww) ]] && swww kill
    [[ $(pgrep --exact swaybg) ]] && pkill --exact swaybg
}
trap 'daemomKill' EXIT

declare -a FILES REFRESH

mapfile -t FILES < <(fd -e jpg -e png -e gif -L . ~/.local/share/wallpapers | sort -R)
if [[ ${#FILES[@]} -eq 0 ]]; then
    exit 1
fi

if [[ -n "$WAYLAND_DISPLAY" ]]; then
    COMMAND="swww img"
    swww init

    # COMMAND="swaybg -m fill -i"
else
    COMMAND="feh --no-fehbg --bg-fill"
fi

i=0
while true; do
    eval "$COMMAND ${FILES[i]}"

    mapfile -t REFRESH < <(fd -e jpg -e png -e gif -L . ~/.local/share/wallpapers)
    if [[ ${#REFRESH[@]} -ne ${#FILES[@]} ]]; then
        mapfile -t FILES < <(shuf -e "${REFRESH[@]}")
        echo "refresh"
    fi

    ((i++))
    [[ i -gt ${#FILES[@]} ]] && i=0

    sleep $((60 * 1))
done
