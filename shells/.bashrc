#!/usr/bin/env bash
# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples
#
# # Guard against infinite recursion when BASH_ENV points here
# # if [ -n "$_BASHRC_SOURCED" ]; then return 0; fi
export _BASHRC_SOURCED=1

source_if_exists (){
	local filename=$1
	[[ -f  "$filename" ]] && . "$filename"
}


DOTFILES="${DOTFILES:-$HOME/dotfiles}"
export DOTFILES

# If not running interactively, don't do anything
if [ -z "$PS1" ]; then
	SHELLS_DIR="$DOTFILES/shells"
	source_if_exists "$SHELLS_DIR/commonrc.sh" 
	source_if_exists "$HOME/.local.bashrc" 
	source_if_exists "$HOME/bashrc_extras.sh" 
	# direnv hook relies on PROMPT_COMMAND which never fires in
	# non-interactive shells (Cursor, Claude Code). Export directly instead.
	if command -v direnv &>/dev/null; then
		eval "$(direnv export bash 2>/dev/null)"
	fi
	return 0
fi

# don't put duplicate lines in the history. See bash(1) for more options
# don't overwrite GNU Midnight Commander's setting of `ignorespace'.
HISTCONTROL=$HISTCONTROL${HISTCONTROL+,}ignoredups
# ... or force ignoredups and ignorespace
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

[[ -f ~/.bash-preexec.sh ]] && . ~/.bash-preexec.sh

SHELLS_DIR="$DOTFILES/shells"
. "$SHELLS_DIR/commonrc.sh"
. "$SHELLS_DIR/starship.sh"

if [ -f "$HOME/.local.bashrc" ]; then
    . $HOME/.local.bashrc
    add_kube_configs || echo "failed to add kube configs"
fi

if [ -f "$HOME/bashrc_extras.sh" ]; then
    . $HOME/bashrc_extras.sh
fi
