log() {
    local BOLD RED GREEN YELLOW BLUE ESC
    BOLD=$(tput bold)
    RED=$(tput setaf 1)
    GREEN=$(tput setaf 2)
    YELLOW=$(tput setaf 3)
    BLUE=$(tput setaf 4)
    ESC=$(tput sgr0)
    readonly BOLD RED GREEN YELLOW BLUE ESC
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
}
