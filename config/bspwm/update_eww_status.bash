#!/usr/bin/env bash

{
    xkb-switch -W | while read -r line; do
        label=""
        case "$line" in
        "us"*)
            label="US"
            ;;
        "ru"*)
            label="RU"
            ;;
        esac
        eww update keyboard_layout="$label"
    done
} &

declare -a ARRAY
ARRAY=("(box :orientation 'v' :space-evenly false :spacing 10 :valign 'center' :halign 'center'")
for _ in $(seq 9); do
    ARRAY+=("(label :class 'workspace-tag' :text '󰜌')")
done
ARRAY+=(")")

workspaces() {
    occupied=$(bspc query -D -d .occupied --names)
    focused=$(bspc query -D -d focused --names)

    declare -a a
    a=("${ARRAY[@]}")
    for o in $occupied; do
        a[o]="(label :class 'workspace-tag-visible' :text '󰜌')"
    done

    a[focused]="(label :class 'workspace-tag-mine' :text '󰜋')"

    eww update wm-tags="${a[*]}"
}

workspaces

bspc subscribe desktop node_transfer | while read -r _; do
    bspwm_workspaces
done
