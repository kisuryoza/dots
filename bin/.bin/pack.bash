#!/usr/bin/env bash

[[ -z "$DEBUG" ]] && DEBUG=false
$DEBUG && set -Eeuxo pipefail

SCRIPT="$(realpath -s "${BASH_SOURCE[0]}")"

# {{{ Help and log
$DEBUG && set +ux
BOLD=$(tput bold)
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
ESC=$(tput sgr0)
readonly BOLD RED GREEN YELLOW ESC
$DEBUG && set -ux

function log {
    $DEBUG && set +ux
    case "$2" in
    "err")
        printf "%s[%s]%s\n" "${BOLD}${RED}" "$1" "${ESC}" >&2
        ;;
    "warn")
        printf "%s[%s]%s\n" "${BOLD}${YELLOW}" "$1" "${ESC}"
        ;;
    *)
        printf "%s[%s]%s\n" "${BOLD}${GREEN}" "$1" "${ESC}"
        ;;
    esac
    if [[ -n "$3" ]]; then
        exit "$3"
    fi
    $DEBUG && set -ux
}

function help {
    local filename
    filename="$(basename "$SCRIPT")"
    printf "The script packages binary files into the copy of itself
for using one script for distributing and manipulating its binary content

Usage:
    %s [OPTIONS]

    Unpacks:
    %s -d|--dest=<path>

    Packs:
    %s -t|--tar=<directory>
    %s -s|--squash=<directory>
    %s -p|--pack=<file>

Options:
    -t, --tar       Packages a directory as tar.gz
    -s, --squash    Packages a directory as SquashFS
    -p, --pack      Packages an executable binary
    -d, --dest      Where to unpack
" "$filename" "$filename" "$filename" "$filename" "$filename"
}
# }}}

function pack_in {
    SIZE=$(stat --printf="%s" "$1")

    cp "$SCRIPT" ./"$OUTPUT"
    log "Package output: $OUTPUT"
    log "Package size: $((SIZE / 1024 / 1024)) Mib"

    sed -Ei "s|^SIZE=.*|SIZE=$SIZE|" ./"$OUTPUT"
    cat "$1" >>./"$OUTPUT"
}

# {{{ SquashFS
function pack_squash {
    local tmp
    log "Packaging $1 as SquashFS"
    if [[ ! -d "$1" ]]; then
        log "It should be a directory" err 1
    fi

    tmp="$(mktemp -d)"
    trap 'rm -rf -- $TEMP' QUIT EXIT INT
    OUTPUT="$(basename "$1").sqsh.bash"

    [[ -f "$tmp/file.sqsh" ]] && rm "$tmp/file.sqsh"
    mksquashfs "$1" "$tmp/file.sqsh"

    pack_in "$tmp/file.sqsh"

    exit 0
}

function unsquash_mount {
    trap unsquash_unmount QUIT INT
    log "Creating loopback device with SquashFS file and mounting it"

    DEVICE=$(udisksctl loop-setup --file "$SCRIPT" --offset $(($(stat --printf="%s" "$SCRIPT") - SIZE)) | awk '{print $NF}' | sed "s|.$||")
    MOUNTED_AT=$(udisksctl mount -b "$DEVICE" | awk '{print $NF}')
    if [[ -n "$MOUNTED_AT" ]]; then
        log "Mounted at $MOUNTED_AT"
    else
        log "Failed to mount" err 1
    fi

    if [[ -f "$MOUNTED_AT/start" ]]; then
        log "Launching $MOUNTED_AT/start"
        "$MOUNTED_AT/start"
    else
        log "Waiting for any signal to unmount" warn
        read -r
    fi

    unsquash_unmount
}

function unsquash_unmount {
    log "Unmounting SquashFS and deleting loopback device"

    if [[ -n "$MOUNTED_AT" ]]; then
        while ! udisksctl unmount -b "$DEVICE"; do
            log "Couldn't unmount $DEVICE at $MOUNTED_AT, device is busy" err
            log "Make sure all inner processes are closed then hit ENTER" warn
            read -r
        done
    fi

    udisksctl loop-delete -b "$DEVICE"
}
# }}}

# {{{ tar archive
function pack_tar {
    local tmp
    log "Packaging $1 as compressed tar arhive"
    if [[ ! -d "$1" ]]; then
        log "It should be a directory" err 1
    fi

    tmp="$(mktemp -d)"
    trap 'rm -rf -- $TEMP' QUIT EXIT INT
    OUTPUT="$(basename "$1").tar.gz.bash"

    tar -cf "$tmp/file.tar" "$1"
    gzip "$tmp/file.tar"

    pack_in "$tmp/file.tar.gz"

    exit 0
}

function untar {
    log "Untaring arhive at $DIR"
    tail --bytes="$SIZE" "$0" | tar -xzv -C "$DIR"
}
# }}}

# {{{ bin
function pack_bin {
    log "Packaging binary"
    OUTPUT="$(basename "$1").bin.bash"
    pack_in "$1"

    exit 0
}

function unpack_bin {
    log "Unpacking file as $DIR/$NAME"
    tail --bytes="$SIZE" "$0" >"$DIR/$NAME"
    chmod u+x "$DIR/$NAME"
    "$DIR/$NAME"
}
# }}}

# {{{ Variables
SIZE=
DIR="$PWD"
NAME="$(basename "$SCRIPT")"
NAME="${NAME%.*}"
# }}}

# {{{ Options parser
LONG_OPTS=squash:,tar:,pack:,dest:,help
SHORT_OPTS=s:t:p:d:h
PARSED=$(getopt --options ${SHORT_OPTS} \
    --longoptions ${LONG_OPTS} \
    --name "$0" \
    -- "$@")
eval set -- "${PARSED}"

while true; do
    case "$1" in
    -s | --squash)
        pack_squash "$2"
        ;;
    -t | --tar)
        pack_tar "$2"
        ;;
    -p | --pack)
        pack_bin "$2"
        ;;
    -d | --dest)
        if [[ ! -d "$2" ]]; then
            log "$2 is not dir" err 1
        fi
        DIR="$2"
        shift
        ;;
    -h | --help)
        help
        exit 0
        ;;
    --)
        shift
        break
        ;;
    *)
        echo "Error while was passing the options"
        help
        exit 1
        ;;
    esac
done
# }}}

case "$NAME" in
*"tar.gz"*)
    untar
    ;;
*"sqsh"*)
    unsquash_mount
    ;;
*"bin"*)
    unpack_bin
    ;;
esac

exit 0
