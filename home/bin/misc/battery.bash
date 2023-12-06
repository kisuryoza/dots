#!/usr/bin/env bash

if [[ -n $(fd -1 . /sys/class/power_supply/) ]]; then
    BATTERY="$(acpi | awk '{print $4}' | tr -d \%,)"
    CHARGE="$(acpi | awk '{print $3}' | tr -d \,)"
else
    BATTERY=100
    CHARGE="PlugedIn"
fi

icon() {
    if [[ $BATTERY -lt 10 ]]; then
        if [[ $CHARGE == "Charging" ]]; then ICON="󰢟"; else ICON="󰂎"; fi
    elif [[ $BATTERY -lt 20 ]]; then
        if [[ $CHARGE == "Charging" ]]; then ICON="󰢜"; else ICON="󰁺"; fi
    elif [[ $BATTERY -lt 30 ]]; then
        if [[ $CHARGE == "Charging" ]]; then ICON="󰂆"; else ICON="󰁻"; fi
    elif [[ $BATTERY -lt 40 ]]; then
        if [[ $CHARGE == "Charging" ]]; then ICON="󰂇"; else ICON="󰁼"; fi
    elif [[ $BATTERY -lt 50 ]]; then
        if [[ $CHARGE == "Charging" ]]; then ICON="󰂈"; else ICON="󰁽"; fi
    elif [[ $BATTERY -lt 60 ]]; then
        if [[ $CHARGE == "Charging" ]]; then ICON="󰢝"; else ICON="󰁾"; fi
    elif [[ $BATTERY -lt 70 ]]; then
        if [[ $CHARGE == "Charging" ]]; then ICON="󰂉"; else ICON="󰁿"; fi
    elif [[ $BATTERY -lt 80 ]]; then
        if [[ $CHARGE == "Charging" ]]; then ICON="󰢞"; else ICON="󰂀"; fi
    elif [[ $BATTERY -lt 90 ]]; then
        if [[ $CHARGE == "Charging" ]]; then ICON="󰂊"; else ICON="󰂁"; fi
    elif [[ $BATTERY -lt 100 ]]; then
        if [[ $CHARGE == "Charging" ]]; then ICON="󰂋"; else ICON="󰂂"; fi
    else
        if [[ $CHARGE == "Charging" ]]; then ICON="󰂅"; else ICON="󰁹"; fi
    fi
}

if [[ $CHARGE == "Full" ]]; then
    CHARGE="Charging"
    icon
elif [[ $CHARGE == "PlugedIn" ]]; then
    ICON="󰚥"
fi

printf '%s\n%s' "$BATTERY" "$ICON" > /tmp/battery-charge
