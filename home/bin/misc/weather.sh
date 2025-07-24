#!/usr/bin/env bash

cache=~/.cache/weather
file_time=$(stat -L --format %Y "$cache")
curr_time=$(date +%s)
if [[ -f "$cache" ]] && (((curr_time - file_time) < (60 * 30))); then
    cat "$cache"
    exit
fi

for _ in {1..2}; do
    RET=$(curl -s "https://wttr.in/Samara?format=%t")
    if [[ "$RET" == "Unknown"* ]]; then
        break
    fi
    if [[ "$RET" != "" && "$RET" != "This query is already being processed" ]]; then
        echo "$RET" | tee "$cache"
        # printf '{"text":"%s"}' "$RET"
        exit
    fi
    sleep 10
done

echo "?°C"
# printf '{"text":"?°C"}'
