#!/bin/bash
echo initializing dotfiles 
if [ ! -d "$HOME/dotfiles/" ]; then
	cd $HOME
	git clone https://github.com/xysmas/dotfiles.git
fi

if [ -d "$HOME/dotfiles" ]; then
	ln -s ~/dotfiles/.gitconfig ~/.gitconfig 
	ln -s ~/dotfiles/.bashrc ~/.bashrc 
	ln -s ~/dotfiles/.bash_aliases ~/.bash_aliases 
	ln -s ~/dotfiles/.bash_profile ~/.bash_profile 
fi
