#!/usr/bin/env bash

CONNECTION=0

for file in $(fd --exclude=lo --follow --max-depth=2 --glob "carrier" /sys/class/net); do
    [[ $(cat "$file") = 1 ]] && CONNECTION=1
done

if [[ "$CONNECTION" -eq 0 ]]; then
    echo 0
    exit 0
fi

WIRELESS=$(awk 'END {if (NR == 3) print $3; else print '0.'}' /proc/net/wireless | tr -d \%.)
if [[ "$CONNECTION" -eq 1 && "$WIRELESS" == 0 ]]; then
    echo -1
    exit 0
fi

echo "$WIRELESS"
