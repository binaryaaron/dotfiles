# shellcheck shell=bash
# Single source of truth for PATH, XDG, and shell-agnostic env vars.
#
# Sourced from:
#   - home/.bash_profile and home/.zprofile (login shells, including
#     non-interactive ones like ssh-with-command, cron, launchd)
#   - shell/commonrc.sh (interactive bash/zsh via .bashrc / .zshrc)
#
# Idempotent via _ENVVARS_SOURCED (unexported so child shells re-evaluate)
# and via per-entry presence checks on PATH.
[ -n "$_ENVVARS_SOURCED" ] && return; _ENVVARS_SOURCED=1

# --- XDG base dirs + misc ---
export XDG_HOME="${XDG_HOME:-$HOME}"
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$XDG_HOME/.config}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$XDG_HOME/.local/share}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$XDG_HOME/.cache}"
export XDG_BIN_HOME="${XDG_BIN_HOME:-$XDG_HOME/.local/bin}"
export EDITOR="${EDITOR:-vim}"
export HISTSIZE=100000

if [ -z "${USER:-}" ]; then
    USER="$(id -un 2>/dev/null || printf '%s' "${LOGNAME:-}")"
fi
[ -n "${USER:-}" ] && export USER
export LOGNAME="${LOGNAME:-$USER}"

# Keep locale handling conservative: preserve host settings when they work, but
# repair empty/broken values common in minimal containers and embedded shells.
_dotfiles_locale_works() {
    [ -n "$1" ] || return 1
    command -v locale >/dev/null 2>&1 || return 0
    case "$(LC_ALL="$1" locale charmap 2>/dev/null)" in
        UTF-8|utf8|UTF8) return 0 ;;
        *) return 1 ;;
    esac
}

if ! _dotfiles_locale_works "${LANG:-}"; then
    LANG=C.UTF-8
fi
export LANG

if [ -n "${LC_ALL:-}" ] && ! _dotfiles_locale_works "$LC_ALL"; then
    unset LC_ALL
fi

if [ -n "${LC_CTYPE:-}" ] && ! _dotfiles_locale_works "$LC_CTYPE"; then
    unset LC_CTYPE
fi

unset -f _dotfiles_locale_works

# --- PATH (single place to change order) ---
#
# Precedence (front -> back):
#   ~/.local/share/mise/shims  mise-managed dev tools (beats everything)
#   ~/.local/bin               user installs (pipx, cargo, ~/.local builds)
#   ~/bin                      legacy per-user scripts (only if it exists)
#   <inherited PATH>           whatever login gave us
#   /usr/local/bin             appended if missing (brew on mac, manual builds)
#
# Idempotent: every entry is checked with ":$PATH:" substring match before
# modifying. Safe to re-source from any entrypoint in any order.
_dotfiles_prepend_path() {
    case ":$PATH:" in
        *:"$1":*) ;;
        *) PATH="$1:$PATH" ;;
    esac
}
_dotfiles_append_path() {
    case ":$PATH:" in
        *:"$1":*) ;;
        *) PATH="$PATH:$1" ;;
    esac
}

_dotfiles_append_path "/usr/local/bin"
[ -d "$HOME/bin" ] && _dotfiles_prepend_path "$HOME/bin"
_dotfiles_prepend_path "$HOME/.local/bin"
_dotfiles_prepend_path "$HOME/.local/share/mise/shims"
export PATH
unset -f _dotfiles_prepend_path _dotfiles_append_path

[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"
