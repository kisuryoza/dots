export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"

export QT_STYLE_OVERRIDE=kvantum
export MANPAGER="sh -c 'col -bx | bat -l man -p'"
export BROWSER="librewolf"
export EDITOR="nvim"
export VISUAL="nvim"
export BAT_THEME="gruvbox-dark"

export ANDROID_HOME="$XDG_DATA_HOME"/android
export CUDA_CACHE_PATH="$XDG_CACHE_HOME"/nv
export GNUPGHOME="$XDG_DATA_HOME"/gnupg
export LESSHISTFILE="$XDG_CACHE_HOME"/less/history

# Rust
export RUSTUP_HOME="$XDG_DATA_HOME"/rustup
export CARGO_HOME="$XDG_DATA_HOME"/cargo
export RUSTC_WRAPPER=sccache

if [[ "$XDG_SESSION_TYPE" == "wayland" ]]; then
    export MOZ_ENABLE_WAYLAND=1
fi

typeset -U path PATH
path=(~/.local/bin ~/.bin "$CARGO_HOME"/bin $path)
export PATH
