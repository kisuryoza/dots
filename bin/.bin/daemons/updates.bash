#!/usr/bin/env bash

SCRIPT="$(realpath -s "${BASH_SOURCE[0]}")"
SCRIPT_DIR=$(dirname "$SCRIPT")
source "$SCRIPT_DIR"/init

while true; do
    sleep $((60 * 60 * 1))

    if ! updates_arch=$(checkupdates 2> /dev/null | wc -l ); then
        updates_arch=0
    fi

    if ! updates_aur=$(paru -Qua 2> /dev/null | wc -l); then
        updates_aur=0
    fi

    updates=$((updates_arch + updates_aur))

    echo "$updates" > ~/.cache/avaliable-updates.txt
done
