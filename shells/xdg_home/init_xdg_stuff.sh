#!/usr/bin/env bash

. "$DOTFILES/shells/utils.sh"

init_xdg_home() {
    mkdir -p "$XDG_CONFIG_HOME" "$XDG_CACHE_HOME" "$XDG_BIN_HOME"

    for bin in "$DOTFILES/shells/xdg_home/bin/"*; do
        _safe_symlink "$bin" "$XDG_BIN_HOME/$(basename "$bin")"
    done

    for config in "$DOTFILES/shells/xdg_home/config/"*; do
        _safe_symlink "$config" "$XDG_CONFIG_HOME/$(basename "$config")"
    done
}
