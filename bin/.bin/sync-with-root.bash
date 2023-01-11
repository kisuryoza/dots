#!/usr/bin/env bash

SCRIPT_PATH=$(realpath -s "${BASH_SOURCE[0]}")

function run_root {
    local user="$1"
    declare -a FILES_TO_SYNC
    FILES_TO_SYNC+=("/home/$user/.config/zsh/.zshenv")
    FILES_TO_SYNC+=("/home/$user/.config/zsh/.zshrc")
    FILES_TO_SYNC+=("/home/$user/.config/zsh/aliases.zsh")
    FILES_TO_SYNC+=("/home/$user/.config/zsh/functions.zsh")
    FILES_TO_SYNC+=("/home/$user/.config/starship.toml")

    for i in "${FILES_TO_SYNC[@]}"
    do
        install -vDm 600 "$i" "/root/$(echo "$i" | sed -E "s|/([a-zA-Z]*/){2}||")"
    done
}

if [[ $(id -u) -eq 0 ]]; then
    [[ -z "$1" ]] && exit 1
    run_root "$1"
else
    sudo "$SCRIPT_PATH" "$USER"
fi
