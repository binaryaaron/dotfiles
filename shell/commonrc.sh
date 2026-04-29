# shellcheck shell=bash
DOTFILES="${DOTFILES:-$HOME/dotfiles}"

# Defense against stale Cursor-wrapper snapshots: if mise() and
# command_not_found_handle were inherited as functions from a dumped bash state
# but their backing $__MISE_EXE is gone, drop them before `mise activate`
# reinstalls fresh ones. Without this, the first unknown command recurses
# through cnfh -> mise() -> `command ""` -> cnfh and fork-storms.
if [ -z "${__MISE_EXE:-}" ] && declare -F mise >/dev/null 2>&1; then
    unset -f mise command_not_found_handle 2>/dev/null || true
fi

safe_source() {
    local file="$1"
    if [ -f "$file" ]; then
        . "$file"
    fi
}

safe_source "$DOTFILES/shell/envvars.sh"
safe_source "$DOTFILES/shell/init_xdg.sh"
safe_source "$DOTFILES/shell/aliases.sh"
safe_source "$DOTFILES/shell/bazel_aliases.sh"
safe_source "$DOTFILES/shell/completions.sh"
safe_source "$DOTFILES/shell/starship.sh"

_dotfiles_repair_atuin_bash_hooks() {
    [ -n "${BASH_VERSION:-}" ] || return 0
    [[ $- == *i* ]] || return 0
    command -v atuin >/dev/null 2>&1 || return 0

    # Atuin verifies that its preexec hook is live via `atuin doctor`.
    # See: https://docs.atuin.sh/cli/guide/shell-integration/
    if [[ ${__atuin_initialized-} == true ]] && {
        [[ " ${preexec_functions[*]-} " != *" __atuin_preexec "* ]] ||
        [[ " ${precmd_functions[*]-} " != *" __atuin_precmd "* ]]
    }; then
        unset __atuin_initialized
        eval "$(atuin init bash)"
    fi

    if declare -F __atuin_preexec >/dev/null &&
       [[ " ${preexec_functions[*]-} " != *" __atuin_preexec "* ]]; then
        preexec_functions+=(__atuin_preexec)
    fi

    if declare -F __atuin_precmd >/dev/null &&
       [[ " ${precmd_functions[*]-} " != *" __atuin_precmd "* ]]; then
        precmd_functions+=(__atuin_precmd)
    fi
}

_dotfiles_repair_atuin_bash_hooks
unset -f _dotfiles_repair_atuin_bash_hooks

safe_source "$DOTFILES/shell/local_extras.sh"

unset -f safe_source

set -o vi

_dotfiles_attach_blesh() {
    [ -n "${BLE_VERSION:-}" ] || return 0
    [ -z "${BLE_ATTACHED:-}" ] || return 0
    declare -F ble-attach >/dev/null || return 0

    # ble.sh recommends attaching after the rest of bashrc has configured the
    # prompt, keymap, aliases, and hooks.
    ble-attach
}

_dotfiles_attach_blesh
unset -f _dotfiles_attach_blesh
