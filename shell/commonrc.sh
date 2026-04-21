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
safe_source "$DOTFILES/shell/local_extras.sh"

unset -f safe_source

set -o vi
