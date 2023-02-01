#!/usr/bin/env bash

[[ -z "$DEBUG" ]] && DEBUG=false
$DEBUG && set -Eeuxo pipefail

(exec bwrap \
    --ro-bind /usr /usr \
    --dir /tmp \
    --dir /var \
    --symlink ../tmp var/tmp \
    --proc /proc \
    --dev /dev \
    --ro-bind /etc/resolv.conf /etc/resolv.conf \
    --ro-bind /usr/share/ca-certificates /usr/share/ca-certificates \
    --ro-bind /etc/ssl /etc/ssl \
    --ro-bind /etc/ca-certificates /etc/ca-certificates \
    --ro-bind-try /etc/alsa /etc/alsa \
    --ro-bind-try /etc/pulse /etc/pulse \
    --ro-bind-try /etc/pipewire /etc/pipewire \
    --tmpfs /run \
    --ro-bind-try /run/user/"$(id -u)"/pipewire-0 /run/user/"$(id -u)"/pipewire-0 \
    --ro-bind /run/user/"$(id -u)/$WAYLAND_DISPLAY" /run/user/"$(id -u)/$WAYLAND_DISPLAY" \
    --symlink usr/lib /lib \
    --symlink usr/lib64 /lib64 \
    --symlink usr/bin /bin \
    --symlink usr/sbin /sbin \
    --dir /run/user/$(id -u) \
    --dir "$PWD" \
    --chdir "$PWD" \
    --ro-bind "$1" "$PWD/$1" \
    --setenv XDG_RUNTIME_DIR "/run/user/$(id -u)" \
    --setenv PS1 "capsule$ " \
    --unshare-all \
    --share-net \
    --die-with-parent \
    --new-session \
    --file 11 /etc/passwd \
    --file 12 /etc/group \
    /bin/bash) \
    11< <(getent passwd $UID 65534) \
    12< <(getent group $(id -g) 65534)
