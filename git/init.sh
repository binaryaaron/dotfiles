#!/usr/bin/env bash

. "$DOTFILES/shell/utils.sh"

# Shared, portable git settings that belong in the dotfiles repo.
# Does NOT contain user identity (name/email) or machine-specific credential
# helpers — those stay in ~/.gitconfig on each machine.
#
# Strategy: ~/.gitconfig on each machine includes this file via [include],
# so local settings always take precedence (git applies includes before
# evaluating later sections in the including file).
_write_shared_gitconfig() {
	local gitconfig_dest="$1"
	local gitignore_dest="$DOTFILES/git/ignore"

	mkdir -p "$(dirname "$gitconfig_dest")"

	cat <<'EOF' > "$gitconfig_dest"
[alias]
	slog = log --pretty=format:'%C(auto)%h%Creset | %C(red)%as%Creset | %C(auto)%d%Creset | %C(green)%s%Creset | %C(blue)%aN%Creset' --graph
	l = slog
	l5 = l -5
	ls = slog --decorate -25
	ll = slog --decorate --numstat -100
	la = "!git config -l | grep alias | cut -c 7-"
	type = cat-file -t
	dump = cat-file -p
	brs = "!{ printf 'BRANCH\tDATE\t+/-\tMESSAGE\n'; git for-each-ref --sort=-creatordate --format='%(refname:short)\t%(creatordate:relative)\t%(ahead-behind:HEAD)\t%(contents:subject)' refs/heads; } | awk -F'\t' '{ printf \"%-40s  %-18s  %-10s  %-.*s\\n\", $1, $2, $3, 50, $4 }'"
	brsa = "!{ printf 'BRANCH\tDATE\t+/-\tMESSAGE\n'; git for-each-ref --sort=-creatordate --format='%(refname:short)\t%(creatordate:relative)\t%(ahead-behind:HEAD)\t%(contents:subject)' refs/heads refs/remotes; } | awk -F'\t' '{ printf \"%-40s  %-18s  %-10s  %s\\n\", $1, $2, $3, $4 }'"
	stag = tag -l --sort=v:refname
	structure = log --oneline --simplify-by-decoration --graph --all
	wdiff = diff --color-words='[^[:space:]]|([[:alnum:]]|UTF_8_GUARD)+'
	co = checkout
	br = branch
	incoming = log HEAD..@{upstream}
	outgoing = log @{upstream}..HEAD
	prune-local = !git branch -vv | awk '/: gone]/{print $1}' | xargs git branch -D
	unstaged-tracked = !status --short | grep '^ .' | awk '{print $1}'
	rebase-latest-main = "!git fetch && git rebase -i origin/main"
	restore-staged = restore --staged .
	restore-all = "!git restore --staged . && git restore ."
	add-signoffs = rebase main --signoff
	branch-point = "!git merge-base ${1:-main} HEAD"
[color]
	ui = auto
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
[filter "media"]
	clean = git-media-clean %f
	smudge = git-media-smudge %f
[http]
	postBuffer = 257286400
[pager]
	branch = false
[rerere]
	enabled = true
[pull]
	rebase = true
[commit]
	gpgsign = true
[gpg]
	format = ssh

EOF

	# Append paths that expand at write-time (contain $HOME / $DOTFILES)
	cat <<EOF >> "$gitconfig_dest"
[gpg "ssh"]
	allowedSignersFile = $HOME/.ssh/allowed_signers

[credential "https://github.com"]
	helper = !$(which gh) auth git-credential

[core]
	excludesfile = $gitignore_dest
	pager = less
	autocrlf = input

EOF
}

# Ensure ~/.gitconfig exists with a minimal local identity stub, then inject
# an [include] pointing at the shared dotfiles config if not already present.
# Local sections in ~/.gitconfig always win because git evaluates [include]
# at the point it appears; sections defined *after* the include override it.
#
# Args: EMAIL (required), NAME (optional), SIGNINGKEY (optional path to pub key)
# EMAIL is required. NAME defaults to the local part of the email.
# SIGNINGKEY defaults to the first found of id_ed25519, id_ecdsa, id_rsa;
# fails if none found and no override provided.
setup_gitconfig() {
	local email="$1"
	local name="${2:-${email%%@*}}"
	local signingkey="${3:-}"
	local gitconfig_dest="$DOTFILES/git/generated_config"
	local gitignore_dest="$DOTFILES/git/ignore"

	if [ -z "$email" ]; then
		echo "setup_gitconfig: EMAIL is required" >&2
		return 1
	fi

	if [ -z "$signingkey" ]; then
		signingkey=$(_find_ssh_signing_key) || return 1
	fi

	_write_shared_gitconfig "$gitconfig_dest"
	_safe_symlink "$gitignore_dest" "$HOME/.gitignore_global"

	# Bootstrap ~/.gitconfig if it doesn't exist yet
	if [ ! -e "$HOME/.gitconfig" ]; then
		_bootstrap_local_gitconfig "$email" "$name" "$signingkey"
	fi

	# Inject [include] into ~/.gitconfig if not already there
	if ! grep -qF "path = $gitconfig_dest" "$HOME/.gitconfig" 2>/dev/null; then
		# Prepend so local sections defined below the include take precedence
		local tmp
		tmp=$(mktemp)
		printf '[include]\n\tpath = %s\n\n' "$gitconfig_dest" | cat - "$HOME/.gitconfig" > "$tmp"
		mv "$tmp" "$HOME/.gitconfig"
		echo "injected [include] path = $gitconfig_dest into $HOME/.gitconfig"
	else
		echo "[include] already present in $HOME/.gitconfig, nothing to do"
	fi
}

# Find the first available SSH public key suitable for commit signing.
_find_ssh_signing_key() {
	local key
	for key in id_ed25519 id_ecdsa id_rsa; do
		if [ -f "$HOME/.ssh/${key}.pub" ]; then
			echo "$HOME/.ssh/${key}.pub"
			return 0
		fi
	done
	echo "no SSH public key found in ~/.ssh (tried id_ed25519, id_ecdsa, id_rsa); pass SIGNINGKEY=path to override" >&2
	return 1
}

# Write a minimal local ~/.gitconfig with identity and OS credential helper.
# Only called when no ~/.gitconfig exists at all (fresh machine).
_bootstrap_local_gitconfig() {
	local email="$1"
	local name="$2"
	local signingkey="$3"

	local credential_section
	local os_type
	os_type="$(uname -s)"
	if [ "$os_type" = "Darwin" ]; then
		credential_section="[credential]\n\thelper = osxkeychain"
	elif [ "$os_type" = "Linux" ]; then
		credential_section="[credential]\n\thelper = cache --timeout 21600\n\thelper = oauth -device"
	fi

	cat <<EOF > "$HOME/.gitconfig"
[user]
	name = $name
	email = $email
	signingkey = $signingkey
EOF
	[ -n "$credential_section" ] && printf "$credential_section\n" >> "$HOME/.gitconfig"
	echo "created minimal $HOME/.gitconfig"
}