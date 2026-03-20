#!/usr/bin/env bash

[ -n "$_UTILS_SOURCED" ] && return; _UTILS_SOURCED=1

# Back up an existing file/symlink at dst and replace it with a symlink to src.
# Idempotent: no-ops if the symlink already points to src, unless FORCE=1.
# Any file or symlink not pointing into DOTFILES is backed up to dst.bak.
_safe_symlink() {
	local src="$1" dst="$2"
	local dotfiles="${DOTFILES:-$HOME/dotfiles}"
	if [ -L "$dst" ]; then
		local current; current="$(readlink "$dst")"
		if [ "$current" = "$src" ] && [ "${FORCE:-0}" != "1" ]; then
			echo "skipping $dst -- already linked to $src" >&2
			return 0
		fi
		case "$current" in
			"$dotfiles"*) ;;
			*)
				echo "backing up symlink $dst -> $current to ${dst}.bak"
				mv "$dst" "${dst}.bak" ;;
		esac
		[ -L "$dst" ] && rm "$dst" && echo "removed symlink $dst -> $current"
	elif [ -e "$dst" ]; then
		echo "backing up existing $dst to ${dst}.bak"
		mv "$dst" "${dst}.bak"
	fi
	ln -s "$src" "$dst"
	echo "linked $dst -> $src"
}
