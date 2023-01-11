#!/usr/bin/env bash

if [[ "$1" == "CHILD" ]]; then
    shift
    $0 DAEMON "$@" &
    exit 0
fi

if [[ "$1" != "DAEMON" ]]; then
    setsid "$0" CHILD "$@" &
    exit 0
fi

shift
cd /
umask 0
exec 0<&-
exec 1>&-
exec 2>&-

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
    while true; do
        xkb-switch -w -p | \
            while read -r line; do
                switch_eww "$line"
            done
    done
fi

if [[ "$1" == "wayland" ]]; then
    socat - UNIX-CONNECT:/tmp/hypr/"$HYPRLAND_INSTANCE_SIGNATURE"/.socket2.sock | \
        while read -r line; do
            if [[ "$line" == "activelayout"* ]]; then
                switch_eww "$line"
            fi
        done
fi
