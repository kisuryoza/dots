#!/usr/bin/env bash

SCRIPT_PATH=$(realpath -s "${BASH_SOURCE[0]}")
USER=$(echo "$SCRIPT_PATH" | awk -F '/' '{print $3}')
HOME="/home/$USER"
REPO_NAME=$(echo "$SCRIPT_PATH" | awk -F '/' '{print $4}')
RESOURCES="$HOME/$REPO_NAME/post-install/deploy-cfg"

[[ -z "$DEBUG" ]] && DEBUG=false
$DEBUG && set -Eeuxo pipefail

source "$HOME"/"$REPO_NAME"/home/.bin/helper-func.sh

function post_user {
    declare -a AUR_PKG
    AUR_PKG+=(shellcheck-bin)
    AUR_PKG+=(codelldb-bin) # A native debugger extension for VSCode based on LLDB.
    AUR_PKG+=(librewolf-bin)
    AUR_PKG+=(freetube-bin) # An open source desktop YouTube player built with privacy in mind.
    AUR_PKG+=(catppuccin-gtk-theme-mocha ttf-material-design-icons-desktop-git ttf-comic-neue ttf-comic-mono-git)
    AUR_PKG+=(downgrade rate-mirrors-bin)
    AUR_PKG+=(bob-bin)      # A version manager for neovim
    # AUR_PKG+=(xkb-switch-git) # Program that allows to query and change the XKB layout state
    # AUR_PKG+=(thokr-git)      # A sleek typing tui written in rust
    # AUR_PKG+=(greetd greetd-tuigreet-bin)
    # AUR_PKG+=(pince-git bottles)

    if pacman -Q wlroots &>/dev/null; then
        AUR_PKG+=(swww) # Efficient animated wallpaper daemon for wayland, controlled at runtime.
    fi

    sudo pacman -S --needed base-devel cmake unzip ninja tree-sitter curl clang

    export XDG_CONFIG_HOME="$HOME/.config"
    export XDG_CACHE_HOME="$HOME/.cache"
    export XDG_DATA_HOME="$HOME/.local/share"
    export XDG_STATE_HOME="$HOME/.local/state"
    export RUSTUP_HOME="$XDG_DATA_HOME"/rustup
    export CARGO_HOME="$XDG_DATA_HOME"/cargo
    export RUSTC_WRAPPER=sccache

    declare -a DIRS
    DIRS+=("$XDG_CONFIG_HOME" "$XDG_CACHE_HOME" "$XDG_DATA_HOME" "$XDG_STATE_HOME")
    DIRS+=("$XDG_CONFIG_HOME/android/" "$XDG_CACHE_HOME/less/" "$XDG_DATA_HOME/wallpapers/" "$HOME/.local/bin/")

    for DIR in "${DIRS[@]}"; do
        mkdir -p "$DIR"
    done

    log "Stowing $REPO_NAME"
    mkdir ~/.librewolf ~/gitclones
    cd ~/"$REPO_NAME" || log "Couldn't cd to ~/$REPO_NAME" err 1
    stow -vt ~/.config config
    stow -v home

    log "Syncing some $REPO_NAME with root"
    ~/.bin/sync-with-root.bash

    log "Installing Rust"
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs -o /tmp/rustup.sh &&
        chmod +x /tmp/rustup.sh &&
        /tmp/rustup.sh --no-modify-path

    RUSTUP="$CARGO_HOME/bin/rustup"
    $RUSTUP component add rust-analyzer

    (
        log "Installing paru"
        git clone --depth 1 https://aur.archlinux.org/paru-git.git /tmp/paru &&
            cd /tmp/paru &&
            makepkg -si
    )

    log "Installing packages from AUR"
    paru -S --skipreview "${AUR_PKG[@]}" || log "AUR failed" err

    log "Installing packages from git..."
    ~/.bin/pkg-from-git.bash all

    log "Installing neovim"
    bob use nightly
    mkdir -p "$HOME/.local/share/applications/"
    cat <<EOF >"$HOME/.local/share/applications/nvim.desktop"
[Desktop Entry]
Name=nvim
Exec=nvim-gui
Type=Application
EOF

    (
        log "Installing zsh plugins"
        ZSH_PUGINS="$HOME/.local/share/zsh/plugins"
        mkdir -p "$ZSH_PUGINS" && cd "$ZSH_PUGINS"
        git clone --depth 1 https://github.com/Aloxaf/fzf-tab
        git clone --depth 1 https://github.com/zsh-users/zsh-autosuggestions
        git clone --depth 1 https://github.com/zdharma-continuum/fast-syntax-highlighting
        git clone --depth 1 https://github.com/nix-community/nix-zsh-completions
    )

    if is_in_path mpv; then
        log "Installing mpv additional features"
        git clone --depth 1 https://github.com/occivink/mpv-scripts.git /tmp/mpv-scripts &&
            rm /tmp/mpv-scripts/scripts/blur-edges.lua &&
            mv --target-directory="$HOME/.config/mpv/" /tmp/mpv-scripts/script-opts/ /tmp/mpv-scripts/scripts/

        git clone --depth 1 https://github.com/bloc97/Anime4K.git /tmp/Anime4K &&
            mkdir -p ~/.config/mpv/shaders &&
            fd --extension="glsl" . /tmp/Anime4K -x mv {} ~/.config/mpv/shaders
    fi

    if is_in_path startx; then
        (
            log "Installing sxlock"
            git clone --depth 1 https://github.com/lahwaacz/sxlock.git ~/gitclone/sxlock &&
                cd ~/gitclone/sxlock &&
                make &&
                sudo make install &&
                sudo install -vDm 644 "$RESOURCES"/sxlock.service /etc/systemd/system/sxlock.service &&
                systemctl enable sxlock.service
        )

        (
            log "Installing a cursor"
            wget -O /tmp/cursor.tar.gz "$(curl -s https://api.github.com/repos/ful1e5/Bibata_Cursor/releases/latest | grep 'browser_' | cut -d\" -f4 | grep -E "Bibata-Original-Classic.tar.gz")" &&
                cd ~/.icons &&
                tar -xvf /tmp/cursor.tar.gz
        )
    fi

    if is_in_path zathura; then
        log "Installing zathura themes"
        git clone --depth 1 https://github.com/catppuccin/zathura /tmp/zathura &&
            install -vDm 644 /tmp/zathura/src/* -t ~/.config/zathura/
    fi

    if is_in_path kvantummanager; then
        log "Installing Kvantum themes"
        git clone --depth 1 https://github.com/catppuccin/Kvantum /tmp/Kvantum &&
            mkdir -P ~/.config/Kvantum &&
            mv /tmp/Kvantum/src/* ~/.config/Kvantum &&
            kvantummanager --set Catppuccin-Macchiato-Maroon
    fi

    if is_in_path handlr; then
        handlr set 'inode/directory' thunar.desktop
        handlr set 'text/*' nvim.desktop
        handlr set 'text/plain' nvim.desktop
        handlr set 'application/x-shellscript' nvim.desktop
        handlr set 'audio/*' mpv.desktop
        handlr set 'image/*' imv.desktop
        handlr set 'image/jpeg' imv.desktop
        handlr set 'image/png' imv.desktop
    fi

    git clone --depth 1 https://github.com/justAlex0/arch-deploy ~/.local/bin/arch-deploy
}

function post_root {
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
    install -vDm 644 "$RESOURCES"/10-update-NextDNS-IP.sh /etc/NetworkManager/dispatcher.d/10-update-NextDNS-IP.sh
    systemctl enable NetworkManager-dispatcher.service

    log "Configuring openresolv"
    {
        echo "name_servers=\"127.0.0.1\""
        echo "name_servers_append=\"::1\""
        echo "resolv_conf_options=\"edns0\""
    } >>/etc/resolvconf.conf
    systemctl enable dnscrypt-proxy.service
    resolvconf -u
    {
        echo "[main]"
        echo "rc-manager=resolvconf"
    } >/etc/NetworkManager/conf.d/rc-manager.conf
    printf "\nnohook resolv.conf" >/etc/dhcpcd.conf
    mkdir /etc/iwd
    {
        echo "[General]"
        echo "EnableNetworkConfiguration=True"
    } >/etc/iwd/main.conf
}

if [[ $(id -u) -eq 0 ]]; then
    post_root
else
    sudo "$SCRIPT_PATH"
    post_user
fi
