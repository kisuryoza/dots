#!/usr/bin/env bash

if pkill wp; then
    if [[ "$1" == "x" ]]; then
        [[ -f ~/wallpaper.jpg ]] && feh --no-fehbg --bg-fill ~/wallpaper.jpg
    else
        [[ -f ~/wallpaper.jpg ]] && swww img -t none ~/wallpaper.jpg
    fi
    for sock in /run/user/1000/Alacritty*.sock; do
        alacritty msg --socket="$sock" config window.opacity=1
    done
    notify-send "killed: wp"
else
    wp ~/Arts start -d -i 30
    for sock in /run/user/1000/Alacritty*.sock; do
        alacritty msg --socket="$sock" config window.opacity=0.9
    done
fi
