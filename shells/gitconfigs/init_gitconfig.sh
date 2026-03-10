#!/usr/bin/env bash


setup_gitconfig() {
	email="${1:-aaron@aarongonzales.net}"

if [ "$OS" == "Darwin" ]; then
    credential_helper="helper = osxkeychain"
elif [ "$OS" == "Linux" ]; then
    credential_helper="helper = cache --timeout 21600\nhelper = oauth -device"
fi

cat <<EOF > "$DOTFILES/shells/gitconfigs/.gitconfig"
[user]
	name = Aaron Gonzales
	email = "$email"
	signingkey = /root/.ssh/id_ed25519.pub
[filter "media"]
	clean = git-media-clean %f
	smudge = git-media-smudge %f
[credential]
	${credential_helper}
[alias]
	slog = log --pretty=format:'%C(auto)%h %C(red)%as %C(blue)%aN%C(auto)%d%C(green) %s'
	l = slog
	l5 = l -5
	ls = slog --decorate -25
	ll = slog --decorate --numstat -100
	la = "!git config -l | grep alias | cut -c 7-"
	type = cat-file -t
	dump = cat-file -p
	brs = "!{ printf 'BRANCH\\tDATE\\t+/-\\tMESSAGE\\n'; git for-each-ref --sort=-creatordate --format='%(refname:short)\t%(creatordate:relative)\t%(ahead-behind:HEAD)\t%(contents:subject)' refs/heads; } | awk -F'\\t' '{ printf \"%-40s  %-18s  %-10s  %-.*s\\n\", $1, $2, $3, 50, $4 }'"
	brsa = "!{ printf 'BRANCH\\tDATE\\t+/-\\tMESSAGE\\n'; git for-each-ref --sort=-creatordate --format='%(refname:short)\t%(creatordate:relative)\t%(ahead-behind:HEAD)\t%(contents:subject)' refs/heads refs/remotes; } | awk -F'\\t' '{ printf \"%-40s  %-18s  %-10s  %s\\n\", $1, $2, $3, $4 }'"
	stag = tag -l --sort=v:refname
	structure = log --oneline --simplify-by-decoration --graph --all
	
	wdiff = diff --color-words='[^[:space:]]|([[:alnum:]]|UTF_8_GUARD)+'

	co = checkout
	br = branch

	# what would be merged
	incoming = log HEAD..@{upstream}
	# what would be pushed
	outgoing = log @{upstream}..HEAD

	prune-local = !git branch -vv | awk '/: gone]/{print $1}' | xargs git branch -D
	unstaged-tracked = !status --short | grep '^ .' | awk '{print $1}'
	rebase-latest-main = "!git fetch && git rebase -i origin/main"
	restore-staged = restore --staged .
	restore-all = "!git restore --staged . && git restore ."
	add-signoffs = rebase main --signoff
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
[credential "https://github.com"]
	helper = !/root/.local/bin/gh auth git-credential
[rerere]
	enabled = true
[gpg]
	format = ssh
[commit]
	gpgsign = true
[gpg "ssh"]
	allowedSignersFile = /root/.ssh/allowed_signers
[pull]
	rebase = true

EOF

ln -s "$DOTFILES/shells/gitconfigs/.gitconfig" "$HOME/.gitconfig"
ln -s "$DOTFILES/shells/gitconfigs/.gitignore_global" "$HOME/.gitignore_global"
}
