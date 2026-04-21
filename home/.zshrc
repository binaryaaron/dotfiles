#!/usr/bin/env zsh

DOTFILES="${DOTFILES:-$HOME/dotfiles}"
. "$DOTFILES/shell/zsh_completions.sh"
. "$DOTFILES/shell/commonrc.sh"

# uv run completion: prefer .py files until one is present, then any file
_uv_run_mod() {
    if [[ "$words[2]" == "run" && "$words[CURRENT]" != -* ]]; then
        if [[ ${words[3,$((CURRENT-1))]} =~ ".*\.py" ]]; then
            _arguments '*:filename:_files'
        else
            _arguments '*:filename:_files -g "*.py"'
        fi
    else
        _uv "$@"
    fi
}
# compdef _uv_run_mod uv
