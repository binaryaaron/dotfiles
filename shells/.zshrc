#!/usr/bin/env zsh

DOTFILES="$HOME/dotfiles"
SHELLS_DIR="$DOTFILES/shells"
# export fpath=(/opt/homebrew/share/zsh/site-functions /usr/local/share/zsh/site-functions /usr/share/zsh/site-functions /usr/share/zsh/5.9/functions $fpath)
# _comp_options+=(globdots) # With hidden files
source "$SHELLS_DIR/zsh_completions.sh"
# autoload -Uz compinit && compinit -u
source "$SHELLS_DIR/commonrc.sh"


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
# compdef _uv_run_mod uv

source "$SHELLS_DIR/starship.sh"

if [ -f "$HOME/.local.zshrc" ]; then
    source $HOME/.local.zshrc
    add_kube_configs
fi