#!/usr/bin/env bash

SCRIPT_PATH=$(realpath -s "${BASH_SOURCE[0]}")
USER=$(echo "$SCRIPT_PATH" | awk -F '/' '{print $3}')
HOME="/home/$USER"
REPO_NAME=$(echo "$SCRIPT_PATH" | awk -F '/' '{print $4}')
RESOURCES="$HOME/$REPO_NAME/post-install/deploy-cfg"

[[ -z "$DEBUG" ]] && DEBUG=false
$DEBUG && set -Eeuxo pipefail

source "$HOME"/"$REPO_NAME"/home/bin/helper-func.sh
source "$HOME"/"$REPO_NAME"/home/.profile

function post_user {
    declare -a AUR_PKG
    AUR_PKG+=(shellcheck-bin)
    AUR_PKG+=(codelldb-bin) # A native debugger extension for VSCode based on LLDB.
    AUR_PKG+=(librewolf-bin)
    AUR_PKG+=(freetube-bin) # An open source desktop YouTube player built with privacy in mind.
    AUR_PKG+=(catppuccin-gtk-theme-mocha ttf-material-design-icons-desktop-git ttf-comic-neue ttf-comic-mono-git)
    AUR_PKG+=(downgrade rate-mirrors-bin)
    # AUR_PKG+=(xkb-switch-git) # Program that allows to query and change the XKB layout state
    # AUR_PKG+=(greetd greetd-tuigreet-bin)
    # AUR_PKG+=(pince-git bottles)

    if pacman -Q wlroots &>/dev/null; then
        AUR_PKG+=(swww) # Efficient animated wallpaper daemon for wayland, controlled at runtime.
    fi

    sudo pacman -S --needed base-devel cmake unzip ninja tree-sitter curl clang

    declare -a DIRS
    DIRS+=("$XDG_CONFIG_HOME" "$XDG_CACHE_HOME" "$XDG_DATA_HOME" "$XDG_STATE_HOME")
    DIRS+=("$XDG_CONFIG_HOME/android/" "$XDG_CACHE_HOME/less/" "$HOME/.local/bin/")

    for DIR in "${DIRS[@]}"; do
        mkdir -p "$DIR"
    done

    log "Stowing $REPO_NAME"
    mkdir ~/gitclones
    cd ~/"$REPO_NAME" || log "Couldn't cd to ~/$REPO_NAME" err 1
    stow -vt ~/.config config
    stow -v home

    log "Syncing some $REPO_NAME with root"
    ~/bin/sync-with-root.bash

    log "Installing Rust"
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs -o /tmp/rustup.sh &&
        less -M /tmp/rustup.sh &&
        log "Are we good?" warn &&
        read -r &&
        chmod +x /tmp/rustup.sh &&
        /tmp/rustup.sh --no-modify-path

    RUSTUP="$CARGO_HOME/bin/rustup"
    $RUSTUP component add rust-analyzer
    mkdir ~/.config/zsh/zfunc
    $RUSTUP completions zsh cargo >~/.config/zsh/zfunc/_cargo
    $RUSTUP completions zsh rustup >~/.config/zsh/zfunc/_rustup

    (
        log "Installing paru"
        git clone --depth 1 https://aur.archlinux.org/paru-git.git /tmp/paru &&
            cd /tmp/paru &&
            makepkg -si
    )

    log "Installing packages from AUR"
    paru -S --skipreview "${AUR_PKG[@]}" || log "AUR failed" err

    log "Installing packages from git..."
    ~/bin/pkg-from-git.bash all

    if [[ -n $(command -v mpv) ]]; then
        log "Installing mpv additional features"
        git clone --depth 1 https://github.com/occivink/mpv-scripts.git /tmp/mpv-scripts &&
            rm /tmp/mpv-scripts/scripts/blur-edges.lua &&
            mv --target-directory="$HOME/.config/mpv/" /tmp/mpv-scripts/script-opts/ /tmp/mpv-scripts/scripts/

        git clone --depth 1 https://github.com/bloc97/Anime4K.git /tmp/Anime4K &&
            mkdir -p ~/.config/mpv/shaders &&
            fd --extension="glsl" . /tmp/Anime4K -x mv {} ~/.config/mpv/shaders
    fi

    (
        log "Installing a cursor"
        wget -O /tmp/cursor.tar.gz "$(curl -s https://api.github.com/repos/ful1e5/Bibata_Cursor/releases/latest | grep 'browser_' | cut -d\" -f4 | grep -E "Bibata-Original-Classic.tar.gz")" &&
            cd ~/.icons &&
            tar -xvf /tmp/cursor.tar.gz

        log "Applying themes"
        {
            echo "[Icon Theme]"
            echo "Inherits=Bibata-Original-Classic"
        } >~/.icons/default/index.theme

        {
            echo "gtk-theme-name=Catppuccin-Mocha-Standard-Red-dark"
            echo "gtk-icon-theme-name=breeze-dark"
            echo "gtk-font-name=DejaVu Sans 11"
            echo "gtk-cursor-theme-name=Bibata-Original-Classic"
        } >~/.config/gtk-3.0/settings.ini
    )

    if [[ -n $(command -v zathura) ]]; then
        log "Installing zathura themes"
        git clone --depth 1 https://github.com/catppuccin/zathura /tmp/zathura &&
            install -vDm 644 /tmp/zathura/src/* -t ~/.config/zathura/
    fi

    if [[ -n $(command -v kvantummanager) ]]; then
        log "Installing Kvantum themes"
        git clone --depth 1 https://github.com/catppuccin/Kvantum /tmp/Kvantum &&
            mkdir -p ~/.config/Kvantum &&
            mv /tmp/Kvantum/src/* ~/.config/Kvantum &&
            kvantummanager --set Catppuccin-Macchiato-Maroon
    fi

    mkdir -p "$HOME/.local/share/applications/"
    cat <<EOF >"$HOME/.local/share/applications/nvim.desktop"
[Desktop Entry]
Name=nvim
Exec=alacritty --command=nvim --command=%F
Type=Application
EOF

    if [[ -n $(command -v handlr) ]]; then
        handlr set 'inode/directory' thunar.desktop
        handlr set 'text/*' nvim.desktop
        handlr set 'text/plain' nvim.desktop
        handlr set 'application/x-shellscript' nvim.desktop
        handlr set 'audio/*' mpv.desktop
        handlr set 'image/*' imv-dir.desktop
        handlr set 'image/jpeg' imv-dir.desktop
        handlr set 'image/png' imv-dir.desktop
    fi

    log "Setting crontab"
    cat <<'EOF' >/tmp/crontab
* * * * * for i in {1..30}; do sar -u 2 1 | awk 'ENDFILE {usage=100-$NF; printf("\%3u\n", usage)}' >> /tmp/cpu-load & sleep 2; done
* * * * * for i in {1..30}; do free | awk '$1 ~ /Mem/ {printf("\%3u\n", 100*$3/$2)}' >> /tmp/ram-load; sleep 2; done
0 * * * * tail -n1 /tmp/cpu-load > /tmp/cpu-load; tail -n1 /tmp/ram-load > /tmp/ram-load
*/5 * * * * ~/bin/misc/battery.bash
*/30 * * * * [ -r "/tmp/.dbus-address" ] && source /tmp/.dbus-address && pgrep --exact dunst && notify-send -i " " "$USER" "fix the poisture"
EOF
    crontab /tmp/crontab

    git clone --depth 1 https://github.com/kisuryoza/arch-deploy ~/.local/bin/arch-deploy
}

function post_root {
    echo 'export ZDOTDIR=$HOME/.config/zsh' > /etc/zsh/zshenv

    log "Configuring pacman"
    # sed -Ei 's|^#?MAKEFLAGS=.*|MAKEFLAGS="-j4"|' /etc/makepkg.conf
    install -vDm 644 "$RESOURCES"/hooks/* -t /etc/pacman.d/hooks

    if pacman -Q nvidia-utils &>/dev/null; then
        log "Tweaking NVIDIA"
        {
            echo "options nvidia-drm modeset=1"
            echo "options nvidia NVreg_UsePageAttributeTable=1"
        } >/etc/modprobe.d/nvidia.conf
        files=$(grep "FILES=" /etc/mkinitcpio.conf)
        eval "$files"
        files+=(/etc/modprobe.d/nvidia.conf)
        sed -Ei "s|^#?FILES=.*|FILES=(${files[*]})|" /etc/mkinitcpio.conf
        mkinitcpio -p linux-zen || mkinitcpio -p linux
    fi

    log "WiFi fixes"
    {
        echo "[device]"
        echo "wifi.scan-rand-mac-address=no"
    } >/etc/NetworkManager/NetworkManager.conf

    log "NetworkManager-dispatcher"
    install -vDm 744 "$RESOURCES"/10-update-NextDNS-IP.sh /etc/NetworkManager/dispatcher.d/10-update-NextDNS-IP.sh
    systemctl enable NetworkManager-dispatcher.service

    # log "Configuring openresolv"
    # {
    #     echo "name_servers=\"127.0.0.1\""
    #     echo "name_servers_append=\"::1\""
    #     echo "resolv_conf_options=\"edns0\""
    # } >>/etc/resolvconf.conf
    # systemctl enable dnscrypt-proxy.service
    # resolvconf -u
    # {
    #     echo "[main]"
    #     echo "rc-manager=resolvconf"
    # } >/etc/NetworkManager/conf.d/rc-manager.conf
    # printf "\nnohook resolv.conf" >/etc/dhcpcd.conf
    # mkdir /etc/iwd
    # {
    #     echo "[General]"
    #     echo "EnableNetworkConfiguration=True"
    # } >/etc/iwd/main.conf

    systemctl enable cronie.service
}

if [[ $(id -u) -eq 0 ]]; then
    post_root
else
    sudo "$SCRIPT_PATH"
    post_user
fi
