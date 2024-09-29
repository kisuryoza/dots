#!/usr/bin/env bash

type -p jq &>/dev/null || exit 127
type -p mkvextract &>/dev/null || exit 127
type -p mkvmerge &>/dev/null || exit 127

attachments() {
    local video info name id
    declare -a list
    video="$1"
    info="$(mkvmerge -J "$video")"

    mapfile -t ID < <(echo "$info" | jq -r '.attachments[] | .id')
    mapfile -t NAMES < <(echo "$info" | jq -r '.attachments[] | .file_name')

    [[ ! -d "attachments" ]] && mkdir "attachments"
    for ((i = 0; i < ${#ID[@]}; i++)); do
        id="${ID[i]}"
        name="${NAMES[i]}"
        list+=("$id:attachments/$name")
    done

    mkvextract "$video" attachments "${list[@]}"
}

subs() {
    local video info video_name id name
    declare -a list
    video="$1"
    info="$(mkvmerge -J "$video")"
    video_name="$(basename "$video")"

    mapfile -t ID < <(echo "$info" | jq -r '.tracks[] | select(.type=="subtitles") | .id')
    mapfile -t NAMES < <(echo "$info" | jq -r '.tracks[] | select(.type=="subtitles") | .properties | .track_name')

    for ((i = 0; i < ${#ID[@]}; i++)); do
        id="${ID[i]}"
        name="${NAMES[i]}"
        [[ ! -d "$name" ]] && mkdir "$name"
        list+=("$id:$name/${video_name/mkv/ass}")
    done

    mkvextract "$video" tracks "${list[@]}"
}

main() {
    mapfile -t FILES < <(fd -e mkv)
    for file in "${FILES[@]}"; do
        attachments "$file"
        subs "$file"
    done

}

main

# fd -e mkv -x bash -c 'echo "{}"; mediainfo --output=JSON "{}" | jq -r '\''.media | .track[] | select(."@type" == "Audio" or ."@type" == "Text") | [."@type", .Title, .Language] | @tsv'\'''
# Copy .mkv file with audio #2 and subs #4, others will be dropped. ID starts at 0.
# fd -j1 -e mkv -x mkvmerge -o "{/}" --audio-tracks 2 --subtitle-tracks 4 "{}"
