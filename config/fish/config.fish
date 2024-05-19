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

function nvimq
    nvim -q (rg --color=never --vimgrep --smart-case $argv[1] | psub)
end

bind \cf yazi

starship init fish | source
atuin init fish --disable-up-arrow | source
zoxide init fish | source
task
