#!/usr/bin/env bash
set -euo pipefail

declare -a OPTIONS
VID=""
ARCHIVE="subs.7z"
dir_name=$(realpath "$PWD")
dir_name="${dir_name#"$HOME/"}"
dir_name="${dir_name#"/run/media/$USER/"}"
FONTS_DIR="/tmp/fonts/"
EXT_DIR="/tmp/$dir_name"

crc32-verify() {
    local file checksum calculated
    file=$(basename "$1")

    checksum=$(echo "$file" | sd '.+\[(.+)\](\..+)$' '$1')
    calculated="$(7z h "$file" | tail -n3 | head -n1 | sd '.*\s([\d\w]+)$' '$1')"
    if [[ "$checksum" == "$calculated" ]]; then
        echo "OK - $file"
    else
        echo "ERR - $file"
    fi
}

find_subs() {
    declare -a dirs subs
    local where sub
    where="$1"
    mapfile -t dirs < <(fd -td . "$where")
    for dir in "${dirs[@]}"; do
        if [[ $(fd -1 -d 1 -e ass -e mks -e srt . "$dir") == "" ]]; then
            continue
        fi
        mapfile -t subs < <(fd -e ass -e mks -e srt . "$dir")
        sub=${subs[$counting - 1]}
        if [[ -f "$sub" ]]; then
            echo "Found sub: $sub"
            OPTIONS+=(--sub-file="$sub")
        fi
    done
}

fonts() {
    local where sub
    where="$1"
    if [[ $(fd -1 -e ttf -e otf . "$where") != "" ]]; then
        mkdir -p "$FONTS_DIR"
        (
            cd "$FONTS_DIR" || exit 1
            mapfile -t fonts < <(fd -e ttf -e otf . "$where")
            for font in "${fonts[@]}"; do
                ln -sf "$font" .
            done
        )
    fi
}

find_vid() {
    declare -a vids dubs
    local counting
    counting="$1"

    mapfile -t vids < <(fd --max-depth=1 -e mkv -e mp4)
    VID="${vids[$counting - 1]}"
    if [[ "$VID" == "" ]]; then
        echo "Couldn't find any video"
        exit 1
    fi
    echo "Found video: $VID"

    if [[ -f "$ARCHIVE" ]]; then
        if [[ ! -d "$EXT_DIR" ]]; then
            7z x -o"$EXT_DIR" "$ARCHIVE"
            echo "Extracting done"
        fi
        find_subs "$EXT_DIR"
        fonts "$EXT_DIR"
    else
        find_subs "$PWD"
        fonts "$PWD"
    fi

    mapfile -t dubs < <(fd -e mp3 -e ogg -e mka)
    if [[ ! "${#dubs[@]}" -eq 0 ]]; then
        dub="${dubs[$counting - 1]}"
        echo "Found dub: $dub"
        OPTIONS+=(--audio-file="$dub")
    fi
}

launch() {
    mpv --sub-fonts-dir="$FONTS_DIR" "${OPTIONS[@]}" "$@" "$VID"
}

history() {
    local cache dir hist_path
    cache="$HOME/.cache/mpv-history"
    mkdir -p "$cache"

    dir="$(realpath "$PWD")"
    hist_path="${dir//\//__}"
    HIST_FILE="$cache/$hist_path"
}

play() {
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
"verify")
    mapfile -t files < <(fd -e mkv -e mp4)
    for file in "${files[@]}"; do
        crc32-verify "$file"
    done
    ;;
*)
    history
    if [[ -e "$HIST_FILE" ]]; then
        cat "$HIST_FILE"
    fi
    ;;
esac
shopt -u extglob
