#!/usr/bin/env bash
# ~/.bashrc: executed by bash(1) for non-login shells.

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

DOTFILES="${DOTFILES:-$HOME/dotfiles}"
. "$DOTFILES/shell/commonrc.sh"

# machine-local extras (e.g. k8s ConfigMap, per-machine overrides)
[ -f /startup/bashrc_extras.sh ] && . /startup/bashrc_extras.sh
[ -f "$HOME/.local.bashrc" ] && . "$HOME/.local.bashrc"
[[ -f ~/.bash-preexec.sh ]] && source ~/.bash-preexec.sh

[[ -f ~/.bash-preexec.sh ]] && source ~/.bash-preexec.sh
. "$HOME/.atuin/bin/env"

[[ -f ~/.bash-preexec.sh ]] && source ~/.bash-preexec.sh
eval "$(atuin init bash)"
