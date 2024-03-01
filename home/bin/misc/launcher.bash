#!/usr/bin/env bash

function lock {
    if [[ -n "$WAYLAND_DISPLAY" ]]; then
        swaylock -f -c 1a1b26 --ring-color 24283b --key-hl-color bb9af7 --inside-color 1a1b26
    else
        i3lock -c 1a1b26
    fi
}

function launcher {
    bemenu-run --ignorecase --prompt "" --line-height 35 \
        --fn "DejaVu Sans Mono 12" \
        --fb "#1a1b26" \
        --ff "#e0af68" \
        \
        --nb "#1a1b26" \
        --nf "#c0caf5" \
        \
        --ab "#24283b" \
        --af "#c0caf5" \
        \
        --hb "#1a1b26" \
        --hf "#f7768e"
}

function screenshot_area {
    if [[ -n "$WAYLAND_DISPLAY" ]]; then
        grim -g "$(slurp)"
    else
        flameshot gui
    fi
}

function screenshot {
    if [[ -n "$WAYLAND_DISPLAY" ]]; then
        grim
    else
        flameshot full --clipboard
    fi
}

case $1 in
"lock") lock ;;
"launcher") launcher ;;
"screenshot-area") screenshot_area ;;
"screenshot") screenshot ;;
*) exit 1 ;;
esac
