#!/usr/bin/env zsh

DOTFILES="${DOTFILES:-$HOME/dotfiles}"
. "$DOTFILES/shells/zsh_completions.sh"
. "$DOTFILES/shells/commonrc.sh"

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

# machine-local extras (e.g. k8s ConfigMap, per-machine overrides)
[ -f /startup/bashrc_extras.sh ] && . /startup/bashrc_extras.sh
[ -f "$HOME/.local.zshrc" ] && . "$HOME/.local.zshrc"
command -v add_kube_configs > /dev/null 2>&1 && add_kube_configs
