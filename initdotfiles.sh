#!/bin/bash
if [ -d "$HOME/dotfiles" ]; then
	echo 'making symlinks'
	ln -s ~/dotfiles/.gitconfig ~/.gitconfig 
	ln -s ~/dotfiles/.gitignore_global ~/.gitignore_global 
	ln -s ~/dotfiles/.bashrc ~/.bashrc 
	ln -s ~/dotfiles/.bash_aliases ~/.bash_aliases 
	ln -s ~/dotfiles/.bash_profile ~/.bash_profile 
	ln -s ~/dotfiles/.dircolors ~/.dircolors
fi
	
