#!/usr/bin/env bash

bspc subscribe node_state | while read -r _ _ _ _ state flag; do
    if [ "$state" != "fullscreen" ]; then
        continue
    fi
    if [ "$flag" == "on" ]; then
        xdo lower -N eww-bar || xdo lower -N eww || xdo lower -N Eww
    else
        xdo raise -N eww-bar || xdo raise -N eww || xdo raise -N Eww
    fi
done
