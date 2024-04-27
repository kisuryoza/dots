#!/usr/bin/env bash

switch_layout() {
    label=""
    case "$1" in
    *"English"*)
        label="US"
        ;;
    *"Russian"*)
        label="RU"
        ;;
    esac
    eww update keyboard_layout="$label"
}

declare -a ARRAY
ARRAY=("(box :orientation 'v' :space-evenly false :spacing 10 :valign 'center' :halign 'center'")
for _ in $(seq 9); do
    ARRAY+=("(label :class 'workspace-tag' :text '󰜌')")
done
ARRAY+=(")")

workspaces() {
    occupied=$(hyprctl workspaces -j | jq '.[] | .id')
    focused=$(hyprctl monitors -j | jq '.[] | select(.focused) | .activeWorkspace.id')

    declare -a a
    a=("${ARRAY[@]}")
    for o in $occupied; do
        a[o]="(label :class 'workspace-tag-visible' :text '󰜌')"
    done

    a[focused]="(label :class 'workspace-tag-mine' :text '󰜋')"

    eww update wm-tags="${a[*]}"
}

workspaces

socat -u UNIX-CONNECT:/tmp/hypr/"$HYPRLAND_INSTANCE_SIGNATURE"/.socket2.sock - | while read -r line; do
    case "$line" in
    "activelayout>>"*)
        switch_layout "$line"
        ;;
    "workspacev2>>"*)
        workspaces
        ;;
    esac
done
