#!/usr/bin/env bash

bspwm_workspaces() {
    occupied=$(bspc query -D -d .occupied --names)
    focused=$(bspc query -D -d focused --names)
    workspaces
}

hyprland_workspaces (){
    occupied=$(hyprctl workspaces -j | jq '.[] | .id')
    focused=$(hyprctl monitors -j | jq '.[] | select(.focused) | .activeWorkspace.id')
    workspaces
}

workspaces() {
    declare -a array

    array=("(box :orientation 'v' :space-evenly false :spacing 10 :valign 'center' :halign 'center'")
    for _ in $(seq 9); do
        array+=("(label :class 'workspace-tag' :text '󰜌')")
    done
    array+=(")")

    for o in $occupied; do
        array[o]="(label :class 'workspace-tag-visible' :text '󰜌')"
    done

    array[focused]="(label :class 'workspace-tag-mine' :text '󰜋')"

    echo "${array[@]}"
}

if [[ -n "$WAYLAND_DISPLAY" ]]; then
    hyprland_workspaces
    socat -u UNIX-CONNECT:/tmp/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock - | while read -r line; do
        if [[ "$line" == "workspace"* ]]; then
            hyprland_workspaces
        fi
    done
else
    bspwm_workspaces
    bspc subscribe desktop node_transfer | while read -r _; do
        bspwm_workspaces
    done
fi
