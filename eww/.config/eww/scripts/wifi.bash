#!/usr/bin/env bash

[[ -z "$DEBUG" ]] && DEBUG=false
$DEBUG && set -Eeuxo pipefail

function rescan {
    nmcli device wifi rescan
    nmcli -get-values IN-USE,SSID,SIGNAL device wifi list > /tmp/connection
    eww update wifi-list="$(getList)"
}

function getList {
    OUTPUT="{\"list\": ["
    while IFS="" read -r line
    do
        IN_USE=$(echo "$line" | awk -F ":" '{print $1}')
        if [[ $IN_USE == "*" ]]; then IN_USE="true"; else IN_USE="false"; fi
        SSID=$(echo "$line" | awk -F ":" '{print $2}')
        SIGNAL=$(echo "$line" | awk -F ":" '{print $3}')

        OUTPUT+="{"
        OUTPUT+="\"in-use\": $IN_USE, "
        OUTPUT+="\"ssid\": \"$SSID\", "
        OUTPUT+="\"signal\": $SIGNAL"
        OUTPUT+="},"
    done < /tmp/connection
    OUTPUT=${OUTPUT::(-1)}
    OUTPUT+="]}"
    echo "$OUTPUT"
}

function toggle {
    IS_CONNECTED=$(nmcli dev | rg "wifi" | rg "connected")
    if [ -n "$IS_CONNECTED" ]; then
        nmcli radio wifi off
    else
        nmcli radio wifi on
    fi
}

case $1 in
    "rescan") rescan ;;
    "getList") getList ;;
    "toggle") toggle ;;

    *) exit 1 ;;
esac
