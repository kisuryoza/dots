#!/usr/bin/env bash

[[ -z "$DEBUG" ]] && DEBUG=false
$DEBUG && set -Eeuxo pipefail

SCRIPT="$(realpath -s "${BASH_SOURCE[0]}")"
SCRIPT_DIR=$(dirname "$SCRIPT")
source "$SCRIPT_DIR"/helper-func.sh

if [[ ! -d "$HOME/.local/bin/" ]]; then
    mkdir --parents "$HOME/.local/bin/"
fi

function update {
    NAME="$(echo "$1" | awk -F '/' '{print $NF}')"

    if [[ -d ~/gitclones/"$NAME" ]]; then
        log "Updating $NAME"
        cd ~/gitclones/"$NAME" && git pull
    else
        log "Installing $NAME"
        git clone --depth 1 "$1.git" ~/gitclones/"$NAME" &&
            cd ~/gitclones/"$NAME"
    fi
}

function eww {
    update "https://github.com/elkowar/eww"

    cargo build --release --no-default-features --features x11
    install -vsDm 744 target/release/eww ~/.local/bin/eww-x
    if pacman -Q gtk-layer-shell &>/dev/null; then
        cargo build --release --no-default-features --features=wayland
        install -vsDm 744 target/release/eww ~/.local/bin/eww-wayland
    fi

    cargo clean
}

function fennel_language_server {
    update "https://github.com/rydesun/fennel-language-server"
    cargo build --release
    install -vsDm 744 target/release/fennel-language-server ~/.local/bin

    cargo clean
}

case $1 in
"eww")
    eww
    ;;
"all")
    eww
    fennel_language_server
    ;;
*) exit 1 ;;
esac
