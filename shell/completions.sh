
_shell="$(basename "$SHELL")"

# Eval a tool's shell integration if the tool is available.
_eval_if_found() {
    local cmd="$1"; shift
    command -v "$cmd" > /dev/null 2>&1 && eval "$("$cmd" "$@")"
}

# bash-completion framework (Linux: apt, macOS: homebrew)
if [ "$_shell" = "bash" ]; then
    for _f in \
        /usr/share/bash-completion/bash_completion \
        /usr/local/etc/profile.d/bash_completion.sh \
        /opt/homebrew/etc/profile.d/bash_completion.sh
    do
        [ -f "$_f" ] && { . "$_f"; break; }
    done
    unset _f
fi

# mise must come before direnv so direnv can reference mise-managed tools
_eval_if_found mise activate "$_shell"
_eval_if_found direnv hook "$_shell"
_eval_if_found uv generate-shell-completion "$_shell"
_eval_if_found kubectl completion "$_shell"

[ -f "$HOME/.config/op/plugins.sh" ] && . "$HOME/.config/op/plugins.sh"

# bash-preexec must be sourced before atuin init (bash only -- zsh has native hooks)
[ "$_shell" = "bash" ] && [ -f "$HOME/.bash-preexec.sh" ] && . "$HOME/.bash-preexec.sh"

if [ -f "$HOME/.atuin/bin/env" ]; then
    . "$HOME/.atuin/bin/env"
    eval "$(atuin init "$_shell")"
fi

if command -v docker > /dev/null 2>&1; then
    if [ "$_shell" = "zsh" ]; then
        fpath=("$HOME/.docker/completions" $fpath)
    else
        fpath="$HOME/.docker/completions${fpath:+:$fpath}"
        export fpath
    fi
fi
