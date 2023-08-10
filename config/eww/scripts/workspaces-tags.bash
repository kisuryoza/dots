#!/usr/bin/env bash

bspwm_workspaces() {
    declare -a array

    array=("(box :spacing 10 :valign 'center' :halign 'center' :orientation 'v' :space-evenly true")
    for i in $(seq 9); do
        array+=("(label :class 'workspace-tag' :text '󰜌')")
    done
    array+=(")")

    occupied=$(bspc query -D -d .occupied --names)
    for o in $occupied; do
        array[o]="(label :class 'workspace-tag-visible' :text '󰜌')"
    done

    focused=$(bspc query -D -d focused --names)
    for f in $focused; do
        array[f]="(label :class 'workspace-tag-mine' :text '󰜋')"
    done

    echo "${array[@]}"
}

if [[ $(loginctl show-session self -p Type | awk -F "=" '/Type/ {print $NF}') == "wayland" ]]; then
    ~/.config/eww/scripts/workspaces.py
else
    bspwm_workspaces
    bspc subscribe desktop node_transfer | while read -r _; do
        bspwm_workspaces &
    done
fi
