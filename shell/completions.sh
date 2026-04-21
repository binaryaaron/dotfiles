#shellcheck shell=bash

# If not running interactively, don't do anything.
case $- in
    *i*) ;;
      *) return;;
esac

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

# mise: activate shell hooks (PATH, env, auto-install). Replaces direnv --
# mise supports the same auto-load-per-directory pattern via [env] in mise.toml
# (including .env files), with the added benefit of managing tool versions.
_eval_if_found mise activate "$_shell"
# Cursor dump_bash_state dumps shell functions but only exported vars.
# mise()'s body references $__MISE_EXE, which `mise activate` leaves unexported.
# Without this, replayed Cursor shells fork-storm through command_not_found_handle.
for _v in __MISE_EXE __MISE_FLAGS __MISE_HOOK_ENABLED __MISE_BASH_CHPWD_RAN; do
    [ -n "${!_v+x}" ] && export "$_v"
done
unset _v

_eval_if_found uv generate-shell-completion "$_shell"
_eval_if_found kubectl completion "$_shell"

[ -f "$HOME/.config/op/plugins.sh" ] && . "$HOME/.config/op/plugins.sh"

# bash-preexec must be sourced before atuin init (bash only -- zsh has native hooks)
[ "$_shell" = "bash" ] && [ -f "$HOME/.bash-preexec.sh" ] && . "$HOME/.bash-preexec.sh"

_eval_if_found atuin init "$_shell"

# Docker shell completions live in $HOME/.docker/completions. Only zsh
# consumes $fpath; the directory is harmless if it doesn't exist yet.
if [ "$_shell" = "zsh" ] && command -v docker > /dev/null 2>&1; then
    fpath=("$HOME/.docker/completions" $fpath)
    export fpath
fi

# node is managed by mise (see config/mise/config.toml); nvm has been removed
# to avoid two version managers racing over PATH. If you need nvm for a
# specific project, source it from ~/.local.bashrc / ~/.local.zshrc instead.
