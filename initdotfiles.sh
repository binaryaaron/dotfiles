#!/usr/bin/env bash

REPO_URL="${REPO_URL:-"https://github.com/binaryaaron/dotfiles.git"}"
DOTFILES="${DOTFILES:-"$HOME/dotfiles"}"
export DOTFILES
shell_type=$(basename "$SHELL")
email="${EMAIL:-$1}"
name="${NAME:-${2:-}}"
signingkey="${SIGNINGKEY:-${3:-}}"

if [ -z "$email" ]; then
	echo "usage: $0 <email> [name] [signingkey]  or  EMAIL=you@example.com $0" >&2
	exit 1
fi

if [ ! -d "$DOTFILES" ]; then
	git clone "$REPO_URL" "$DOTFILES"
fi

. "$DOTFILES/shells/utils.sh"
. "$DOTFILES/shells/envvars.sh" || echo "failed to source envvars."
. "$DOTFILES/shells/xdg_home/init_xdg_stuff.sh" || echo "failed to source xdg_home"
. "$DOTFILES/shells/gitconfigs/init_gitconfig.sh" || echo "failed to source gitconfig"

init_xdg_home
setup_gitconfig "$email" "$name" "$signingkey" || echo "failed to setup gitconfig"

(command -v starship > /dev/null 2>&1 ||
	FORCE=1 curl -sS https://starship.rs/install.sh | sh
)
(command -v atuin > /dev/null 2>&1 ||
	curl --proto '=https' --tlsv1.2 -LsSf https://setup.atuin.sh | sh
)

echo "symlinking shell rc files"
_safe_symlink "$DOTFILES/shells/.bashrc"      "$HOME/.bashrc"
_safe_symlink "$DOTFILES/shells/.bash_profile" "$HOME/.bash_profile"
_safe_symlink "$DOTFILES/shells/.bashenv"      "$HOME/.bashenv"
_safe_symlink "$DOTFILES/shells/.zshrc"        "$HOME/.zshrc"
_safe_symlink "$DOTFILES/shells/.dircolors"    "$HOME/.dircolors"
