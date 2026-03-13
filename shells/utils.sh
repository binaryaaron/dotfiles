#!/usr/bin/env bash

[ -n "$_UTILS_SOURCED" ] && return; _UTILS_SOURCED=1

# Back up an existing file/symlink at dst and replace it with a symlink to src.
# Idempotent: no-ops if the symlink already points to src.
_safe_symlink() {
	local src="$1" dst="$2"
	if [ -L "$dst" ]; then
		if [ "$(readlink "$dst")" = "$src" ]; then
			return 0
		fi
		echo "removing stale symlink $dst -> $(readlink "$dst")"
		rm "$dst"
	elif [ -e "$dst" ]; then
		echo "backing up existing $dst to ${dst}.bak"
		mv "$dst" "${dst}.bak"
	fi
	ln -s "$src" "$dst"
	echo "linked $dst -> $src"
}
