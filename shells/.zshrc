#!/usr/bin/env zsh

shells_dir="$(git rev-parse --show-toplevel)/shells"
source "$shells_dir/commonrc.sh"


# you will need to add the lines below
# https://github.com/astral-sh/uv/issues/8432#issuecomment-2453494736
_uv_run_mod() {
    if [[ "$words[2]" == "run" && "$words[CURRENT]" != -* ]]; then
        # Check if any previous argument after 'run' ends with .py
        if [[ ${words[3,$((CURRENT-1))]} =~ ".*\.py" ]]; then
            # Already have a .py file, complete any files
            _arguments '*:filename:_files'
        else
            # No .py file yet, complete only .py files
            _arguments '*:filename:_files -g "*.py"'
        fi
    else
        _uv "$@"
    fi
}
compdef _uv_run_mod uv

source "./starship.sh"
source $HOME/.local.zshrc