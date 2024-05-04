#!/usr/bin/env sh

if [ "$1" = "CHILD" ]; then
    shift
    "$0" DAEMON "$@" &
    exit 0
fi

if [ "$1" != "DAEMON" ]; then
    setsid "$0" CHILD "$@" &
    exit 0
fi

shift
cd /
exec 0<&-
exec 1>&-
exec 2>&-

"$@"
