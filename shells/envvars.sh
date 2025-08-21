#!/bin/sh

shell_type=$(basename $SHELL)
XDG_HOME=${XDG_HOME:-$HOME}
XDG_CONFIG_HOME=${XDG_CONFIG_HOME:-$XDG_HOME/.config}
XDG_CACHE_HOME=${XDG_CACHE_HOME:-$XDG_HOME/.cache}
XDG_BIN_HOME=${XDG_BIN_HOME:-$XDG_HOME/.local/bin}

export XDG_HOME
export XDG_CONFIG_HOME
export XDG_CACHE_HOME
export XDG_BIN_HOME
export EDITOR='vim'

HISTFILE="$HOME/.${shell_type}_history"
HISTSIZE=100000
SAVEHIST=100000
export PATH="$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH"

if [ -f "$HOME/.cargo/env" ]; then
    . "$HOME/.cargo/env"
fi


# add binaries to PATH if they aren't added yet
# affix colons on either side of $PATH to simplify matching
case ":${PATH}:" in
    *:"$HOME/.local/bin":*)
        ;;
    *)
    # Prepending path in case a system-installed binary needs to be overridden
    export PATH="$HOME/.local/bin:$PATH"
    ;;
esac
