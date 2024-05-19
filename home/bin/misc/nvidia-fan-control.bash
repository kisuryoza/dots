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

init() {
    echo "runningState=true" >"$cache"
    runningState=true
    fanControl
}

fanControl() {
    nvidia-settings -c :0 -a "[gpu:0]/GPUFanControlState=1"

    while "$runningState"; do
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
            timestamp=$(date +'['%T']')
            output=$(nvidia-settings -c :0 -a "[fan:0]/GPUTargetFanSpeed=$speed" | awk '$1 ~ /^[A]/ {print substr($0, 3)}')
            echo "$timestamp" "$output" >>"$cache"
        fi

        sleep 5
        runningState=$(awk -F "=" '/runningState/ {print $NF}' "$cache")
    done
}

while getopts k param; do
    case $param in
    k)
        sed -i "s|.*runningState=.*|runningState=false|" "$cache"
        exit 0
        ;;
    *) ;;
    esac
done

init
