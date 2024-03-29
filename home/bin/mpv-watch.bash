#!/usr/bin/env bash

declare -a SUBS

function find_vid {
    declare -a subs
    local counting pattern
    counting="$1"

    if [[ -n "$counting" ]]; then
        if [[ ${#counting} -eq 1 ]]; then
            counting="0$1"
        fi
        pattern="( $counting.?.? )|((_)$counting(_))|([Ee]p?\.?$counting )|(\[$counting\])|($counting\.)"
    fi

    VID="$(fd --max-results=1 -e mkv -e mp4 "$pattern")"
    if [[ "$VID" == "" ]]; then
        echo "Couldn't find any video"
        exit 1
    fi

    mapfile -t subs < <(fd -e ass -e srt "$pattern")
    for sub in "${subs[@]}"; do
        OPTIONS+=(--sub-file="$sub")
    done

    mapfile -t dubs < <(fd -e mp3 -e mka "$pattern")
    for dub in "${dubs[@]}"; do
        OPTIONS+=(--audio-file="$dub")
    done

    if [[ ! -d "fonts" && $(fd -1 -e ttf -e otf) != "" ]]; then
        mkdir "fonts"
        (cd fonts && fd -e ttf -e otf . .. -x ln -sf "{}" .)
    fi
}

function launch {
    echo "$VID"
    mpv "$VID" "${OPTIONS[@]}"
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
"set")
    history
    echo "$2" >"$HIST_FILE"
    ;;
"reset")
    history
    if [[ -e "$HIST_FILE" ]]; then
        rm "$HIST_FILE"
        echo "Deleted $HIST_FILE"
    fi
    if [[ -d "fonts" ]]; then
        rm "fonts"
    fi
    ;;
*)
    history
    if [[ -e "$HIST_FILE" ]]; then
        cat "$HIST_FILE"
    fi
    ;;
esac
shopt -u extglob
