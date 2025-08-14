shell_type=$(basename $SHELL)
if command -v starship &> /dev/null; then
    eval "$(starship init "$shell_type")"
fi
