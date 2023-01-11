chpwd () command exa -a --group-directories-first

function sort_history ()
{
    local temp=$(mktemp)
    cp "$HISTFILE" $temp
    cat -n "$temp" | sort -uk2 | sort -nk1 | cut -f2- > "$HISTFILE"
}

function cpp_compile ()
{
    [[ $1 ]]    || { echo "Missing operand" >&2; return 1; }
    [[ -r $1 ]] || { printf "File %s does not exist or is not readable\n" "$1" >&2; return 1; }
    local output=/tmp/$(basename $1)
    g++ "$1" -o "$output" && "$output"
}

function help()
{
    "$@" --help | bat --plain --language=help
}

function shutdown ()
{
    sleep $((60 * $1))
    systemctl poweroff
}
