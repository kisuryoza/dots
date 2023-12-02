#!/usr/bin/env bash

word="$2"

if [ -d "$word" ]; then
    eza --oneline --git --group-directories-first --color=always --icons "$word"
else
    if [ -f "$word" ]; then
        MIME=$(file --brief --dereference --mime-type "$word")
        CATEGORY=${MIME%%/*}
        KIND=${MIME##*/}

        case "$CATEGORY" in
        "text")
            echo "$MIME"
            bat --plain --color=always "$word"
            ;;
        "audio" | "video")
            echo "$MIME"
            mediainfo "$word" | bat --color=always -plhelp
            ;;
        esac

        case "$KIND" in
        "pdf")
            pdftotext "$word" /dev/stdout
            ;;
        esac
    fi
fi
