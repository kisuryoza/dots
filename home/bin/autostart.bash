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

function start_X {
    # Hotkey daemon
    pgrep --exact sxhkd || sxhkd &> /dev/null &

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
    ln -sf ~/.local/bin/eww-x ~/.local/bin/eww
    eww open bar &>/dev/null

    # Keyboard layout
    pgrep --full keyboard-layout.bash || ~/bin/misc/keyboard-layout.bash x

    # wallpaper
    [[ -f ~/wallpaper.jpg ]] && feh --no-fehbg --bg-fill ~/wallpaper.jpg
}

function start_Wayland {
    # Idle management daemon
    pgrep --exact swayidle || swayidle -w \
        timeout 120 'swaylock -f -c 1a1b26 --ring-color 24283b --key-hl-color bb9af7 --inside-color 1a1b26' \
        timeout 130 'hyprctl dispatch dpms off' \
        resume 'hyprctl dispatch dpms on' \
        before-sleep 'swaylock -f -c 1a1b26 --ring-color 24283b --key-hl-color bb9af7 --inside-color 1a1b26' &

    # Bar and widgets
    ln -sf ~/.local/bin/eww-wayland ~/.local/bin/eww
    # launch_eww

    # Keyboard layout
    # pgrep --full keyboard-layout.bash || ~/bin/misc/keyboard-layout.bash wayland
}

case "$1" in
"x")
    start_X
    ;;
"wayland")
    # start_Wayland
    ;;
*) exit 1 ;;
esac
