#!/usr/bin/env bash

[[ -z "$DEBUG" ]] && DEBUG=false
$DEBUG && set -Eeuxo pipefail

ALPHA="64"
background="#000000"
foreground="#000000"
color1="#000000"
color2="#000000"
color3="#000000"
color4="#000000"
color5="#000000"
color6="#000000"

function changeColorTags {
    sed -i "s|%{F#......}|%{F$background}|g" "$1"
    sed -i "s|%{B#........}|%{B#$ALPHA${color1:1}}|g" "$1"

    sed -i "s|%{B#......}|%{B$background}|g" "$1"

    sed -i "s|%{u#......}|%{u$color2}|g" "$1"
    sed -i "s|%{o#......}|%{o$color2}|g" "$1"
}

if [ -x "/usr/bin/wal" ];
then
    [ -r "$HOME"/.cache/wal ] && rm -rf "$HOME"/.cache/wal
    wal -nste -i "$HOME"/.config/bg.*
    source "$HOME"/.cache/wal/colors.sh || echo "error" || exit 1

    COLORS=~/.config/polybar/colors-base.ini
    MODULES=~/.config/polybar/modules.ini

    sed -Ei "s|^foreground =.*|foreground = $color6|" "$COLORS"
    sed -Ei "s|^foreground-alt =.*|foreground-alt = #$ALPHA${color6:1}|" "$COLORS"

    sed -Ei "s|^background =.*|background = $background|" "$COLORS"
    #sed -Ei "s|^background-alt =.*|background-alt = #$ALPHA${color1:1}|" "$COLORS"
    sed -Ei "s|^background-alt =.*|background-alt = #00${color1:1}|" "$COLORS"

    sed -Ei "s|^underline =.*|underline = $color2|" "$COLORS"
    sed -Ei "s|^overline =.*|overline = $color2|" "$COLORS"

    changeColorTags "$MODULES"

    if [[ -x "/usr/bin/leftwm" || -x "/usr/local/bin/leftwm" ]];
    then
        LEFTWM=~/.config/leftwm/themes/current/theme.toml
        LIQUID=~/.config/leftwm/themes/current/template-polybar.liquid

        sed -Ei "s|^default_border_color.*|default_border_color = \"$color1\"|" "$LEFTWM"
        sed -Ei "s|^floating_border_color.*|floating_border_color = \"$color2\"|" "$LEFTWM"
        #sed -Ei "s|^focused_border_color.*|focused_border_color = \"#$color6\"|" "$LEFTWM"

        changeColorTags "$LIQUID"

        leftwm-command "SoftReload"
        echo
    else
        "$HOME"/.config/polybar/launch.sh
    fi
fi
