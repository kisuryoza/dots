#!/usr/bin/env bash

function find_vid {
    local counting pattern
    counting="$1"
    if [[ -n "$counting" ]]; then
        if [[ ${#counting} -eq 1 ]]; then
            counting="0$1"
        fi
        pattern="( $counting )|(Ep?$counting)|(\[$counting\])|($counting\.)"
    fi

    VID="$(fd --max-results=1 -e mkv -e mp4 "$pattern")"
    SUB="$(fd --absolute-path --max-results=1 -e ass "$pattern")"
}

function launch {
    echo "$VID"
    if [[ -n "$SUB" ]]; then
        mpv "$VID" --sub-file="$SUB"
    else
        mpv "$VID"
    fi
}

function hist {
    local cache dir hist_path
    cache="$HOME/.cache/mpv-history"
    [ ! -d "$cache" ] && mkdir "$cache"

    dir="$(realpath "$PWD")"
    hist_path="${dir//\//__}"
    HIST_FILE="$cache/$hist_path"
}

function play {
    local counting
    hist
    if [[ -r "$HIST_FILE" ]]; then
        counting=$(cat "$HIST_FILE")
        if [[ -n "$1" ]]; then
            case "$1" in
            "prev")
                counting=$((counting - 1))
                ;;
            "next")
                counting=$((counting + 1))
                ;;
            *) exit 2 ;;
            esac
            echo "$counting" >"$HIST_FILE"
        fi
        find_vid "$counting"
    else
        find_vid "1"
        echo "1" >"$HIST_FILE"
    fi

    launch
}

shopt -s extglob
case "$1" in
+([0-9]))
    find_vid "$1"
    launch
    ;;
"movie")
    find_vid
    launch
    ;;
"prev")
    play prev
    ;;
"play")
    play
    ;;
"next")
    play next
    ;;
*)
    exit 1
    ;;
esac
shopt -u extglob
