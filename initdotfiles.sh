#!/bin/bash

REPO_URL="${REPO_URL:-"https://github.com/binaryaaron/dotfiles.git"}"
DOTFILES="${DOTFILES:-"$HOME/dotfiles"}"
export DOTFILES
shell_type=$(basename $SHELL)
email="${1:-aaron@aarongonzales.net}"


if [ ! -d "$DOTFILES" ]; then
	git clone "$REPO_URL" "$DOTFILES"
fi	

. "$DOTFILES/shells/envvars.sh" || echo "failed to source envvars"
. "$DOTFILES/shells/xdg_home/init_xdg_stuff.sh" || echo "failed to source xdg_home"
. "$DOTFILES/shells/gitconfigs/init_gitconfig.sh" || echo "failed to source gitconfig"

init_xdg_home
setup_gitconfig "$email" || echo "failed to setup gitconfig"

(command -v starship &> /dev/null ||
	export FORCE=1 && curl -sS https://starship.rs/install.sh | sh
)
(command -v atuin &> /dev/null ||
	curl --proto '=https' --tlsv1.2 -LsSf https://setup.atuin.sh | sh && \
	$HOME/.atuin/bin/atuin init "$shell_type"
)



echo 'making symlinks'
if [ -f "$HOME/.${shell_type}rc" ]; then
	echo "backing up ~/.${shell_type}rc"
	mv "$HOME/.${shell_type}rc" "$HOME/.${shell_type}rc.bak"
fi
ln -s "$DOTFILES/shells/.${shell_type}rc" "$HOME/.${shell_type}rc"