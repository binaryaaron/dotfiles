#!/usr/bin/env bash

email="$1"

if [ "$OS" == "Darwin" ]; then
    credential_helper="helper = osxkeychain"
elif [ "$OS" == "Linux" ]; then
    credential_helper="helper = cache --timeout 21600\nhelper = oauth -device"
fi

cat <<EOF > ".gitconfig"
[user]
	name = Aaron Gonzales
	email = "$email"
[filter "media"]
	clean = git-media-clean %f
	smudge = git-media-smudge %f
[credential]
	$credential_helper
[alias]
	co = checkout
	br = branch
	hist = log --pretty=format:'%h %ad | %s%d [%an]' --graph --date=short -25
	type = cat-file -t
	dump = cat-file -p
[color]
	ui = auto
[core]
	excludesfile = $HOME/dotfiles/gitconfigs/.gitignore_global
	pager = less
	autocrlf = input
[push]
	default = simple
	autoSetupRemote = true
[safe]
	directory = *
[filter "lfs"]
	clean = git-lfs clean -- %f
	smudge = git-lfs smudge -- %f
	process = git-lfs filter-process
	required = true
[http]
	postBuffer = 257286400
[pager]
	branch = false
EOF

ln -s "$(pwd)/.gitconfig" "$HOME/.gitconfig"
ln -s "$(pwd)/.gitignore_global" "$HOME/.gitignore_global"