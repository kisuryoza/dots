#!/usr/bin/env bash

# The script does not support external monitors
if [[ -z $(fd -1 . /sys/class/backlight/) ]]; then
    echo 100
    exit 0
fi

function getBrightness {
    cat /sys/class/backlight/*/brightness
}

function getBrightnessMax {
    cat /sys/class/backlight/*/max_brightness
}

function setBrightness {
    VAR="$2"
    VAR=${VAR%.*}
    NUM=${VAR:1}
    case ${VAR:0:1} in
    "-")
        CHANGE=$(($(getBrightness) - NUM))
        if [[ $CHANGE -lt 0 ]]; then
            CHANGE=0
        fi
        echo $CHANGE >/sys/class/backlight/*/brightness
        ;;
    "+")
        CHANGE=$(($(getBrightness) + NUM))
        if [[ $CHANGE -gt $(getBrightnessMax) ]]; then
            CHANGE=$(getBrightnessMax)
        fi
        echo "$CHANGE" >/sys/class/backlight/*/brightness
        ;;
    *) echo "$VAR" >/sys/class/backlight/*/brightness ;;
    esac
}

function setBrightnessMax {
    cat /sys/class/backlight/*/max_brightness >/sys/class/backlight/*/brightness
}

case $1 in
"get") getBrightness ;;
"get-max") getBrightnessMax ;;
"set") setBrightness "$@" ;;
"set-max") setBrightnessMax ;;

*) exit 1 ;;
esac
