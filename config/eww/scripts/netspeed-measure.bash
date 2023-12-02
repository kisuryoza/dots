#!/usr/bin/env bash

DEVICE=$(nmcli dev status | awk '/connected/ {if ($1 != "lo") print $1}' | sed "1q;d")
OLD_RX=-1
OLD_TX=-1
while true; do
    if [[ -d /sys/class/net/"$DEVICE" ]]; then
        NEW_RX=$(cat /sys/class/net/"$DEVICE"/statistics/rx_bytes)
        NEW_TX=$(cat /sys/class/net/"$DEVICE"/statistics/tx_bytes)
        if [[ $OLD_RX -gt 0 ]]; then
            echo "[$(((NEW_TX - OLD_TX) / 1024)), $(((NEW_RX - OLD_RX) / 1024))]"
        fi
        OLD_RX=$NEW_RX
        OLD_TX=$NEW_TX
        sleep 1
    else
        echo "[0, 0]"
        sleep 5
    fi
done
