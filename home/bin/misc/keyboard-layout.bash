#!/usr/bin/env bash

source ~/bin/daemons/init

function switch_eww {
    case "$1" in
    "us" | *"English"*)
        eww update keyboardLayout="US"
        ;;
    "ru" | *"Russian"*)
        eww update keyboardLayout="RU"
        ;;
    esac
}

if [[ "$1" == "x" ]]; then
    xkb-switch -W |
        while read -r line; do
            switch_eww "$line"
        done
fi

if [[ "$1" == "wayland" ]]; then
    socat - UNIX-CONNECT:/tmp/hypr/"$HYPRLAND_INSTANCE_SIGNATURE"/.socket2.sock |
        while read -r line; do
            if [[ "$line" == "activelayout"* ]]; then
                switch_eww "$line"
            fi
        done
fi
