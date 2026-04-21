#!/usr/bin/env bash
# ~/.bash_profile: executed by bash(1) for login shells.
#
# mise's recommended layout (https://mise.jdx.dev/installing-mise.html):
#   - PATH + XDG setup for every login shell, interactive or not, so
#     non-interactive logins (ssh-with-command, cron, launchd, GUI launchers
#     that inherit a login environment) still resolve mise-managed tools.
#   - Full `mise activate` hook setup only in ~/.bashrc, where interactive
#     shells get PATH manipulation on cd plus auto-install.
#
# PATH construction lives in shell/envvars.sh -- the single source of truth
# used by both login and interactive entrypoints. See that file for ordering.
. "${DOTFILES:-$HOME/dotfiles}/shell/envvars.sh"

# Interactive only below this line: source .bashrc so login and non-login
# interactive shells get identical config.
[[ $- == *i* ]] || return

[ -f "$HOME/.bashrc" ] && . "$HOME/.bashrc"
