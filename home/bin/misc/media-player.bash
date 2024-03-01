#!/usr/bin/env bash

function eww_update {
    [[ -x $(which eww) ]] && eww ping && eww update "$1"="$2"
}

function is_music_playing {
    [[ $(mpc status %state% 2> /dev/null) == "playing" ]] && echo "true" || echo "false"
}

function update_artist {
    eww_update music-artist "$(mpc --format=%artist% current)"
}

function update_title {
    local title
    title=$(mpc --format=%title% current)
    if [[ -z "$title" ]]; then
        title=$(mpc --format=%file% current | awk -F "/" '{print $NF}')
    fi
    eww_update music-title "${title:0:20}"
}

function update_length {
    eww_update music-length "$(mpc status %totaltime%)"
}

function update_cover {
    local file dirname cover

    if [[ ! -d "$HOME/Music" ]]; then
        eww_update music-cover ""
        return
    fi

    file="$HOME/Music/$(mpc current -f %file%)"

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
    ffmpeg -i "$file" /tmp/song-cover.jpg -y || rm "/tmp/song-cover.jpg"
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
    eww_update music-currenttime "$(mpc status %currenttime%)"
}

function update_progress {
    local progress
    progress=$(mpc status %percenttime% 2> /dev/null || echo 0)
    eww_update music_progress ${progress:0:3}
}

function update_volume {
    local volume
    volume=$(mpc status %volume%)
    volume=${volume:0:(-1)}
    echo "$volume"
}

case $1 in
    "prev")
        mpc prev
        exit 0
        ;;
    "play")
        mpc toggle
        exit 0
        ;;
    "next")
        mpc next
        exit 0
        ;;

    # *) exit 1 ;;
esac

# FILE="/tmp/song-file.tmp"
# if [[ -r "$FILE" ]]; then
#     rm "$FILE"
#     touch "$FILE"
# fi
# while eval "$(eww get isDashboardOpen)"; do
#     if [[ "$HOME/Music/$(mpc --format=%file% current)" != "$(cat "$FILE")" ]]; then
#         update_artist
#         update_title
#         update_length
#         update_cover
#         echo "$HOME/Music/$(mpc --format=%file% current)" >"$FILE"
#     fi
#     update_currenttime
#     update_progress
#     sleep 1
# done

while eval "$(eww get is_music_player_hovered)"; do
    update_progress
    sleep 1
done
