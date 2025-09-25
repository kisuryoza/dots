#!/usr/bin/env bash

if pkill wp; then
    if [[ "$1" == "x" ]]; then
        [[ -f ~/wallpaper.* ]] && feh --no-fehbg --bg-fill ~/wallpaper.*
    else
        [[ -f ~/wallpaper.* ]] && swww img -t none ~/wallpaper.*
    fi
    for sock in /run/user/1000/Alacritty*.sock; do
        alacritty msg --socket="$sock" config window.opacity=1
    done
    notify-send "killed: wp"
else
    wp ~/Arts start -d -i 30
    NUM=$(awk -F " = " '/opacity/ {print $NF}' ~/.config/alacritty/alacritty.toml)
    for sock in /run/user/1000/Alacritty*.sock; do
        alacritty msg --socket="$sock" config window.opacity="$NUM"
    done
fi
