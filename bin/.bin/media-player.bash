#!/usr/bin/env bash

[[ -z "$DEBUG" ]] && DEBUG=false
$DEBUG && set -Eeuxo pipefail

# Use MPD or MPRIS to control mediaplayers
INTERFACE="MPD"

# Preferable players for MPRIS
PLAYERS="spotify,pragha,mpv,%any"

function eww_update {
    [[ -x $(which eww) ]] && eww ping && eww update "$1"="$2"
}

function isMusicPlaying {
    case "$INTERFACE" in
        "MPD") [[ $(mpc status %state%) == "playing" ]] && echo "true" || echo "false" ;;
        "MPRIS") [[ $(playerctl --player="$PLAYERS" metadata --format '{{status}}') == "Playing" ]] && echo "true" || echo "false" ;;
        *) ;;
    esac
}

function update_artist {
    case "$INTERFACE" in
        "MPD") eww_update music-artist "$(mpc --format=%artist% current)" ;;
        "MPRIS") eww_update music-artist "$(playerctl --player=$PLAYERS metadata artist)" ;;
        *) ;;
    esac
}

function update_title {
    local title

    case "$INTERFACE" in
        "MPD")
            title=$(mpc --format=%title% current)
            if [[ -z "$title" ]]; then
                title=$(mpc --format=%file% current | awk -F "/" '{print $NF}')
            fi
            eww_update music-title "${title:0:20}"
            ;;
        "MPRIS") eww_update music-title "$(playerctl --player=$PLAYERS metadata title)" ;;
        *) ;;
    esac
}

function update_length {
    case "$INTERFACE" in
        "MPD") eww_update music-length "$(mpc status %totaltime%)" ;;
        "MPRIS") eww_update music-length "$(playerctl --player=$PLAYERS metadata mpris:length)" ;;
        *) ;;
    esac
}

function update_cover {
    local file dirname cover

    if [[ ! -d "$HOME/Music" ]]; then
        eww_update music-cover ""
        return
    fi

    case "$INTERFACE" in
        "MPD") file="$HOME/Music/$(mpc current -f %file%)" ;;
        "MPRIS")
            file=$(playerctl --player=$PLAYERS metadata --format '{{ xesam:url }}' | sed "s|%20| |g")
            file=${file:7}
            ;;
        *) ;;
    esac

    # in case if MPD loaded .cue as a dir
    if [[ -d "$file" ]]; then
        eww_update music-cover ""
        return
    fi

    # check if the folder of the song contains a cover
    dirname=$(dirname "$file")
    cover=$(fd --absolute-path --max-results=1 --exact-depth=1 -e png -e jpg "cover" "$dirname")
    if [[ -e "$cover" ]]; then
        eww_update music-cover "$cover"
        return
    fi
    # retrieve the album cover directly from the song
    ffmpeg -i "$file" /tmp/song-cover.jpg -y
    if [[ -e "/tmp/song-cover.jpg" ]]; then
        eww_update music-cover "/tmp/song-cover.jpg"
        return
    fi
    # or search from the upper folder
    cover=$(fd --absolute-path --max-results=1 --exact-depth=1 -e png -e jpg "cover" "$(dirname "$dirname")")
    if [[ -e "$cover" ]]; then
        eww_update music-cover "$cover"
        return
    fi
    # search for any image file
    cover=$(fd --absolute-path --max-results=1 -e png -e jpg . "$dirname")
    if [[ -e "$cover" ]]; then
        eww_update music-cover "$cover"
        return
    fi

    eww_update music-cover ""
}

function update_currenttime {
    case "$INTERFACE" in
        "MPD") eww_update music-currenttime "$(mpc status %currenttime%)" ;;
        "MPRIS") eww_update music-currenttime "$(playerctl --player=$PLAYERS metadata --format '{{ duration(position) }}')" ;;
        *) ;;
    esac
}

function update_progress {
    local progress position length

    case "$INTERFACE" in
        "MPD")
            progress=$(mpc status %percenttime%)
            eww_update music-progress ${progress:0:3}
            ;;
        "MPRIS")
            position=$(playerctl --player=$PLAYERS position)
            length=$(playerctl --player=$PLAYERS metadata mpris:length)
            [[ -z $position || -z $length ]] && echo 0 && exit
            position=${position%.*}
            length=${length:0:(-6)}

            eww_update music-progress $((position * 100 / length))
            ;;
        *) ;;
    esac
}

function update_volume {
    local volume

    case "$INTERFACE" in
        "MPD")
            volume=$(mpc status %volume%)
            volume=${volume:0:(-1)}
            ;;
        "MPRIS")
            ;;
        *) ;;
    esac
    echo "$volume"
}

case $1 in
    "isMusicPlaying")
        isMusicPlaying
        exit 0
        ;;
    "prev")
        case "$INTERFACE" in
            "MPD") mpc prev ;;
            "MPRIS") playerctl --player="$PLAYERS" previous ;;
            *) ;;
        esac
        exit 0
        ;;
    "play")
        case "$INTERFACE" in
            "MPD") mpc toggle ;;
            "MPRIS") playerctl --player="$PLAYERS" play-pause ;;
            *) ;;
        esac
        eww_update isMusicPlaying "$(isMusicPlaying)"
        exit 0
        ;;
    "next")
        case "$INTERFACE" in
            "MPD") mpc next ;;
            "MPRIS") playerctl --player="$PLAYERS" next ;;
            *) ;;
        esac
        exit 0
        ;;

    # *) exit 1 ;;
esac

FILE="/tmp/song-file.tmp"
if [[ -r "$FILE" ]]; then
    rm "$FILE"
    touch "$FILE"
fi
while eval "$(eww get isDashboardOpen)"; do
    if [[ "$HOME/Music/$(mpc --format=%file% current)" != "$(cat "$FILE")" ]]; then
        update_artist
        update_title
        update_length
        update_cover
        echo "$HOME/Music/$(mpc --format=%file% current)" > "$FILE"
    fi
    update_currenttime
    update_progress
    sleep 1
done

