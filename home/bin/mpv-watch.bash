#!/usr/bin/env bash

function find_vid {
    declare -a subs
    local counting pattern
    counting="$1"

    mapfile -t vids < <(fd --max-depth=1 -e mkv -e mp4)
    VID="${vids[$counting - 1]}"
    if [[ "$VID" == "" ]]; then
        echo "Couldn't find any video"
        exit 1
    fi

    if [[ -n "$counting" ]]; then
        if [[ ${#counting} -eq 1 ]]; then
            counting="0$1"
        fi
        pattern="(S..E$counting)|( $counting )|((_)$counting(_))|([Ee]p?\.?$counting )|(\[$counting\])|($counting\.)"
    fi

    mapfile -t subs < <(fd -e ass -e srt "$pattern")
    for sub in "${subs[@]}"; do
        OPTIONS+=(--sub-file="$sub")
    done

    mapfile -t dubs < <(fd -e mp3 -e ogg -e mka "$pattern")
    for dub in "${dubs[@]}"; do
        OPTIONS+=(--audio-file="$dub")
    done

    if [[ ! -d "fonts" && $(fd -1 -e ttf -e otf) != "" ]]; then
        mkdir "fonts" && cd "fonts" || exit 1
        mapfile -t fonts < <(fd -e ttf -e otf . ..)
        for font in "${fonts[@]}"; do
            ln -sf "$font" .
        done
        cd ..
    fi
}

function launch {
    echo "$VID"
    mpv "${OPTIONS[@]}" "$@" "$VID"
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
            *) ;;
            esac
        fi
        find_vid "$counting"
        echo "$counting" >"$HIST_FILE"
    else
        find_vid "1"
        echo "1" >"$HIST_FILE"
    fi

    shift
    launch "$@"
}

shopt -s extglob
case "$1" in
+([0-9]))
    find_vid "$1"
    shift
    launch "$@"
    ;;
"movie")
    find_vid
    shift
    launch "$@"
    ;;
"prev")
    shift
    play prev "$@"
    ;;
"play")
    play "$@"
    ;;
"next")
    shift
    play next "$@"
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
