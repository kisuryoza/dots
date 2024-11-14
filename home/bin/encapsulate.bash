#!/usr/bin/env bash

(exec bwrap \
    --ro-bind /usr/bin /usr/bin \
    --ro-bind /usr/share /usr/share/ \
    --ro-bind /usr/lib /usr/lib \
    --ro-bind /usr/lib64 /usr/lib64 \
    --symlink /usr/lib /lib \
    --symlink /usr/lib64 /lib64 \
    --symlink /usr/bin /bin \
    --symlink /usr/bin /sbin \
    --proc /proc \
    --dev /dev \
    --tmpfs /run \
    --tmpfs /tmp \
    --dir /var \
    --dir "$XDG_RUNTIME_DIR" \
    --dir "$PWD" \
    --chdir "$PWD" \
    --ro-bind "$1" "$PWD/$1" \
    --setenv PS1 "bwrap$ " \
    --unshare-all \
    --die-with-parent \
    --new-session \
    --seccomp 10 \
    --file 11 /etc/passwd \
    --file 12 /etc/group \
    /bin/bash) \
    10< <(cat /usr/local/bin/seccomp_default_filter.bpf) \
    11< <(getent passwd "$UID" 65534) \
    12< <(getent group "$(id -g)" 65534)
