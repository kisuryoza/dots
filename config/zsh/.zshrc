# If not running interactively, don't do anything
[[ $- != *i* ]] && return

HISTFILE=$XDG_CACHE_HOME/zhistory
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

eval "$(dircolors -b)"
[[ -r ~/.alias ]] && source ~/.alias

###############################################################################
bindkey -s '^F' "tmux-sessionizer\n"

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
# Plugins
if [[ $(id -u) -ne 0 ]]; then
    local ZSH_PUGINS="$HOME/.local/share/zsh"
    [[ -d $ZSH_PUGINS ]] || mkdir -p $ZSH_PUGINS

    local plugin=zsh-completions
    [[ -d $ZSH_PUGINS/$plugin ]] || \
        git clone --depth 1 https://github.com/zsh-users/$plugin $ZSH_PUGINS/$plugin
    fpath=($ZSH_PUGINS/$plugin/src $fpath)

    local plugin=zsh-autosuggestions
    [[ -d $ZSH_PUGINS/$plugin ]] || \
        git clone --depth 1 https://github.com/zsh-users/$plugin $ZSH_PUGINS/$plugin
    source $ZSH_PUGINS/$plugin/zsh-autosuggestions.zsh

    local plugin=fast-syntax-highlighting
    [[ -d $ZSH_PUGINS/$plugin ]] || \
        git clone --depth 1 https://github.com/zdharma-continuum/$plugin $ZSH_PUGINS/$plugin
    source $ZSH_PUGINS/$plugin/fast-syntax-highlighting.plugin.zsh

    local plugin=nix-zsh-completions
    [[ -d $ZSH_PUGINS/$plugin ]] || \
        git clone --depth 1 https://github.com/nix-community/$plugin $ZSH_PUGINS/$plugin
    source $ZSH_PUGINS/$plugin/nix-zsh-completions.plugin.zsh
    fpath=($ZSH_PUGINS/$plugin $fpath)

    # fpath=(/nix/var/nix/profiles/default/share/zsh/site-functions $path)

    # if [[ -n $(command -v fzf) ]]; then
    #     local plugin=fzf-tab-completion
    #     [[ -d $ZSH_PUGINS/$plugin ]] || \
    #         git clone --depth 1 https://github.com/lincheney/$plugin $ZSH_PUGINS/$plugin
    #     source $ZSH_PUGINS/$plugin/zsh/fzf-zsh-completion.sh
    #
    #     bindkey '^I' fzf_completion
    #     zstyle ':completion:*' fzf-search-display true
    #
    #     zstyle ':completion::*:*::*' fzf-completion-opts --preview='~/.config/zsh/fzf-preview.sh path $(eval echo {1})'
    #     zstyle ':completion::*:systemctl::systemctl,status,*' fzf-completion-opts --preview='SYSTEMD_COLORS=1 systemctl status -- $(eval echo {1})'
    #     zstyle ':completion::*:make::*' fzf-completion-opts --preview='make -n $(eval echo {1}) | bat --color=always -plsh'
    #
    #     zstyle ':completion::*:git::git,diff,*' fzf-completion-opts --preview='git diff --color=always $(eval echo {1}) | delta'
    #     zstyle ':completion::*:git::git,show,*' fzf-completion-opts --preview='git show --color=always $(eval echo {1}) | delta'
    #     zstyle ':completion::*:git::git,checkout,*' fzf-completion-opts --preview='git show --color=always $(eval echo {1}) | delta'
    #     zstyle ':completion::*:git::git,log,*' fzf-completion-opts --preview='git log --color=always $(eval echo {1})'
    #     zstyle ':completion::*:git::git,help,*' fzf-completion-opts --preview='git help $(eval echo {1}) | bat --color=always -plhelp'
    #
    #     zstyle ':completion::*:nix::*' fzf-completion-opts --preview='nix $(eval echo {1}) --help | bat --color=always -plhelp'
    #     zstyle ':completion::*:nix::nix,flake,*' fzf-completion-opts --preview='nix flake $(eval echo {1}) --help | bat --color=always -plhelp'
    #     zstyle ':completion::*:nix::nix,profile,*' fzf-completion-opts --preview='nix profile $(eval echo {1}) --help | bat --color=always -plhelp'
    #
    #     zstyle ':completion::*:docker::*' fzf-completion-opts --preview='docker help $(eval echo {1}) | bat --color=always -plhelp'
    #     zstyle ':completion::*:docker::docker,run,*' fzf-completion-opts --preview='docker images "$(eval echo {1})"'
    #     zstyle ':completion::*:docker::docker,image,*' fzf-completion-opts --preview='docker image "$(eval echo {1})" --help | bat --color=always -plhelp'
    #
    #     # local plugin=fzf-tab
    #     # [[ -d $ZSH_PUGINS/$plugin ]] || git clone --depth 1 https://github.com/Aloxaf/$plugin $ZSH_PUGINS/$plugin
    #     # source $ZSH_PUGINS/$plugin/fzf-tab.plugin.zsh
    #     #
    #     # # zstyle ':fzf-tab:complete:docker:argument-1' fzf-preview 'docker help $word | bat --color=always -plhelp'
    #     # zstyle ':fzf-tab:complete:docker-(run|images):*' fzf-preview 'docker images $word'
    #     # zstyle ':fzf-tab:complete:docker-inspect:' fzf-preview 'docker inspect $word | bat --color=always -pljson'
    #     # zstyle ':fzf-tab:complete:docker-image:argument-1' fzf-preview 'docker image $word --help | bat --color=always -plhelp'
    #     # zstyle ':fzf-tab:complete:docker-container:argument-1' fzf-preview 'docker container $word --help | bat --color=always -plhelp'
    #     # # zstyle '' fzf-preview ''
    #     #
    #     # # zstyle ':fzf-tab:complete:(\\|*/|)jq:argument-rest' fzf-preview '[[ -f $realpath ]] && jq -Cr . $realpath 2>/dev/null || less $realpath'
    # fi

    unset plugin

    fpath=($ZDOTDIR/zfunc $fpath)
fi

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

if [[ $(id -u) -ne 0 && -n $(command -v fzf) ]]; then
    source /usr/share/fzf/completion.zsh

    _fzf_compgen_path() {
        fd --hidden --follow --exclude ".git" . "$1"
    }

    _fzf_compgen_dir() {
        fd --type d --hidden --follow --exclude ".git" "$1"
    }

    _fzf_comprun() {
        local command=$1
        shift

        case "$command" in
            cd)           fzf --preview 'eza {} | head -200'   "$@" ;;
            export|unset) fzf --preview "eval 'echo \$'{}"         "$@" ;;
            ssh)          fzf --preview 'dig {}'                   "$@" ;;
            *)            fzf --preview 'bat -n --color=always {}' "$@" ;;
        esac
    }
fi

###############################################################################
chpwd () command exa -a --group-directories-first

cx_repl() {
    [[ -r $1 ]] || { printf "File %s does not exist or is not readable" "$1" >&2; return 1; }
    local ext=$(awk -F. '{print $NF}' <<<"$1")
    local output=/tmp/$(basename $1)
    if [[ "$ext" -eq "c" ]]; then
        clang "$1" -o "$output" && "$output"
    elif [[ "$ext" -eq "cpp" ]]; then
        g++ "$1" -o "$output" && "$output"
    fi
}

nvimq() {
    nvim -q <($(fc -nl -1))
}

rustup_doc_force_dark_theme() {
    sd '\("preferred-light-theme"\)\|\|"light"' '("preferred-light-theme")||"ayu"' \
        ~/.local/share/rustup/toolchains/stable-x86_64-unknown-linux-gnu/share/doc/rust/html/static.files/storage-*.js
}

transfer() {
    if [ $# -eq 0 ]; then
        echo "No arguments specified.\nUsage:\n  transfer <file|directory>\n  ... | transfer <file_name>" >&2
        return 1
    fi

    if ! tty -s; then
        curl --upload-file "-" "https://transfer.sh/$1"
        return
    fi

    local file="$1"
    local file_name=$(basename "$file")
    if [ ! -e "$file" ]; then
        echo "$file: No such file or directory" >&2
        return 1
    fi

    if [ -d "$file" ]; then
        local output="/tmp/$file_name.7z"
        if [ -r "$output" ]; then
            rm "$output"
        fi
        7z a -mx9 "$output" "$file"
        curl --upload-file "$output" "https://transfer.sh/$file_name.7z"
        rm "$output"
    else
        curl --upload-file "$file" "https://transfer.sh/$file_name"
    fi
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

eval "$(starship init zsh)"
eval "$(atuin init zsh --disable-up-arrow)"
task
