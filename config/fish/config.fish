if not status is-interactive
    return
end

set -g fish_greeting
set -gx GPG_TTY $(tty)

source ~/.alias

function fish_prompt
    set -l last_status $status
    set -l normal (set_color normal)
    set -l color_cwd $fish_color_cwd
    set -l suffix '>'

    if functions -q fish_is_root_user; and fish_is_root_user
        set color_cwd (set_color red)
        set suffix '#'
    end

    set -l stat
    if test $last_status -ne 0
        set stat (set_color red)"[$last_status]$normal"
    end

    echo -n -s \
        (set_color $color_cwd) (prompt_pwd --full-length-dirs 2) $normal \
        (fish_vcs_prompt) $normal \
        $stat \
        $suffix ' '
end

function fish_right_prompt
    if test $CMD_DURATION -lt 5000
        return
    end

    set -l duration
    if test $CMD_DURATION -ge 60000
        set duration (echo "$CMD_DURATION" | awk '{ printf "%dm %.1fs", $1 / 1000 / 60, $1 / 1000 % 60 }') # minutes
    else
        set duration (echo "$CMD_DURATION" | awk '{ printf "%.1fs", $1 / 1000 }') # seconds
    end
    echo -n -s $duration
end

function mank
    man -k . | fzf -q "$1" --prompt='man> ' --preview 'echo {} | tr -d \'()\' | awk \'{printf "%s ", $2} {print $1}\' | xargs -r man' | tr -d '()' | awk '{printf "%s ", $2} {print $1}' | xargs -r man
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

zoxide init fish | source
