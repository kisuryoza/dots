#!/usr/bin/env sh

word="$2"

case "$1" in
"path")
    if [ -d "$word" ]; then
        exa --git -l --color=always --icons "$word"
    else
        if [ -f "$word" ]; then
            MIME=$(file --brief --dereference --mime-type "$word")
            CATEGORY=${MIME%%/*}
            KIND=${MIME##*/}

            echo "$MIME"

            case "$CATEGORY" in
            "text")
                bat --plain --color=always "$word"
                ;;
            "image")
                exa --git -l --color=always --icons "$word"
                ;;
            "audio" | "video")
                mediainfo "$word" | bat --plain --language=help --color=always
                ;;
            esac

            case "$KIND" in
            "pdf")
                pdftotext "$word" /dev/stdout
                ;;
            esac
        fi
    fi
    ;;
"make")
    make -n "$word" | bat --plain --language=sh --color=always
    ;;
*) ;;
esac
