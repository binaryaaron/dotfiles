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
# Cursor dump_bash_state dumps Bash functions but only exported vars. mise()'s
# body references $__MISE_EXE, which `mise activate bash` leaves unexported.
# Without this, replayed Cursor Bash shells can fork-storm through
# command_not_found_handle. Keep this Bash-only; zsh does not need it.
if [ -n "${BASH_VERSION:-}" ]; then
    [ -n "${__MISE_EXE+x}" ] && export __MISE_EXE
    [ -n "${__MISE_FLAGS+x}" ] && export __MISE_FLAGS
    [ -n "${__MISE_HOOK_ENABLED+x}" ] && export __MISE_HOOK_ENABLED
    [ -n "${__MISE_BASH_CHPWD_RAN+x}" ] && export __MISE_BASH_CHPWD_RAN
fi

_eval_if_found uv generate-shell-completion "$_shell"
_eval_if_found kubectl completion "$_shell"

[ -f "$HOME/.config/op/plugins.sh" ] && . "$HOME/.config/op/plugins.sh"

# Atuin prefers ble.sh on Bash; bash-preexec remains the fallback backend.
# ble.sh's documented setup loads early with --attach=none and attaches late:
# https://github.com/akinomyoga/ble.sh#13-set-up-bashrc
if [ "$_shell" = "bash" ]; then
    if [ -r "$HOME/.local/share/blesh/ble.sh" ] && [ -t 0 ] && [ -t 1 ] && [ -t 2 ]; then
        source -- "$HOME/.local/share/blesh/ble.sh" --attach=none
    elif [ -f "$HOME/.bash-preexec.sh" ]; then
        . "$HOME/.bash-preexec.sh"
    fi
fi

# Atuin's Bash integration requires an interactive preexec backend during init:
# https://docs.atuin.sh/cli/guide/shell-integration/#bash
# If a parent shell left atuin half-initialized, clear the guard so this shell
# can register its preexec callbacks again.
if [ "$_shell" = "bash" ] && [[ ${__atuin_initialized-} == true ]] && \
   [[ " ${preexec_functions[*]-} " != *" __atuin_preexec "* ]]; then
    unset __atuin_initialized
fi

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
