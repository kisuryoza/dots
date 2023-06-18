#!/usr/bin/env bash

SCRIPT="$(realpath -s "${BASH_SOURCE[0]}")"
SCRIPT_DIR=$(dirname "$SCRIPT")
source "$SCRIPT_DIR"/init

function daemomKill {
    if [[ -n "$WAYLAND_DISPLAY" ]]; then
        [[ $(pgrep --exact swww) ]] && swww kill
        [[ $(pgrep --exact swaybg) ]] && pkill --exact swaybg
    fi
}
trap 'daemomKill' EXIT

declare -a FILES

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
    ln -sf "${FILES[i]}" /tmp/wallpaper
    $COMMAND /tmp/wallpaper

    ((i++))
    [[ i -gt ${#FILES[@]} ]] && i=0

    sleep 30
done
