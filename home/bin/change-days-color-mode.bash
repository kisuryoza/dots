#!/usr/bin/env bash

function day {
    sed -Ei 's|BAT_THEME=.*|BAT_THEME="gruvbox-light"|' ~/.config/zsh/.zshenv
    sed -Ei 's|colors:.*|colors: \*tokyo-light|' ~/.config/alacritty/themes.yml
    sed -Ei 's|--.*"|--light"|' ~/.config/eww/src/_colors.scss
    sed -Ei 's|:style :.*|:style :day|' ~/.config/nvim/fnl/colors.fnl
}

function evening {
    sed -Ei 's|BAT_THEME=.*|BAT_THEME="gruvbox-dark"|' ~/.config/zsh/.zshenv
    sed -Ei 's|colors:.*|colors: \*tokyo-storm|' ~/.config/alacritty/themes.yml
    sed -Ei 's|--.*"|--storm"|' ~/.config/eww/src/_colors.scss
    sed -Ei 's|:style :.*|:style :storm|' ~/.config/nvim/fnl/colors.fnl
}

function night {
    sed -Ei 's|BAT_THEME=.*|BAT_THEME="gruvbox-dark"|' ~/.config/zsh/.zshenv
    sed -Ei 's|colors:.*|colors: \*tokyo-night|' ~/.config/alacritty/themes.yml
    sed -Ei 's|--.*"|--night"|' ~/.config/eww/src/_colors.scss
    sed -Ei 's|:style :.*|:style :night|' ~/.config/nvim/fnl/colors.fnl
}

case $1 in
"day") day ;;
"evening") evening ;;
"night") night ;;

*) exit 1 ;;
esac
