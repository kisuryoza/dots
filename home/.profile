export XDG_CONFIG_HOME=$HOME/.config
export XDG_CACHE_HOME=$HOME/.cache
export XDG_DATA_HOME=$HOME/.local/share
export XDG_STATE_HOME=$HOME/.local/state

# export MOZ_ENABLE_WAYLAND=1
export QT_STYLE_OVERRIDE=kvantum
export MANPAGER="sh -c 'col -bx | bat -l man -p'"
export MANROFFOPT="-c"
export BROWSER=librewolf
export EDITOR=nvim
export VISUAL=nvim
export BAT_THEME=gruvbox-dark
export GIT_EXTERNAL_DIFF=difft
GPG_TTY=$(tty)
export GPG_TTY

export ANDROID_HOME=$XDG_DATA_HOME/android
export CUDA_CACHE_PATH=$XDG_CACHE_HOME/nv
export LESSHISTFILE=$XDG_CACHE_HOME/less/history

# Rust
export RUSTUP_HOME=$XDG_DATA_HOME/rustup
export CARGO_HOME=$XDG_DATA_HOME/cargo
export RUSTC_WRAPPER=/usr/bin/sccache

export PATH="$HOME/bin:$HOME/.local/bin:$CARGO_HOME/bin:${PATH}"
