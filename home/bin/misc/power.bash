#!/usr/bin/env bash

pgrep -x bemenu-run && exit

SELECTED=$(printf "Suspend\nReboot\nPower off" | bemenu --ignorecase --prompt "" --hp 10)
case "$SELECTED" in
"Suspend") systemctl suspend ;;
"Reboot") systemctl reboot ;;
"Power off") systemctl -i poweroff ;;
*) ;;
esac
