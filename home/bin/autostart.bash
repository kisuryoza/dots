#!/usr/bin/env bash

# Polkit (graphical)
pgrep --exact polkit-mate-aut || /usr/lib/mate-polkit/polkit-mate-authentication-agent-1 &>/dev/null &

# Audio Effects for Pipewire applications
if [[ -x /usr/bin/easyeffects && ! $(pgrep -x easyeffects) ]]; then
    easyeffects --gapplication-service &
fi

# Notification daemon
pgrep --exact dunst || dunst &>/dev/null &

start_x() {
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
    ln -sf ~/.local/bin/eww-x ~/.local/bin/eww && eww daemon &>/dev/null && eww open bar &>/dev/null

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
