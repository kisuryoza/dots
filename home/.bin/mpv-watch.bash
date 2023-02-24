#!/usr/bin/env bash

function find_vid {
    local counting
    declare -a vids subs
    counting="$1"

    mapfile -t vids < <(fd -e mkv -e mp4)
    mapfile -t subs < <(fd -e ass)
    VID=${vids[counting]}
    SUB=${subs[counting]}
    if [[ "$VID" == "" ]]; then
        echo "Couldn't find any video"
        exit 1
    fi
}

function launch {
    echo "$VID"
    if [[ -n "$SUB" ]]; then
        mpv "$VID" --sub-file="$SUB"
    else
        mpv "$VID"
    fi
}

function history {
    local cache dir hist_path
    cache="$HOME/.cache/mpv-history"
    [ ! -d "$cache" ] && mkdir "$cache"

    dir="$(realpath "$PWD")"
    hist_path="${dir//\//__}"
    HIST_FILE="$cache/$hist_path"
}

function play {
    local counting
    history
    if [[ -r "$HIST_FILE" ]]; then
        counting=$(cat "$HIST_FILE")
        if [[ -z "$counting" ]]; then
            counting=0
        fi
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
        fi
        find_vid "$counting"
        echo "$counting" >"$HIST_FILE"
    else
        find_vid "0"
        echo "0" >"$HIST_FILE"
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
"reset")
    history
    if [[ -e "$HIST_FILE" ]]; then
        rm "$HIST_FILE"
        echo "Deleted $HIST_FILE"
    fi
    ;;
*)
    exit 1
    ;;
esac
shopt -u extglob
