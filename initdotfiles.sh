#!/bin/bash
cd ~/dotfiles

git clone https://github.com/xysmas/dotfiles.git
ln -s ~/dotfiles/.gitconfig ~/.gitconfig 
ln -s ~/dotfiles/.bashrc ~/.bashrc 
ln -s ~/dotfiles/.bash_aliases ~/.bash_aliases 
ln -s ~/dotfiles/.bash_profile ~/.bash_profile 


