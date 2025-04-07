#!/bin/bash

mkdir -p "$HOME/dotfiles"
cd "$HOME/dotfiles"
bash install_packages.sh

if [ -d "$HOME/dotfiles" ]; then
	echo 'making symlinks'
	sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
	gh repo clone romkatv/powerlevel10k $ZSH_CUSTOM/themes/powerlevel10k

	ln -s ~/dotfiles/.gitconfig ~/.gitconfig 
	ln -s ~/dotfiles/.gitignore_global ~/.gitignore_global 
	ln -s ~/dotfiles/.zshenv ~/.zshenv
 	# ln -s ~/dotfiles/.zshrc ~/.zshrc
  	# ln -s ~/dotfiles/.zshprofile ~/.zshprofile
fi


