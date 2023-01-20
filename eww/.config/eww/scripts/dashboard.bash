#!/usr/bin/env bash

[[ -z "$DEBUG" ]] && DEBUG=false
$DEBUG && set -Eeuxo pipefail

IS_OPEN=$(eww get isDashboardOpen)
if eval "$IS_OPEN"; then
    eww close closer
    eww close dashboard
    eww update isDashboardOpen=false
else
    eww open closer
    eww open dashboard
    eww update isDashboardOpen=true
    eww update brightness_max="$(~/.config/eww/scripts/brightness.bash get-max)"

    # Volume module initialization
    IS_MUTED=$(pamixer --get-mute)
    if eval "$IS_MUTED"; then
        eww update isMuted=true
    else
        eww update isMuted=false
    fi
    eww update volume="$(~/.bin/volume-control.bash get)"

    # Player module initialization
    eww update isMusicPlaying="$(~/.bin/media-player.bash isMusicPlaying)"

    ~/.bin/media-player.bash
fi
