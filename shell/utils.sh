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

show_large_folders() {
	local path="${1:-.}"
    local depth="${1:-2}"
    local min_gb="${2:-1}"
    local min_mb=$((min_gb * 1024))
    du -m --max-depth="$depth" "$path" | awk -v min="$min_mb" '$1 >= min { printf "%.1fG\t%s\n", $1/1024, $2 }' | sort -t$'\t' -k1 -rn
}


# True if branch is fully integrated into integration ref: merge-base ancestry
# (merge/FF) or squash-merge via cherry trick.
# $1: integration ref (e.g. origin/main)
# $2: branch ref (short name or refs/heads/...)
# See https://stackoverflow.com/a/56026209/1354930
_branch_merged_into() {
  local integration="$1" branch="$2"
  git rev-parse --verify "$integration^{commit}" >/dev/null 2>&1 || return 1
  if git merge-base --is-ancestor "$branch" "$integration" 2>/dev/null; then
    return 0
  fi
  local merge_base
  merge_base=$(git merge-base "$integration" "$branch") || return 1
  [[ $(git cherry "$integration" "$(git commit-tree "$(git rev-parse "$branch^{tree}")" -p "$merge_base" -m _)") == "-"* ]]
}

prune_squash_merged_branches() {
  # lightly modified from https://github.com/dougthor42/dotfiles/blob/main/git_prune_squash_merged.sh
  DRY_RUN=${DRY_RUN:-1}
  VERBOSE=${VERBOSE:-1}
  local INTEGRATION_REF="${INTEGRATION_REF:-origin/main}"

  echo "Pruning local branches merged into $INTEGRATION_REF..."
  if [[ $DRY_RUN -eq 1 ]]; then
      echo "DRY RUN - no branches will be deleted."
  fi

  if ! git rev-parse --verify "$INTEGRATION_REF^{commit}" >/dev/null 2>&1; then
      echo "Ref '$INTEGRATION_REF' not found (try: git fetch)."
      return 1
  fi

  git for-each-ref refs/heads/ "--format=%(refname:short)" |
      while read -r branch; do
          [[ "$branch" == "main" ]] && continue

          if [[ $VERBOSE -eq 2 ]]; then
              echo "Checking $branch ..."
          fi

          if ! _branch_merged_into "$INTEGRATION_REF" "$branch"; then
              continue
          fi

          # If we got down here then we already know that $branch is merged into
          # $INTEGRATION_REF. We still want to check if it's a dependency of other branches.

          # Is the branch included in any other branch?
          # `--contains` will always show itself, so remove that line.
          CONTAINS=$(git branch --contains "$branch" | sed -e "\:^[\* ] $branch$:d")

          if [[ -n $CONTAINS ]]; then
              if [[ $VERBOSE -eq 1 ]]; then
                  echo "$branch is a dependency of other branch(es). Not deleting"
                  echo "$CONTAINS"
              fi
              continue
          fi

          if [[ $DRY_RUN -eq 1 ]]; then
              echo "$branch is merged into $INTEGRATION_REF and can be deleted"
              continue
          fi

          if [[ $VERBOSE -eq 1 ]]; then
              echo "Deleting $branch (merged into $INTEGRATION_REF)"
          fi
          git branch -D "$branch"

      done

}


# Prune/remove linked worktrees for the repo containing the current directory only.
# Removes a worktree when: (1) HEAD matches @{upstream}, or (2) the branch is merged
# into INTEGRATION_REF (default origin/main), including squash merges via _branch_merged_into.
# Run git fetch so origin/main and upstream refs are current. git worktree list never
# mixes other repos.
prune_worktrees() {
  DRY_RUN="${DRY_RUN:-1}"
  VERBOSE="${VERBOSE:-1}"
  local INTEGRATION_REF="${INTEGRATION_REF:-origin/main}"

  git rev-parse --is-inside-work-tree >/dev/null 2>&1 || {
    echo "not inside a git work tree" >&2
    return 1
  }

  if ! git rev-parse --verify "$INTEGRATION_REF^{commit}" >/dev/null 2>&1; then
    echo "Ref '$INTEGRATION_REF' not found (try: git fetch)." >&2
    return 1
  fi

  local main_root
  # Primary checkout path (listed first; do not remove this one)
  main_root="$(git worktree list --porcelain | awk '/^worktree / { print $2; exit }')" || return 1
  [ -n "$main_root" ] || return 1

  while IFS=$'\t' read -r wt_path branch_info lock_reason; do
      [ "$wt_path" = "$main_root" ] && continue

      if [ "$branch_info" = "detached" ]; then
        [ "$VERBOSE" -ge 1 ] && printf 'skip: %s (detached HEAD)\n' "$wt_path" >&2
        continue
      fi

      local head up reason
      head="$(git -C "$wt_path" rev-parse HEAD 2>/dev/null)" || {
        [ "$VERBOSE" -ge 1 ] && printf 'skip: %s (cannot read HEAD)\n' "$wt_path" >&2
        continue
      }
      up="$(git -C "$wt_path" rev-parse '@{upstream}' 2>/dev/null)" || up=""
      reason=""
      if [ -n "$up" ] && [ "$head" = "$up" ]; then
        reason="synced with upstream"
      elif _branch_merged_into "$INTEGRATION_REF" "$branch_info"; then
        reason="merged into $INTEGRATION_REF"
      else
        [ "$VERBOSE" -ge 1 ] && printf 'skip: %s (not synced with upstream and not merged into %s)\n' \
          "$wt_path" "$INTEGRATION_REF" >&2
        continue
      fi

      if [ "$DRY_RUN" -eq 1 ]; then
        [ "$VERBOSE" -ge 1 ] && printf 'would remove: %s (%s) %s locked=%s\n' \
          "$wt_path" "$branch_info" "$reason" "${lock_reason:-no}"
        continue
      fi
      git worktree remove --force "$wt_path" 2>/dev/null || git worktree remove "$wt_path"
    done < <(git worktree list --porcelain | awk '
    /^worktree / { path=$2; branch=""; detached=0; locked="" }
    /^branch /   { branch=$2 }
    /^detached$/ { detached=1 }
    /^locked /   { locked=substr($0, 8) }
    /^$/ && path {
      b=(detached ? "detached" : branch)
      print path "\t" b "\t" locked
      path=""
    }
    END { if (path) { b=(detached ? "detached" : branch); print path "\t" b "\t" locked } }
  ')

  if [ "$DRY_RUN" -ne 1 ]; then
    git worktree prune -v
  else
    echo "DRY RUN - no worktrees will be deleted. rerun with DRY_RUN=0 to actually delete worktrees."
  fi
}
