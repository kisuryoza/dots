#!/usr/bin/env bash

# Polkit (graphical)
pgrep --exact polkit-mate-aut || /usr/lib/mate-polkit/polkit-mate-authentication-agent-1 &>/dev/null &

# Audio Effects for Pipewire applications
if [[ -x /usr/bin/easyeffects && ! $(pgrep -x easyeffects) ]]; then
    easyeffects --gapplication-service &
fi

# Notification daemon
pgrep --exact dunst || dunst &>/dev/null &
DBUS_ADDRESS_FILE="/tmp/.dbus-address"
touch "$DBUS_ADDRESS_FILE"
chmod 600 "$DBUS_ADDRESS_FILE"
echo "export DBUS_SESSION_BUS_ADDRESS=$DBUS_SESSION_BUS_ADDRESS" >>"$DBUS_ADDRESS_FILE"

start_x() {
    # Hotkey daemon
    pgrep --exact sxhkd || sxhkd &>/dev/null &

    # Display Power Management Signaling
    xset s 170 170
    xset dpms 180 180 180

    # Screen locker
    pgrep --exact xss-lock || xss-lock --transfer-sleep-lock -- i3lock -c 1a1b26 --nofork &>/dev/null &

    # Compositor
    pgrep --exact picom || picom &>/dev/null &

    # Screenshoter
    pgrep --exact flameshot || flameshot &>/dev/null &

    # Bar and widgets
    ln -sf ~/.local/bin/eww-x ~/.local/bin/eww && eww open bar &>/dev/null
    pgrep --full eww_fullscreen_fix.bash || ~/.config/bspwm/eww_fullscreen_fix.bash &>/dev/null &
    pgrep --full keyboard-layout.bash || ~/.config/bspwm/update_eww_status.bash &>/dev/null &

    # wallpaper
    [[ -f ~/wallpaper.jpg ]] && feh --no-fehbg --bg-fill ~/wallpaper.jpg
}

case "$1" in
"x")
    start_x
    ;;
"wayland")
    # start_Wayland
    ;;
*) ;;
esac
