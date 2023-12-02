#!/usr/bin/env bash

[[ -z "$DEBUG" ]] && DEBUG=false
$DEBUG && set -Eeuxo pipefail

if [[ -n $(fd -1 . /sys/class/power_supply/) ]]; then
    BATTERY="$(acpi | awk '{print $4}' | tr -d \%,)"
    CHARGE="$(acpi | awk '{print $3}' | tr -d \,)"
else
    BATTERY=100
    CHARGE="Pluged in"
fi

function icon {
    case $CHARGE in
    "Pluged in") echo "󰚥" ;;
    "Charging" | "Full")
        if [[ $BATTERY -lt 10 ]]; then
            echo "󰢟"
        elif [[ $BATTERY -lt 20 ]]; then
            echo "󰢜"
        elif [[ $BATTERY -lt 30 ]]; then
            echo "󰂆"
        elif [[ $BATTERY -lt 40 ]]; then
            echo "󰂇"
        elif [[ $BATTERY -lt 50 ]]; then
            echo "󰂈"
        elif [[ $BATTERY -lt 60 ]]; then
            echo "󰢝"
        elif [[ $BATTERY -lt 70 ]]; then
            echo "󰂉"
        elif [[ $BATTERY -lt 80 ]]; then
            echo "󰢞"
        elif [[ $BATTERY -lt 90 ]]; then
            echo "󰂊"
        elif [[ $BATTERY -lt 100 ]]; then
            echo "󰂋"
        else
            echo "󰂅"
        fi
        ;;
    "Discharging")
        if [[ $BATTERY -lt 10 ]]; then
            echo "󰂎"
        elif [[ $BATTERY -lt 20 ]]; then
            echo "󰁺"
        elif [[ $BATTERY -lt 30 ]]; then
            echo "󰁻"
        elif [[ $BATTERY -lt 40 ]]; then
            echo "󰁼"
        elif [[ $BATTERY -lt 50 ]]; then
            echo "󰁽"
        elif [[ $BATTERY -lt 60 ]]; then
            echo "󰁾"
        elif [[ $BATTERY -lt 70 ]]; then
            echo "󰁿"
        elif [[ $BATTERY -lt 80 ]]; then
            echo "󰂀"
        elif [[ $BATTERY -lt 90 ]]; then
            echo "󰂁"
        elif [[ $BATTERY -lt 100 ]]; then
            echo "󰂂"
        else
            echo "󰁹"
        fi
        ;;
    esac
}

case $1 in
"get") echo "$BATTERY" ;;
"icon") icon ;;

*) exit 1 ;;
esac
