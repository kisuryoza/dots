#!/usr/bin/env bash

TMP=$(mktemp -d)
TMPZ="/tmp/zapret"
if [[ -d "$TMPZ" ]]; then
    rm -rf "$TMPZ"
fi

FILES=(config youtube-hosts.txt discord-hosts.txt ipset/zapret-hosts-user-exclude.txt)

for file in "${FILES[@]}"; do
    install -vD "/opt/zapret/$file" "$TMP/$file"
done

git clone --depth 1 https://github.com/bol-van/zapret "$TMPZ" || exit 1

for file in "${FILES[@]}"; do
    install -vD "$TMP/$file" "$TMPZ/$file"
done

nvim -d "$TMPZ"/config.default "$TMPZ"/config

sudo rm -rf /opt/zapret/

"$TMPZ"/install_easy.sh

for file in "${FILES[@]}"; do
    sudo chown alex /opt/zapret/"$file"
done
