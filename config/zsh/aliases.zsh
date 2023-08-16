alias pac="sudo pacman -S --disable-download-timeout"
alias pacs="pacman -Ss"
alias pacd="sudo pacman -Rns"
alias clean="paru -c && paru -Sc"
alias emergency-update="sudo pacman -Sy archlinux-keyring && sudo pacman -Syu"
alias ua-drop-caches='sudo paccache -rk2; paru -Sc'
alias ua-update-all='export TMPFILE="$(mktemp)"; \
    sudo true; \
    rate-mirrors --save=$TMPFILE arch --max-delay=21600 \
    && sudo mv /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist-backup \
    && sudo mv $TMPFILE /etc/pacman.d/mirrorlist \
    && ua-drop-caches \
    && paru -Syyu'

alias ssc="sudo systemctl"
alias scu="systemctl --user"

alias rg="rg --color=always"
alias ip="ip -color=always"
alias diff="diff -u --color=always"

alias gitc="git clone --depth 1"
alias exa="exa --all --group-directories-first"
alias cat="bat -pp"
alias xcd='cd "$(xplr --print-pwd-as-result)"'
alias yt-dlp-audio="yt-dlp --extract-audio --audio-format mp3 --audio-quality 0"
alias wget="wget --hsts-file=$XDG_DATA_HOME/wget-hsts"
alias tsc="tsc -t esnext"
