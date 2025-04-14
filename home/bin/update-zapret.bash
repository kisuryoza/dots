#!/usr/bin/env bash

if ! pacman -Q libnetfilter_queue &>/dev/null; then
    doas pacman -S libnetfilter_queue
fi

TMPZ="/tmp/zapret"
[[ -d "$TMPZ" ]] && rm -rf "$TMPZ"

if [[ ! -d /opt/zapret ]]; then
    git clone --depth 1 https://github.com/bol-van/zapret "$TMPZ" || exit 1
    "$TMPZ"/install_easy.sh
    exit
fi

FILES=(ipset/zapret-hosts-user-exclude.txt)

git clone --depth 1 https://github.com/bol-van/zapret "$TMPZ" || exit 1

for file in "${FILES[@]}"; do
    install -vD "/opt/zapret/$file" "$TMPZ/$file"
done

nvim -d "$TMPZ"/config.default /opt/zapret/config

doas rm -rf /opt/zapret/

"$TMPZ"/install_easy.sh

(
    cd /opt/zapret/
    doas chown alex /opt/zapret/config "${FILES[@]}"
)
