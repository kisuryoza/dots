#!/usr/bin/env bash

if ! pacman -Q libnetfilter_queue &>/dev/null; then
    sudo pacman -S libnetfilter_queue
fi

TMPZ="/tmp/zapret"
TMPC="/tmp/zapret-configs"
[[ -d "$TMPZ" ]] && rm -rf "$TMPZ"

if [[ ! -d /opt/zapret ]]; then
    git clone --depth 1 https://github.com/bol-van/zapret "$TMPZ" || exit 1
    "$TMPZ"/install_easy.sh
    exit
fi

FILES=(youtube-hosts.txt discord-hosts.txt ipset/zapret-hosts-user-exclude.txt)

install -vD "/opt/zapret/$file" "$TMPC/config"
for file in "${FILES[@]}"; do
    install -vD "/opt/zapret/$file" "$TMPC/$file"
done

git clone --depth 1 https://github.com/bol-van/zapret "$TMPZ" || exit 1

for file in "${FILES[@]}"; do
    install -vD "$TMPC/$file" "$TMPZ/$file"
done

nvim -d "$TMPZ"/config.default "$TMPC"/config

sudo rm -rf /opt/zapret/

"$TMPZ"/install_easy.sh

(
    cd /opt/zapret/
    sudo chown alex "${FILES[@]}"
)
