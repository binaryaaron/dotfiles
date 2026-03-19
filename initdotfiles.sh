#!/usr/bin/env bash
# Bootstrap dotfiles from scratch.
#
# Usage:
#   wget -qO- https://raw.githubusercontent.com/binaryaaron/dotfiles/main/initdotfiles.sh | bash -s -- you@example.com "Your Name"
#   curl -fsSL https://raw.githubusercontent.com/binaryaaron/dotfiles/main/initdotfiles.sh | bash -s -- you@example.com "Your Name"
set -euo pipefail

REPO_URL="${REPO_URL:-https://github.com/binaryaaron/dotfiles.git}"
DOTFILES="${DOTFILES:-$HOME/dotfiles}"
EMAIL="${1:?usage: initdotfiles.sh <email> [name] [signingkey]}"
NAME="${2:-}"
SIGNINGKEY="${3:-}"

if [ ! -d "$DOTFILES" ]; then
    git clone "$REPO_URL" "$DOTFILES"
fi

make -C "$DOTFILES" install EMAIL="$EMAIL" NAME="$NAME" SIGNINGKEY="$SIGNINGKEY"
