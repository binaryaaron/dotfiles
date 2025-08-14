init_xdg_home() {
    if [ ! -d "$XDG_CONFIG_HOME" ]; then
    mkdir -p "$XDG_CONFIG_HOME"
    fi

    if [ ! -d "$XDG_CACHE_HOME" ]; then
        mkdir -p "$XDG_CACHE_HOME"
    fi

    if [ ! -d "$XDG_BIN_HOME" ]; then
        mkdir -p "$XDG_BIN_HOME"
    fi

    for bin in $(git rev-parse --show-toplevel)/shells/xdg_home/bin/*; do
        ln -s "$bin" "$XDG_BIN_HOME/$(basename $bin)"
    done

    for config in $(git rev-parse --show-toplevel)/shells/xdg_home/config/*; do
        ln -s "$config" "$XDG_CONFIG_HOME/$(basename $config)"
    done
}

