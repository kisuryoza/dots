#!/usr/bin/env zsh

[[ -z "$DEBUG" ]] && DEBUG=false
$DEBUG && set -Eeuxo pipefail

function isWayland {
    [[ $(loginctl show-session self -p Type | awk -F "=" '/Type/ {print $NF}') == "wayland" ]]
}

function lock {
    if isWayland; then
        swaylock -f -c 1a1b26 --ring-color 24283b --key-hl-color bb9af7 --inside-color 1a1b26
    else
        sxlock
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
    if isWayland; then
        grim -g "$(slurp)"
    else
        flameshot gui
    fi
}

function screenshot {
    if isWayland; then
        grim
    else
        flameshot full --clipboard
    fi
}

case $1 in
    "lock")             lock ;;
    "launcher")         launcher ;;
    "screenshot-area")  screenshot_area ;;
    "screenshot")       screenshot ;;
    *) exit 1 ;;
esac
