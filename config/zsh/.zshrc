# If not running interactively, don't do anything
[[ $- != *i* ]] && return

if [[ -z "$ZELLIJ" ]]; then
    sleep 0.1
    if [[ "$ZELLIJ_AUTO_ATTACH" == "true" ]]; then
        zellij attach -c
    else
        zellij
    fi
    exit
fi

HISTFILE=$XDG_CACHE_HOME/zhistory
HISTSIZE=50000
SAVEHIST=50000

setopt CORRECT
setopt NUMERICGLOBSORT
setopt NOBEEP
setopt SHARE_HISTORY
setopt PROMPT_SUBST

bindkey -v

zmodload zsh/complist
zstyle ':completion:*' menu select

# disable sort when completing options of any command
zstyle ':completion:complete:*:options' sort false

zstyle ':completion:*:descriptions' format '%d'

# create a zkbd compatible hash;
# to add other keys to this hash, see: man 5 terminfo
typeset -g -A key

autoload -Uz up-line-or-beginning-search down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search

key[Home]="${terminfo[khome]}"
key[End]="${terminfo[kend]}"
key[Insert]="${terminfo[kich1]}"
key[Backspace]="${terminfo[kbs]}"
key[Delete]="${terminfo[kdch1]}"
key[Up]="${terminfo[kcuu1]}"
key[Down]="${terminfo[kcud1]}"
key[Left]="${terminfo[kcub1]}"
key[Right]="${terminfo[kcuf1]}"
key[PageUp]="${terminfo[kpp]}"
key[PageDown]="${terminfo[knp]}"
key[Shift-Tab]="${terminfo[kcbt]}"
key[Control-Left]="${terminfo[kLFT5]}"
key[Control-Right]="${terminfo[kRIT5]}"

# setup key accordingly
[[ -n "${key[Home]}"          ]] && bindkey -- "${key[Home]}"          beginning-of-line
[[ -n "${key[End]}"           ]] && bindkey -- "${key[End]}"           end-of-line
[[ -n "${key[Insert]}"        ]] && bindkey -- "${key[Insert]}"        overwrite-mode
[[ -n "${key[Backspace]}"     ]] && bindkey -- "${key[Backspace]}"     backward-delete-char
[[ -n "${key[Delete]}"        ]] && bindkey -- "${key[Delete]}"        delete-char
[[ -n "${key[Up]}"            ]] && bindkey -- "${key[Up]}"            up-line-or-beginning-search
[[ -n "${key[Down]}"          ]] && bindkey -- "${key[Down]}"          down-line-or-beginning-search
[[ -n "${key[Left]}"          ]] && bindkey -- "${key[Left]}"          backward-char
[[ -n "${key[Right]}"         ]] && bindkey -- "${key[Right]}"         forward-char
[[ -n "${key[PageUp]}"        ]] && bindkey -- "${key[PageUp]}"        beginning-of-buffer-or-history
[[ -n "${key[PageDown]}"      ]] && bindkey -- "${key[PageDown]}"      end-of-buffer-or-history
[[ -n "${key[Shift-Tab]}"     ]] && bindkey -- "${key[Shift-Tab]}"     reverse-menu-complete
[[ -n "${key[Control-Left]}"  ]] && bindkey -- "${key[Control-Left]}"  backward-word
[[ -n "${key[Control-Right]}" ]] && bindkey -- "${key[Control-Right]}" forward-word

# Finally, make sure the terminal is in application mode, when zle is
# active. Only then are the values from $terminfo valid.
if (( ${+terminfo[smkx]} && ${+terminfo[rmkx]} )); then
    autoload -Uz add-zle-hook-widget
    function zle_application_mode_start { echoti smkx }
    function zle_application_mode_stop { echoti rmkx }
    add-zle-hook-widget -Uz zle-line-init zle_application_mode_start
    add-zle-hook-widget -Uz zle-line-finish zle_application_mode_stop
fi


autoload -U colors zsh/terminfo
colors

fpath+="$ZDOTDIR"/zfunc

chpwd () command exa -a --group-directories-first

sort_history() {
    local temp=$(mktemp)
    cp "$HISTFILE" $temp
    cat -n "$temp" | sort -uk2 | sort -nk1 | cut -f2- > "$HISTFILE"
}

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

help() { "$@" --help | bat --plain --language=help }

vmrss() {
    [[ $1 ]] || { echo "Missing name of process(es)" >&2; return 1; }
    IFS=$' ' pidofs=($(pidof "$1"))
    while true; do
        for pid in "${pidofs[@]}"; do
            awk -v var="$pid" '/VmRSS/ {OFS="\t"; print "pid:", var, "|", "VmRSS:", $2, $3, int($2 / 1024), "mB"}' "/proc/$pid/status"
        done
        sleep 1
    done
}

source "$ZDOTDIR/aliases.zsh"

local ZSH_PUGINS="$HOME/.local/share/zsh"
if [[ -r "$ZSH_PUGINS"/fzf-tab-completion/zsh/fzf-zsh-completion.sh && -n $(whence -p fzf) ]]; then
    source "$ZSH_PUGINS"/fzf-tab-completion/zsh/fzf-zsh-completion.sh
    bindkey '^I' fzf_completion
    zstyle ':completion:*' fzf-search-display true

    # zstyle ':completion::*:*::*' fzf-completion-opts --preview='~/.config/zsh/fzf-preview.sh path $(eval echo {1})'
    zstyle ':completion::*:systemctl::systemctl,status,*' fzf-completion-opts --preview='SYSTEMD_COLORS=1 systemctl status -- $(eval echo {1})'
    zstyle ':completion::*:make::*' fzf-completion-opts --preview='make -n $(eval echo {1}) | bat --plain --language=sh --color=always'
    zstyle ':completion::*:btrfs::*' fzf-completion-opts --preview='btrfs $(eval echo {1}) --help | bat --plain --language=help --color=always'

    zstyle ':completion::*:git::git,diff,*' fzf-completion-opts --preview='git diff --color=always $(eval echo {1}) | delta'
    zstyle ':completion::*:git::git,show,*' fzf-completion-opts --preview='git show --color=always $(eval echo {1}) | delta'
    zstyle ':completion::*:git::git,checkout,*' fzf-completion-opts --preview='git show --color=always $(eval echo {1}) | delta'
    zstyle ':completion::*:git::git,log,*' fzf-completion-opts --preview='git log --color=always $(eval echo {1})'
    zstyle ':completion::*:git::git,help,*' fzf-completion-opts --preview='git help $(eval echo {1}) | bat --plain --language=man --color=always'

    zstyle ':completion::*:nix::*' fzf-completion-opts --preview='nix $(eval echo {1}) --help | bat --plain --language=help --color=always'
    zstyle ':completion::*:nix::nix,flake,*' fzf-completion-opts --preview='nix flake $(eval echo {1}) --help | bat --plain --language=help --color=always'
    zstyle ':completion::*:nix::nix,profile,*' fzf-completion-opts --preview='nix profile $(eval echo {1}) --help | bat --plain --language=help --color=always'
fi

if [[ -r "$ZSH_PUGINS"/zsh-autosuggestions/zsh-autosuggestions.zsh ]]; then
    source "$ZSH_PUGINS"/zsh-autosuggestions/zsh-autosuggestions.zsh
fi
if [[ -r "$ZSH_PUGINS"/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh ]]; then
    source "$ZSH_PUGINS"/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh
fi
if [[ -r "$ZSH_PUGINS"/nix-zsh-completions/nix-zsh-completions.plugin.zsh ]]; then
    source "$ZSH_PUGINS"/nix-zsh-completions/nix-zsh-completions.plugin.zsh
    fpath+="$ZSH_PUGINS"/nix-zsh-completions
fi

# fpath+="/nix/var/nix/profiles/default/share/zsh/site-functions"
autoload -Uz compinit && compinit

if [[ $(id -u) -ne 0 ]]; then
    # Auto starting ssh-agent
    if ! pgrep -u "$USER" ssh-agent >/dev/null; then
        ssh-agent > "$HOME/.ssh/ssh-agent.env"
    fi
    if [[ ! -f "$SSH_AUTH_SOCK" ]]; then
        source "$HOME/.ssh/ssh-agent.env" >/dev/null
    fi
fi

eval "$(starship init zsh)"

task
