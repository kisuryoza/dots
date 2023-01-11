#!/usr/bin/env bash

if [[ $(loginctl show-session self -p Type | awk -F "=" '/Type/ {print $NF}') == "wayland" ]]; then
    ~/.config/eww/scripts/workspaces.py
else
    leftwm-state -w 0 -t ~/.config/leftwm/themes/current/template-eww.liquid
fi
