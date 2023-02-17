# If not running interactively, don't do anything
[[ $- != *i* ]] && return

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
autoload -Uz compinit
compinit
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

source "$ZDOTDIR/functions.zsh"
source "$ZDOTDIR/aliases.zsh"

if [[ $(id -u) -ne 0 ]]; then
    if [[ -n $(whence -p fzf) ]]; then
        source /usr/share/fzf/completion.zsh
        source "$HOME"/.local/share/zsh/plugins/fzf-tab/fzf-tab.plugin.zsh
        # zstyle ':fzf-tab:*' fzf-command sk
        zstyle ':fzf-tab:complete:*:' fzf-preview '~/.config/zsh/fzf-preview.sh path'
        zstyle ':fzf-tab:complete:systemctl-*:*' fzf-preview 'SYSTEMD_COLORS=1 systemctl status $word'
        zstyle ':fzf-tab:complete:(g|b|d|p|freebsd-|)make:' fzf-preview '~/.config/zsh/fzf-preview.sh make'

        zstyle ':fzf-tab:complete:git-(add|diff|restore):*' fzf-preview 'git diff $word | delta'
        zstyle ':fzf-tab:complete:git-log:*' fzf-preview 'git log --color=always $word'
        zstyle ':fzf-tab:complete:git-show:*' fzf-preview '~/.config/zsh/fzf-preview.sh git-show'
        zstyle ':fzf-tab:complete:git-checkout:*' fzf-preview '~/.config/zsh/fzf-preview.sh git-checkout'
        zstyle ':fzf-tab:complete:git-help:*' fzf-preview 'git help $word | bat --plain --language=man --color=always'

        zstyle ':fzf-tab:complete:docker-container:argument-1' fzf-preview 'docker container $word --help | bat --plain --language=help --color=always'
        zstyle ':fzf-tab:complete:docker-image:argument-1' fzf-preview 'docker image $word --help | bat --plain --language=help --color=always'
        zstyle ':fzf-tab:complete:docker-inspect' fzf-preview 'docker inspect $word | bat --plain --language=json --color=always'
        zstyle ':fzf-tab:complete:docker-(run|images):argument-1' fzf-preview 'docker images $word'
        zstyle ':fzf-tab:complete:docker-help:argument-1' fzf-preview 'docker help $word | bat --plain --language=help --color=always'

    # zstyle ':fzf-tab:complete:*:options' fzf-preview
    # zstyle ':fzf-tab:complete:*:argument-1' fzf-preview
    fi
    source "$HOME"/.local/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
    source "$HOME"/.local/share/zsh/plugins/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh
fi

eval "$(starship init zsh)"
# task
