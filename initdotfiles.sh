#!/bin/bash

shell_type=$(basename $SHELL)


if ! command -v starship &> /dev/null; then
	curl -sS https://starship.rs/install.sh | sh
fi
if command -v atuin &> /dev/null; then
	curl --proto '=https' --tlsv1.2 -LsSf https://setup.atuin.sh | sh
fi


if [ -d "$HOME/dotfiles" ]; then
	echo 'making symlinks'
	if [ ! -f "$HOME/.${shell_type}rc" ]; then
		echo "backing up ~/.${shell_type}rc"
		mv "$HOME/.${shell_type}rc" "$HOME/.${shell_type}rc.bak"
	fi
	ln -s "$(pwd)/shells/.{$shell_type}rc" "$HOME/.{$shell_type}rc"
	ln -s "$(pwd)/gitconfigs/gitconfig" "$HOME/.gitconfig" 
	ln -s "$(pwd)/gitconfigs/gitignore_global" "$HOME/.gitignore_global" 
fi
