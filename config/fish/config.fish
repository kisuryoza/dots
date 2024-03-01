if not status is-interactive
    return
end

set -g fish_greeting
set -gx GPG_TTY $(tty)

source ~/.alias

# Export environment variables
if test \( -r ~/.cache/fishvars \) -a \( -r ~/.cache/fishpaths \) -a \( ~/.cache/fishvars -nt ~/.profile \)
    export (cat ~/.cache/fishvars)
    set -l path (cat ~/.cache/fishpaths)
    eval set -gx PATH $path
else
    envsubst < ~/.profile | rg --pcre2 '^export (?!.*PATH.*)(\w+)=' | sd "(export |\")" "" > ~/.cache/fishvars
    export (cat ~/.cache/fishvars)
    envsubst < ~/.profile | rg '^export PATH' | sd 'export PATH=\"(.*)\"$' '$1' | sd ':' ' ' > ~/.cache/fishpaths
    set -l path (cat ~/.cache/fishpaths)
    eval set -gx PATH $path
end

# Auto starting ssh-agent
if not pgrep --full ssh-agent | string collect > /dev/null
    eval (ssh-agent -c)
    set -Ux SSH_AUTH_SOCK $SSH_AUTH_SOCK
    set -Ux SSH_AGENT_PID $SSH_AGENT_PID
end

starship init fish | source
atuin init fish --disable-up-arrow | source
task

function nvimq
    nvim -q (rg --color=never --vimgrep --smart-case $argv[1] | psub)
end

function transfer
    if test -z $argv[1]
        echo "No arguments specified.\nUsage:\n  transfer <file|directory>\n  ... | transfer <file_name>" >&2
        return 1
    end

    if not tty -s; then
        curl --upload-file "-" "https://transfer.sh/$argv[1]"
        return
    end

    set -l file $argv[1]
    set -l file_name $(basename "$file")
    if test ! -e "$file"
        echo "$file: No such file or directory" >&2
        return 1
    end

    if test -d "$file"
        set -l output "/tmp/$file_name.7z"
        if test -r "$output"
            rm "$output"
        end
        7z a -mx9 "$output" "$file"
        curl --upload-file "$output" "https://transfer.sh/$file_name.7z"
        rm "$output"
    else
        curl --upload-file "$file" "https://transfer.sh/$file_name"
    end
end
