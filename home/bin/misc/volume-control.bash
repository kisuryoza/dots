#!/usr/bin/env bash

[[ -z "$DEBUG" ]] && DEBUG=false
$DEBUG && set -Eeuxo pipefail

function toggleMute {
    if eval "$(pamixer --get-mute)"; then
        pamixer --unmute
        eww update isMuted=false
        pamixer --set-volume 100
        eww update volume=100
    else
        pamixer --mute
        eww update isMuted=true
    fi
}

function getVolume {
    pamixer --get-volume
}

function setVolume {
    VAR="$2"
    VAR=${VAR%.*}
    NUM=${VAR:1}
    case ${VAR:0:1} in
    "-")
        CHANGE=$(($(getVolume) - NUM))
        pamixer --set-volume $CHANGE --allow-boost
        eww update volume=$CHANGE
        ;;
    "+")
        CHANGE=$(($(getVolume) + NUM))
        pamixer --set-volume $CHANGE --allow-boost
        eww update volume=$CHANGE
        ;;
    *)
        pamixer --set-volume "$VAR" --allow-boost
        eww update volume=$VAR
        ;;
    esac
}

case $1 in
"get") getVolume ;;
"set") setVolume "$@" ;;
"toggleMute") toggleMute ;;

*) exit 1 ;;
esac
