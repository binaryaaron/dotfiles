#!/usr/bin/env bash
# ~/.bashrc: executed by bash(1) for non-login shells.

# If not running interactively, don't do anything.
case $- in
    *i*) ;;
      *) return;;
esac

DOTFILES="${DOTFILES:-$HOME/dotfiles}"
. "$DOTFILES/shell/commonrc.sh"


# nmptool dev-machine hook -- installed by NMP on managed pods; absent elsewhere.
# The [ -r ] guard is required; do NOT assume this file provides any
# defensive cleanup (e.g. unsetting stale mise functions). That protection
# lives in shell/commonrc.sh and must stand on its own.
[ -r /opt/devmachine_assets/bashrc-managed.sh ] && . /opt/devmachine_assets/bashrc-managed.sh
