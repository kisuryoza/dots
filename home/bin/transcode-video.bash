#!/usr/bin/env bash
set -euo pipefail

type -p SvtAv1EncApp &>/dev/null || exit 127
type -p av1an &>/dev/null || exit 127
type -p ffmpeg &>/dev/null || exit 127
type -p jq &>/dev/null || exit 127
type -p mkvextract &>/dev/null || exit 127
type -p mkvmerge &>/dev/null || exit 127
type -p mkvpropedit &>/dev/null || exit 127
type -p opusenc &>/dev/null || exit 127

# https://github.com/master-of-zen/Av1an
# https://github.com/gianni-rosato/svt-av1-psy
# https://github.com/vapoursynth/bestsource
# paru -S av1an svt-av1-psy-git

declare -a VOPTS MERGE_PARAMS
declare -i ATRACK

OUTPUT_DIR="encods"
[[ ! -d "$OUTPUT_DIR" ]] && mkdir "$OUTPUT_DIR"

LIST='
[
  {
    "input_video": "",
    "input_subs": "",
    "output": ""
  }
]
'
ffmpeg_() {
    ffmpeg -hide_banner -v warning -stats "$@"
}

log() {
    local bold blue esc
    bold=$(tput bold)
    blue=$(tput setaf 4)
    esc=$(tput sgr0)
    printf "%s%s%s\n" "${bold}${blue}" "$1" "$esc"
}

select-file() {
    file=$(fd -e "$1" | fzy --prompt "Select a $2 file: ")
    [[ ! -f "$file" ]] && exit 1
    echo "$file"
}

crc32-rename() {
    local file checksum path
    file="$1"

    log "Calculating crc32"
    checksum="$(7z h "$file" | tail -n3 | head -n1 | sd '.*\s([\d\w]+)$' '$1')"
    path="${file%.*}"
    mv -v "$file" "$path [$checksum].mkv"
}

# https://www.matroska.org/technical/tagging.html
set-tags() {
    local file original tmpfile
    file="$1"
    original="$2"
    tmpfile="/tmp/encoding-settings.xml"

    log "Setting tags"
    cat <<EOF >"$tmpfile"
<?xml version="1.0"?>
<!-- <!DOCTYPE Tags SYSTEM "matroskatags.dtd"> -->
<Tags>
  <Tag>
    <Targets />
    <Simple>
      <Name>ENCODER</Name>
      <String>$(SvtAv1EncApp --version | head -n1)</String>
    </Simple>
    <Simple>
      <Name>ENCODER_SETTINGS</Name>
      <String>${VOPTS[*]}</String>
    </Simple>
  </Tag>
</Tags>
EOF
    mkvpropedit "$file" -t track:v1:"$tmpfile"
    rm "$tmpfile"

    if [[ $ATRACK -ge 0 ]]; then
        mapfile -t fields < <(mediainfo --Output=JSON "$original" |
            jq -r ".media.track[$((ATRACK + 2))] | .Language, .Channels")
        lang="${fields[0]}"
        ch=${fields[1]}
        mkvpropedit "$file" --edit track:a1 \
            --set "flag-default=1" \
            --set "language-ietf=$lang" \
            --set "name=[$lang] Opus 128kbps ${ch}ch"
    fi
}

merge() {
    local output video audio
    declare -a subtitle_tracks compression_args
    output="$1"
    video="$2"
    audio="$3"

    log "Merging files"
    # Extract subtitle track IDs using mkvmerge -J
    mapfile -t subtitle_tracks < <(mkvmerge -J "$video" |
        jq -r '.tracks[] | select(.type=="subtitles") | .id')
    # Prepare compression arguments for mkvmerge
    for track_id in "${subtitle_tracks[@]}"; do
        compression_args+=(--compression "$track_id:zlib")
    done
    # Use mkvmerge to remux the file, applying zlib compression to the identified subtitle tracks
    mkvmerge -o "$output" "${compression_args[@]}" "$video" "$audio" "${MERGE_PARAMS[@]}"

    rm -v "$tmpv" "$tmpa"
}

cut-encode() {
    INPUT=$(select-file "mkv" "video")
    log "Selected $INPUT"
    OUTPUT="$OUTPUT_DIR/cut.mkv"
    ATRACK=-1
    local start end
    start="00:12:50"
    end="00:13:10"

    log "Cutting from $start to $end"
    ffmpeg_ -i "$INPUT" -ss "$start" -to "$end" \
        -map 0:v:0 -pix_fmt yuv420p10le -f yuv4mpegpipe -strict -1 - |
        SvtAv1EncApp -i - "${VOPTS[@]}" --lp 4 --keyint 240 --scd 1 --progress 2 -b - |
        ffmpeg_ -i - -c:v copy "$OUTPUT"

    set-tags "$OUTPUT"
    crc32-rename "$OUTPUT"
    notify-send "Encoding completed"
}

encode-video() {
    local filename tmpv tmpa
    INPUT="${INPUT:-$(select-file "mkv" "video")}"
    filename="${INPUT%.*}"
    OUTPUT="${OUTPUT:-"$OUTPUT_DIR/$filename.mkv"}"
    tmpv="$OUTPUT_DIR/video-$filename.mkv"
    tmpa="$OUTPUT_DIR/audio-$filename.ogg"

    log "Encoding $INPUT"

    av1an -i "$INPUT" -e svt-av1 --resume \
        --workers 3 --sc-downscale-height=540 -x 240 -m bestsource --photon-noise=2 \
        -v "${VOPTS[*]}" -f "-an -vf \"scale=-2:'min(1080,ih)'\"" -a "-an" -c mkvmerge -o "$tmpv" --verbose

    case $ATRACK in
    -2) ffmpeg_ -i "$INPUT" -map 0:a -c:a copy "$tmpa" ;;
    -1) ;;
    *)
        ffmpeg_ -i "$INPUT" -map 0:a:"$ATRACK" -f flac - |
            opusenc --bitrate 128 - "$tmpa"
        ;;
    esac

    merge "$OUTPUT" "$tmpv" "$tmpa"

    set-tags "$OUTPUT" "$INPUT"
    crc32-rename "$OUTPUT"
    notify-send "Encoding completed"
}

encode-dir() {
    [[ "$LIST" == "" ]] && exit 2
    local len
    len=$(echo "$LIST" | jq -r '. | length')
    for ((i = 0; i < len - 1; i++)); do
        mapfile -t curr < <(echo "$LIST" | jq -r ".[$i] | .input_video, .input_subs, .output")
        INPUT="${curr[0]}"
        input_subs="${curr[1]}"
        output="${curr[2]}"
        if [[ $(fd --base-directory "$OUTPUT_DIR" "${output%.*}") != "" ]]; then
            log "Skipping $INPUT"
            continue
        fi
        OUTPUT="$OUTPUT_DIR/$output"
        MERGE_PARAMS=(--compression 0:zlib --language 0:rus "$input_subs")
        encode-video
    done
}

# --enable-cdef 1 - Smoothes mosquito noise around edges. Usefull at higher crf.
# --qp-scale-compress-strength - keeps quality consistent, in case of scenes that are lower quality,
# increasing this should mitigate or even eliminate that
VOPTS+=(--preset 2 --crf 30 --tune 3)
VOPTS+=(--lp 1 --enable-cdef 1 --enable-tf 1 --scm 0)
VOPTS+=(--enable-qm 1 --qm-min 8 --qm-max 15)
VOPTS+=(--keyint -1 --irefresh-type 1 --scd 0)
VOPTS+=(--variance-boost-strength 3 --variance-octile 6 --sharpness 2 --qp-scale-compress-strength 1)
# VOPTS+=(--frame-luma-bias 40)
VOPTS+=(--color-primaries 1 --transfer-characteristics 1 --matrix-coefficients 1)

# -1 - disable
# -2 - copy
ATRACK=-2

# encode-dir
encode-video
# cut-encode
