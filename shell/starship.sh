# shellcheck shell=bash
if command -v starship >/dev/null 2>&1; then
    _shell_type=${SHELL##*/}
    eval "$(starship init "$_shell_type")"
    unset _shell_type
fi
