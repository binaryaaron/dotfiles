[ -n "$_ENVVARS_SOURCED" ] && return; _ENVVARS_SOURCED=1

export XDG_HOME="${XDG_HOME:-$HOME}"
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$XDG_HOME/.config}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$XDG_HOME/.local/share}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$XDG_HOME/.cache}"
export XDG_BIN_HOME="${XDG_BIN_HOME:-$XDG_HOME/.local/bin}"
export EDITOR="${EDITOR:-vim}"
export HISTSIZE=100000

case ":$PATH:" in
    *:"$HOME/.local/bin":*) ;;
    *) export PATH="$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH" ;;
esac

[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"
