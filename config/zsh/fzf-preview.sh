#!/usr/bin/env sh

case "$1" in
"path")
    if [ -d "$realpath" ]; then
        exa --git -l --color=always --icons "$realpath"
    else
        if [ -f "$realpath" ]; then
            MIME=$(file --brief --dereference --mime-type "$realpath")
            CATEGORY=${MIME%%/*}
            KIND=${MIME##*/}

            echo "$MIME"

            case "$CATEGORY" in
            "text")
                bat --plain --color=always "$realpath"
                ;;
            "image")
                exa --git -l --color=always --icons "$realpath"
                ;;
            "audio" | "video")
                mediainfo "$realpath" | bat --plain --language=help --color=always
                ;;
            esac

            case "$KIND" in
            "pdf")
                pdftotext "$realpath" /dev/stdout
                ;;
            esac
        fi
    fi
    ;;
"make")
    case "$group" in
    "make target")
        make -n "$word" | bat --plain --language=sh --color=always
        ;;
    "make variable")
        make -pq | rg -Ns "^$word = " | bat --plain --language=sh --color=always
        ;;
    "file")
        ~/.config/zsh/fzf-preview.sh path
        ;;
    esac
    ;;
"git-show")
    case "$group" in
    "commit tag")
        git show --color=always "$word"
        ;;
    *)
        git show --color=always "$word" | delta
        ;;
    esac
    ;;
"git-checkout")
    case "$group" in
    "modified file")
        git diff "$word" | delta
        ;;
    "recent commit object name")
        git show --color=always "$word" | delta
        ;;
    *)
        git log --color=always "$word"
        ;;
    esac
    ;;
*) ;;
esac
