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
setopt INC_APPEND_HISTORY        # New history lines are added as soon as they are entered, rather than waiting until the shell exits.

[[ -r ~/.alias ]] && source ~/.alias

###############################################################################
# bindkey -s '^F' "yazi\n"

# Vi to zsh
bindkey -v
export KEYTIMEOUT=1

# Editing command lines in vim
autoload -Uz edit-command-line
zle -N edit-command-line
bindkey -M vicmd '^v' edit-command-line

zmodload zsh/complist
bindkey -M menuselect 'h' vi-backward-char
bindkey -M menuselect 'k' vi-up-line-or-history
bindkey -M menuselect 'l' vi-forward-char
bindkey -M menuselect 'j' vi-down-line-or-history

bindkey '^?' backward-delete-char # backspace
bindkey '^[[3~' delete-char # delete

autoload -Uz up-line-or-beginning-search down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey "^[[A" up-line-or-beginning-search # arrow up
bindkey "^[[B" down-line-or-beginning-search # arrow down

bindkey "^[[1;5D" backward-word # ctrl left
bindkey "^[[1;5C" forward-word # ctrl right

###############################################################################
# Completion
autoload -Uz compinit
for dump in ~/.zcompdump(N.mh+24); do
    compinit
done
compinit -C

# setopt MENU_COMPLETE        # Automatically highlight first element of completion menu
setopt AUTO_LIST            # Automatically list choices on ambiguous completion.
setopt COMPLETE_IN_WORD     # Complete from both ends of a word.
setopt ALWAYS_TO_END        # If a completion is performed with the cursor within a word, and a full completion is inserted, the cursor is moved to the end of the word.

# Ztyle pattern
# :completion:<function>:<completer>:<command>:<argument>:<tag>
# Define completers
zstyle ':completion:*' completer _extensions _complete _approximate

# Use cache for commands using cache
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "$XDG_CACHE_HOME/.zcompcache"
# Complete the alias when _expand_alias is used as a function
zstyle ':completion:*' complete true
# Allow you to select in a menu
zstyle ':completion:*' menu select
# Autocomplete options for cd instead of directory stack
zstyle ':completion:*' complete-options true

zstyle ':completion:*' file-sort modification

# Colorful descriptions
zstyle ':completion:*:*:*:*:corrections' format '%F{yellow}!- %d (errors: %e) -!%f'
zstyle ':completion:*:*:*:*:descriptions' format '%F{blue}-- %D %d --%f'
zstyle ':completion:*:*:*:*:messages' format ' %F{purple} -- %d --%f'
zstyle ':completion:*:*:*:*:warnings' format ' %F{red}-- no matches found --%f'
# Colors for files and directory
zstyle ':completion:*:*:*:*:default' list-colors ${(s.:.)LS_COLORS}

# Required for completion to be in good groups (named after the tags)
zstyle ':completion:*' group-name ''
zstyle ':completion:*:*:-command-:*:*' group-order aliases builtins functions commands

# See ZSHCOMPWID "completion matching control"
zstyle ':completion:*' matcher-list '' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'

zstyle ':completion:*' keep-prefix true

###############################################################################
nvimq() {
    nvim -q <(rg --color=never --vimgrep --smart-case "$1")
}

# if [[ $(id -u) -ne 0 ]]; then
#     # Auto starting ssh-agent
#     if ! pgrep -u "$USER" ssh-agent >/dev/null; then
#         ssh-agent > "$HOME/.ssh/ssh-agent.env"
#     fi
#     if [[ ! -f "$SSH_AUTH_SOCK" ]]; then
#         source "$HOME/.ssh/ssh-agent.env" >/dev/null
#     fi
# fi
