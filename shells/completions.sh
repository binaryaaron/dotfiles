
shell_type=$(basename $SHELL)
if command -v direnv &> /dev/null; then
    eval "$(direnv hook "$shell_type")"
fi
if command -v uv &> /dev/null; then
    eval "$(uv generate-shell-completion "$shell_type")"
    eval "$(uvx --generate-shell-completion "$shell_type")"
fi
if [ -f "$HOME/.config/op/plugins.sh" ]; then
    source "$HOME/.config/op/plugins.sh"
fi
if [ -f "$HOME/.atuin/bin/env" ]; then
    . "$HOME/.atuin/bin/env"
    eval "$(atuin init "$shell_type")"
fi

if command -v kubectl &> /dev/null; then
    source <(kubectl completion "$shell_type")
fi

if command -v docker &> /dev/null; then
    # zsh uses fpath for completions and more
    export fpath=("$HOME/.docker/completions" "${fpath[@]}")
fi
