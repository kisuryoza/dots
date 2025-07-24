CPU_VENDOR=$(awk -F ": " '/vendor_id/ {print $NF; exit}' /proc/cpuinfo)
case "$CPU_VENDOR" in
"GenuineIntel") PKG+=(intel-ucode) ;;
"AuthenticAMD") PKG+=(amd-ucode) ;;
esac

# essential
PKG+=(linux linux-firmware base base-devel)
PKG+=(efibootmgr e2fsprogs btrfs-progs)
PKG+=(zsh vim neovim tmux git networkmanager iwd iptables-nft wget)
PKG+=(man-db man-pages texinfo)
PKG+=(tealdeer wikiman arch-wiki-docs)
PKG+=(opendoas usbguard apparmor dnscrypt-proxy)
PKG+=(earlyoom)

# cli/tui helpers
PKG+=(strace lsof skim jq stow)
PKG+=(bind bandwhich net-tools nmap traceroute)
PKG+=(bat ripgrep sd fd dust hyperfine) # sane gnu replacments

# developing
PKG+=(nasm zig zls rustup rust-analyzer python)
PKG+=(perf lldb clang sccache valgrind)
PKG+=(radare2) # disasm, debug, analyze and manipulate binary files
PKG+=(prettier shellharden shfmt lua-language-server selene stylua)

# monitors
PKG+=(smartmontools sysstat acpi)
PKG+=(htop btop nvtop)

PKG+=(bubblewrap) # Unprivileged sandboxing tool
# PKG+=(aircrack-ng)  # Key cracker for the 802.11 WEP and WPA-PSK protocols

PKG+=(pacman-contrib)

if [[ "$WAYLAND" == true ]]; then
    PKG+=(foot)
    PKG+=(wlroots xorg-xwayland wl-clipboard)
    PKG+=(hyprland)
    PKG+=(xdg-desktop-portal-hyprland)
    # PKG+=(xdg-desktop-portal-wlr)
    PKG+=(qt5-wayland qt6-wayland)
    PKG+=(swayidle)              # Idle management daemon
    PKG+=(swaylock)              # Screen locker
    PKG+=(bemenu bemenu-wayland) # Wayland (wlroots-based compositors) renderer for bemenu
    PKG+=(grim slurp)            # screenshoter
    PKG+=(waybar)                # bar
    AUR_PKG+=(swww)
fi

if [[ "$XORG" == true ]]; then
    CPU_VENDOR=$(awk -F ": " '/vendor_id/ {print $NF; exit}' /proc/cpuinfo)
    case "$CPU_VENDOR" in
    "GenuineIntel") PKG+=(xf86-video-intel) ;;
    "AuthenticAMD") PKG+=(xf86-video-amdgpu) ;;
    esac

    PKG+=(alacritty)
    PKG+=(xorg-server xorg-xinit xclip)
    PKG+=(xdg-desktop-portal-gtk)
    PKG+=(bspwm sxhkd xdo)
    PKG+=(xss-lock i3lock)   # Screen locker
    PKG+=(picom)             # compositor
    PKG+=(bemenu bemenu-x11) # X11 renderer for bemenu
    PKG+=(flameshot)         # screenshoter
    PKG+=(feh)               # for wallpaper setting
fi

if [[ "$WAYLAND" == true || "$XORG" == true ]]; then
    PKG+=(mesa mesa-utils glfw vulkan-icd-loader lib32-vulkan-icd-loader)
    PKG+=(xdg-desktop-portal)

    GRAPHICS=$(lspci -v | grep -A1 -e VGA -e 3D)
    case ${GRAPHICS^^} in
    *NVIDIA*) PKG+=(linux-headers nvidia-dkms nvidia-utils lib32-nvidia-utils libva-nvidia-driver nvidia-settings) ;;
    *AMD* | *ATI*) PKG+=(xf86-video-ati libva-mesa-driver vulkan-radeon lib32-vulkan-radeon) ;;
    *INTEL*) PKG+=(intel-media-driver vulkan-intel lib32-vulkan-intel) ;;
    esac

    # -- Multimedia

    PKG+=(pipewire wireplumber pipewire-alsa pipewire-pulse gst-plugins-base gst-plugins-good gst-plugin-pipewire)
    PKG+=(pamixer pavucontrol qpwgraph)

    PKG+=(imv)              # Image viewer for Wayland and X11
    PKG+=(mpd mpc rmpc)     # Music player
    PKG+=(mpv mediainfo songrec noise-suppression-for-voice)
    # PKG+=(soundconverter)   # A simple sound converter application for GNOME
    # PKG+=(lmms)             # The Linux MultiMedia Studio
    PKG+=(imagemagick jpegoptim oxipng ffmpeg mkvtoolnix-gui opus-tools)

    # -- Utilities

    PKG+=(syncthing)            # file synchronization client/server application
    PKG+=(nm-connection-editor) # NetworkManager GUI connection editor and widgets

    PKG+=(yazi ffmpegthumbnailer)
    PKG+=(android-file-transfer)
    PKG+=(ouch)             # Archiving and compression
    PKG+=(udisks2)          # Daemon, tools and libraries to access and manipulate disks, storage devices and technologies
    PKG+=(fuseiso)          # FuseISO is a FUSE module to let unprivileged users mount ISO filesystem images
    PKG+=(gvfs gvfs-mtp)    # Virtual filesystem implementation
    PKG+=(handlr-regex)     # Powerful alternative to xdg-utils (managing mime types)
    PKG+=(trash-cli)        # Command line trashcan (recycle bin) interface
    PKG+=(libnotify)
    PKG+=(mate-polkit) # graphical authentication agent
    PKG+=(dunst)       # Customizable and lightweight notification-daemon
    PKG+=(yt-dlp)
    # PKG+=(tlp) # Linux Advanced Power Management

    PKG+=(hunspell hunspell-en_us hunspell-ru enchant gspell)

    # -- Themes, icons, fonts

    PKG+=(kvantum kvantum-qt5 lxappearance-gtk3)
    PKG+=(arc-gtk-theme breeze-icons)
    PKG+=(ttf-liberation noto-fonts noto-fonts-cjk)

    # -- Apps

    PKG+=(libreoffice-fresh qbittorrent keepassxc zathura zathura-pdf-mupdf)
    PKG+=(krita)
    AUR_PKG+=(paru-git shellcheck-bin eww dragon-drop)
    AUR_PKG+=(librewolf-bin freetube-bin)
    AUR_PKG+=(xkb-switch catppuccin-cursors-mocha ttf-comic-neue)
    AUR_PKG+=(downgrade rate-mirrors-bin)
    # AUR_PKG+=(pince-git)

    # -- Wine

    PKG+=(wine-staging winetricks gamemode lib32-gamemode)
    # https://github.com/lutris/docs/blob/master/WineDependencies.md#archendeavourosmanjaroother-arch-derivatives
    PKG+=(giflib lib32-giflib gnutls lib32-gnutls v4l-utils lib32-v4l-utils)
    PKG+=(sqlite lib32-sqlite libxcomposite)
    PKG+=(lib32-libxcomposite ocl-icd lib32-ocl-icd libva lib32-libva gtk3 lib32-gtk3 gst-plugins-base-libs)
    PKG+=(lib32-gst-plugins-base-libs vulkan-icd-loader lib32-vulkan-icd-loader sdl2-compat lib32-sdl2-compat)
    PKG+=(lib32-pipewire libpulse lib32-libpulse alsa-plugins lib32-alsa-plugins alsa-lib lib32-alsa-lib)
fi
