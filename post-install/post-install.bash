#!/usr/bin/env bash

SCRIPT_PATH=$(realpath -s "${BASH_SOURCE[0]}")
USER=$(echo "$SCRIPT_PATH" | awk -F '/' '{print $3}')
HOME="/home/$USER"
REPO_NAME=$(echo "$SCRIPT_PATH" | awk -F '/' '{print $4}')
RESOURCES="$HOME/$REPO_NAME/post-install"

declare -a AUR_PKG
AUR_PKG+=(7-zip-full ueberzugpp)
AUR_PKG+=(librewolf-bin freetube-bin)
AUR_PKG+=(xkb-switch catppuccin-cursors-mocha ttf-comic-neue)
AUR_PKG+=(downgrade rate-mirrors-bin)
# AUR_PKG+=(pince-git)
if pacman -Q wlroots &>/dev/null; then
    AUR_PKG+=(swww) # Efficient animated wallpaper daemon for wayland, controlled at runtime.
fi

[[ -z "$DEBUG" ]] && DEBUG=false
"$DEBUG" && set -Eeuxo pipefail

source "$HOME/$REPO_NAME"/home/bin/helper-func.sh
source "$HOME/$REPO_NAME"/home/.profile

download_and_check() {
    local url=$1
    local dest=$2
    log "Downloading from $url and moving in $dest"
    curl --proto '=https' --tlsv1.3 -LsSf "$url" -o /tmp/pending
    bat /tmp/pending
    read -rp "Are we good? y/n: " y
    [[ $y == "y" ]] && install -vD /tmp/pending "$dest"
}

install_themes() {
    log "Installing themes"
    download_and_check "https://github.com/catppuccin/yazi/raw/main/themes/mocha.toml" "$XDG_CONFIG_HOME/yazi/theme.toml"
    download_and_check "https://github.com/catppuccin/bat/raw/main/themes/Catppuccin%20Mocha.tmTheme" "$XDG_CONFIG_HOME/yazi/Catppuccin-mocha.tmTheme"
    git clone --depth 1 https://github.com/Reledia/glow.yazi.git ~/.config/yazi/plugins/glow.yazi

    download_and_check "https://github.com/catppuccin/zathura/raw/main/src/catppuccin-mocha" "$XDG_CONFIG_HOME/zathura/catppuccin-mocha"
    download_and_check "https://github.com/catppuccin/alacritty/raw/main/catppuccin-mocha.toml" "$XDG_CONFIG_HOME/alacritty/catppuccin-mocha.toml"

    git clone https://github.com/catppuccin/Kvantum /tmp/Kvantum &&
        mkdir -p ~/.config/Kvantum &&
        mv /tmp/Kvantum/src/* ~/.config/Kvantum &&
        kvantummanager --set Catppuccin-Macchiato-Maroon
}

set_xdg_dirs() {
    log "Setting XDG directories"
    DIRS=(
        "$XDG_CONFIG_HOME" "$XDG_CACHE_HOME" "$XDG_DATA_HOME" "$XDG_STATE_HOME"
        "$XDG_CONFIG_HOME"/android/ "$XDG_CACHE_HOME"/less/ "$XDG_CONFIG_HOME"/npm
        "$XDG_CONFIG_HOME"/task/ "$HOME"/.local/bin/
    )

    for dir in "${DIRS[@]}"; do
        mkdir -p "$dir"
    done

    echo 'data.location=$XDG_CONFIG_HOME/task/' >"$XDG_CONFIG_HOME"/task/taskrc
    cat <<'EOF' >"$XDG_CONFIG_HOME"/npm/npmrc
prefix=${XDG_DATA_HOME}/npm
cache=${XDG_CACHE_HOME}/npm
init-module=${XDG_CONFIG_HOME}/npm/config/npm-init.js
tmp=${XDG_RUNTIME_DIR}/npm
EOF
}

post_user() {
    mkdir ~/.ssh
    echo "AddKeysToAgent yes" >~/.ssh/config

    mkdir ~/.gnupg
    echo "default-cache-ttl 3600" >~/.gnupg/gpg-agent.conf
    gpg-connect-agent reloadagent /bye

    localectl set-x11-keymap us,ru pc104 qwerty grp:win_space_toggle,caps:escape

    set_xdg_dirs
    mkdir ~/gitclones

    (
        log "Stowing $REPO_NAME"
        cd ~/"$REPO_NAME" || log "Couldn't cd to ~/$REPO_NAME" err 1
        stow -vt ~/.config config
        stow -v home
    )

    log "Syncing some dots $REPO_NAME with root"
    ~/bin/sync-with-root.bash

    rustup component add rust-analyzer
    mkdir ~/.config/zsh/zfunc

    (
        log "Installing paru"
        git clone https://aur.archlinux.org/paru-git.git /tmp/paru &&
            cd /tmp/paru &&
            makepkg -si

        cat <<EOF >"$HOME/.config/paru/paru.conf"
[options]
BottomUp
PgpFetch
NewsOnUpgrade
UpgradeMenu
EOF
    )

    log "Installing packages from AUR"
    paru -S --skipreview "${AUR_PKG[@]}" || log "AUR failed" err

    (
        log "Installing eww"
        git clone https://github.com/elkowar/eww ~/gitclones/eww && cd ~/gitclones/eww
        if pacman -Q gtk-layer-shell &>/dev/null; then
            RUSTFLAGS="-C target-cpu=native" cargo build --release --no-default-features --features=wayland
            install -vsDm 744 target/release/eww ~/.local/bin/eww-wayland
        else
            RUSTFLAGS="-C target-cpu=native" cargo build --release --no-default-features --features=x11
            install -vsDm 744 target/release/eww ~/.local/bin/eww-x
        fi
        cargo clean
    )

    mkdir -p "$HOME/.local/share/applications/"
    cat <<EOF >"$HOME/.local/share/applications/nvim.desktop"
[Desktop Entry]
Name=nvim
Exec=alacritty --command=nvim --command=%F
Type=Application
EOF

    gio mime inode/directory yazi.desktop
    gio mime application/x-shellscript nvim.desktop
    gio mime image/png imv-dir.desktop
    gio mime image/jpeg imv-dir.desktop
    gio mime x-scheme-handler/terminal Alacritty.desktop
    gio mime application/pdf org.pwmt.zathura.desktop
    gio mime application/x-bittorrent org.qbittorrent.qBittorrent.desktop
    if [[ -n $(command -v handlr) ]]; then
        handlr set 'inode/directory' yazi.desktop
        handlr set 'application/x-shellscript' nvim.desktop
        handlr set 'text/*' nvim.desktop
        handlr set 'audio/*' mpv.desktop
        handlr set 'video/*' mpv.desktop
        handlr set 'image/*' imv-dir.desktop
        handlr set 'x-scheme-handler/terminal' Alacritty.desktop
        handlr set 'application/pdf' org.pwmt.zathura.desktop
        handlr set 'application/x-bittorrent' org.qbittorrent.qBittorrent.desktop
    fi

    cat <<EOF >"$HOME/.xinitrc"
#!/usr/bin/bash
exec bspwm
EOF

    mkdir "$HOME/.config/git"
    cat <<EOF >"$HOME/.config/git/config"
[alias]
    lg = lg1
    lg1 = lg1-specific --all
    lg2 = lg2-specific --all
    lg3 = lg3-specific --all

    lg1-specific = log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(white)%s%C(reset) %C(dim white)- %an%C(reset)%C(auto)%d%C(reset)'
    lg2-specific = log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold cyan)%aD%C(reset) %C(bold green)(%ar)%C(reset)%C(auto)%d%C(reset)%n''          %C(white)%s%C(reset) %C(dim white)- %an%C(reset)'
    lg3-specific = log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold cyan)%aD%C(reset) %C(bold green)(%ar)%C(reset) %C(bold cyan)(committed: %cD)%C(reset) %C(auto)%d%C(reset)%n''          %C(white)%s%C(reset)%n''          %C(dim white)- %an <%ae> %C(reset) %C(dim white)(committer: %cn <%ce>)%C(reset)'
EOF

    install_themes

    git clone https://github.com/kisuryoza/arch-deploy ~/.local/bin/arch-deploy
}

post_root() {
    echo 'export ZDOTDIR=$HOME/.config/zsh' >>/etc/zsh/zshenv

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

        install -vDm 744 "$HOME/$REPO_NAME"/home/bin/misc/nvidia-fan-control.bash /usr/local/bin/
        install -vm 644 "$RESOURCES"/nvidia-fan-control.service /etc/systemd/system/
        install -vm 644 "$RESOURCES"/nvidia-fan-control.timer /etc/systemd/system/
    fi

    log "Configuring openresolv and dnscrypt-proxy"
    cat <<EOF >"/etc/resolvconf.conf"
nameserver ::1
nameserver 127.0.0.1
options edns0
EOF
    cat <<EOF >"/etc/NetworkManager/conf.d/dns.conf"
[main]
dns=none
EOF
    # sed -Ei "s|^#? server_names .*|server_names = ['quad9-dnscrypt-ip4-filter-ecs-pri']|" /etc/dnscrypt-proxy/dnscrypt-proxy.toml
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

    systemctl enable dnscrypt-proxy.service
    systemctl enable earlyoom.service
}

if [[ $(id -u) -eq 0 ]]; then
    post_root
else
    sudo "$SCRIPT_PATH"
    post_user
fi
