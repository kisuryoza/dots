#!/usr/bin/env bash

# Polkit (graphical)
pgrep --exact polkit-mate-aut || /usr/lib/mate-polkit/polkit-mate-authentication-agent-1 &> /dev/null &

# Audio Effects for Pipewire applications
if [[ -x /usr/bin/easyeffects && ! $(pgrep -x easyeffects) ]]; then
    easyeffects --gapplication-service &
fi

# Notification daemon
pgrep --exact dunst || dunst &>/dev/null &
DBUS_ADDRESS_FILE="/tmp/.dbus-address"
touch "$DBUS_ADDRESS_FILE"
chmod 600 "$DBUS_ADDRESS_FILE"
echo "export DBUS_SESSION_BUS_ADDRESS=$DBUS_SESSION_BUS_ADDRESS" >> "$DBUS_ADDRESS_FILE"
