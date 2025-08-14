#!/usr/bin/env bash
# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# don't put duplicate lines in the history. See bash(1) for more options
# don't overwrite GNU Midnight Commander's setting of `ignorespace'.
HISTCONTROL=$HISTCONTROL${HISTCONTROL+,}ignoredups
# ... or force ignoredups and ignorespace
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

shells_dir="$(git rev-parse --show-toplevel)/shells"
source "$shells_dir/commonrc.sh"
source "$shells_dir/starship.sh"

if [ -f "$HOME/.local.bashrc" ]; then
    source $HOME/.local.bashrc
    add_kube_configs
fi