# If not running interactively, don't do anything
[[ $- != *i* ]] && return

HISTFILE=$HOME/.cache/zhistory
HISTSIZE=10000
SAVEHIST=10000

setopt NUMERICGLOBSORT
setopt NOBEEP
setopt PROMPT_SUBST

setopt CORRECT              # Spelling correction
setopt EXTENDED_GLOB        # Use extended globbing syntax.

setopt EXTENDED_HISTORY          # Write the history file in the ':start:elapsed;command' format.
setopt SHARE_HISTORY             # Share history between all sessions.
setopt HIST_EXPIRE_DUPS_FIRST    # Expire a duplicate event first when trimming history.
setopt HIST_IGNORE_DUPS          # Do not record an event that was just recorded again.
setopt HIST_IGNORE_ALL_DUPS      # Delete an old recorded event if a new event is a duplicate.
setopt HIST_FIND_NO_DUPS         # Do not display a previously found event.
setopt HIST_IGNORE_SPACE         # Do not record an event starting with a space.
setopt HIST_SAVE_NO_DUPS         # Do not write a duplicate event to the history file.
setopt HIST_VERIFY               # Do not execute immediately upon history expansion.
WORDCHARS=${WORDCHARS/\/}

setopt AUTO_PUSHD           # Push the current directory visited on the stack.
setopt PUSHD_IGNORE_DUPS    # Do not store duplicates in the stack.
setopt PUSHD_SILENT         # Do not print the directory stack after pushd or popd.
alias d='dirs -v'
for index ({1..9}) alias "$index"="cd +${index}"; unset index

eval "$(dircolors)"
autoload -Uz colors && colors

autoload -Uz promptinit && promptinit
PS1="%F{magenta}%~%(?.. %F{red}%B(%?%)%b)%f %# "
function preexec() {
    timer=$(($(date +%s%0N)/1000000))
}

function precmd() {
    if [ $timer ]; then
        now=$(($(date +%s%0N)/1000000))
        elapsed=$(($now-$timer))

        if [ $elapsed -gt 60000 ]; then
            elapsed=$(echo "$elapsed" | awk '{ printf "%dm %.1fs", $1 / 1000 / 60, $1 / 1000 % 60 }')
            export RPS1="%F{cyan}${elapsed} %f"
        elif [ $elapsed -gt 1000 ]; then
            export RPS1="%F{cyan}${elapsed}ms %f"
        else
            export RPS1=""
        fi
        unset timer
    fi
}

zmodload zsh/complist
zstyle ':completion:*' menu select yes
zstyle ':completion:*' completer _extensions _complete _approximate
zstyle ':completion:*:*:*:*:descriptions' format '%F{green}-- %d --%f'
zstyle ':completion:*' group-name ''
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}

autoload -Uz compinit
if [[ -n ${ZDOTDIR}/.zcompdump(#qN.mh+24) ]]; then
    compinit;
else
    compinit -C;
fi
_comp_options+=(globdots)

bindkey -v
autoload -Uz edit-command-line
zle -N edit-command-line
bindkey '^e' edit-command-line
bindkey -M menuselect '^h' vi-backward-char
bindkey -M menuselect '^k' vi-up-line-or-history
bindkey -M menuselect '^l' vi-forward-char
bindkey -M menuselect '^j' vi-down-line-or-history
bindkey -M menuselect '/' history-incremental-search-forward
bindkey -M menuselect '?' history-incremental-search-backward
# remap because enabling vim mode clears them
bindkey '^?' backward-delete-char
bindkey '^[[3~' delete-char
bindkey '^w' backward-delete-word

autoload -Uz up-line-or-beginning-search down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey "^k" up-line-or-beginning-search
bindkey "^j" down-line-or-beginning-search
bindkey "[A" up-line-or-beginning-search
bindkey "[B" down-line-or-beginning-search

filemanager() {
    yazi
    # cd $(yazi --cwd-file=/dev/stdout)
}
zle -N filemanager
bindkey '^f' filemanager
# bindkey -s '^f' "yazi\n"

[[ -r ~/.alias ]] && source ~/.alias

nvimq() {
    nvim -q <(rg --color=never --vimgrep --smart-case "$1")
}

if [[ $(id -u) -ne 0 ]]; then
    # Auto starting ssh-agent
    if ! pgrep -u "$USER" ssh-agent >/dev/null; then
        ssh-agent > "$HOME/.ssh/ssh-agent.env"
    fi
    if [[ ! -f "$SSH_AUTH_SOCK" ]]; then
        source "$HOME/.ssh/ssh-agent.env" >/dev/null
    fi
fi
