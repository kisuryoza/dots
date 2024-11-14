#!/usr/bin/env bash

SCRIPT="$(realpath -s "${BASH_SOURCE[0]}")"

DISPLAY=:0
export DISPLAY

[[ -z "$DEBUG" ]] && DEBUG=false
"$DEBUG" && set -Eeuxo pipefail

MaxTempThreshold=60 MaxRPM=100

TempThreshold[0]=60 RPM[0]=80
TempThreshold[1]=50 RPM[1]=60

MinTempThreshold=40 MinRPM=30

cache=/tmp/$(basename "$SCRIPT").cache
runningState=false

run() {
    temp=$(nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader)

    if [[ "$temp" -ge $MaxTempThreshold ]]; then
        speed=$MaxRPM
    elif [[ "$temp" -le $MinTempThreshold ]]; then
        speed=$MinRPM
    else
        thresholds=$((${#TempThreshold[@]} - 1))
        for i in $(seq 0 "$thresholds"); do
            if [[ "$temp" -lt $((TempThreshold[i])) ]]; then
                threshold=$((TempThreshold[i]))
                speed=$((RPM[i]))
            fi
        done

        # max possible temperature at the current thresholds speed
        maxTemp=$((threshold * 100 / speed))
        speed=$(("$temp" * 100 / maxTemp))
    fi

    currentRPM=$(nvidia-smi --query-gpu=fan.speed --format=csv,noheader,nounits)
    if [[ "$speed" != "$currentRPM" ]]; then
        output=$(nvidia-settings -c :0 -a "[fan:0]/GPUTargetFanSpeed=$speed" | awk '$1 ~ /^[A]/ {print substr($0, 3)}')
        echo "$output"
        # timestamp=$(date +'['%T']')
        # echo "$timestamp" "$output" >>"$cache"
    fi
}

run-looped() {
    echo "runningState=true" >"$cache"
    runningState=true
    nvidia-settings -c :0 -a "[gpu:0]/GPUFanControlState=1"

    while "$runningState"; do
        run
        sleep 5
        runningState=$(awk -F "=" '/runningState/ {print $NF}' "$cache")
    done
}

case "$1" in
"run") run ;;
"run-looped") run-looped ;;
"stop") sed -i "s|.*runningState=.*|runningState=false|" "$cache" ;;
*) ;;
esac
