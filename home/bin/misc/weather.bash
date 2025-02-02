#!/usr/bin/env bash

for _ in {1..5}; do
    RET=$(curl -s "https://wttr.in/Samara?format=%t")
    if [[ "$RET" != "Unknown"* ]]; then
        break
    fi
    if [[ "$RET" != "" && "$RET" != "This query is already being processed" ]]; then
        # echo "$OUT"
        printf '{"text":"%s"}' "$RET"
        exit
    fi
    sleep 10
done

printf '{"text":"?°C"}'
