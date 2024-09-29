#!/usr/bin/env bash

TMP=$(mktemp -d)
TMPZ="/tmp/zapret"
if [[ -d "$TMPZ" ]]; then
    rm -rf "$TMPZ"
fi

cp /opt/zapret/config "$TMP"/config
cp /opt/zapret/ipset/zapret-hosts-user-exclude.txt "$TMP"/zapret-hosts-user-exclude.txt

git clone --depth 1 https://github.com/bol-van/zapret "$TMPZ"  || exit 1

cp "$TMP"/config "$TMPZ"
cp "$TMP"/zapret-hosts-user-exclude.txt  "$TMPZ"/ipset/

nvim -d "$TMPZ"/config.default "$TMPZ"/config

"$TMPZ"/install_easy.sh
