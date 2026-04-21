#!/usr/bin/env zsh
# ~/.zprofile: executed by zsh(1) for login shells, before .zshrc.
#
# mise's recommended layout (https://mise.jdx.dev/installing-mise.html):
#   - PATH + XDG setup for every login shell, interactive or not, so
#     non-interactive logins (ssh-with-command, launchd, GUI launchers that
#     inherit a login environment) still resolve mise-managed tools.
#   - `mise activate zsh` runs in .zshrc for interactive shells, where the
#     function-based hook can instrument chpwd and env loading.
#
# PATH construction lives in shell/envvars.sh -- the single source of truth
# used by both login and interactive entrypoints. See that file for ordering.
. "${DOTFILES:-$HOME/dotfiles}/shell/envvars.sh"
