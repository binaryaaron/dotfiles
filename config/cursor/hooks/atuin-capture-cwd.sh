#!/usr/bin/env bash
# beforeShellExecution hook: capture cwd so atuin-history.sh can associate
# the recorded command with the right directory. Cursor's afterShellExecution
# event doesn't include cwd, so we stash it here keyed by generation_id.
#
# Also logs a debug line to $ATUIN_CURSOR_LOG if set (helpful when debugging
# hook payload shape).

set -euo pipefail

input=$(cat)

if command -v jq >/dev/null 2>&1; then
    cwd=$(jq -r '.cwd // .workspace_roots[0] // empty' <<<"$input")
    generation_id=$(jq -r '.generation_id // "default"' <<<"$input")
else
    cwd=$(printf '%s' "$input" | grep -oE '"cwd"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed -E 's/.*"cwd"[[:space:]]*:[[:space:]]*"([^"]*)".*/\1/')
    if [ -z "$cwd" ]; then
        cwd=$(printf '%s' "$input" | grep -oE '"workspace_roots"[[:space:]]*:[[:space:]]*\[[[:space:]]*"[^"]*"' | head -1 | sed -E 's/.*"workspace_roots"[[:space:]]*:[[:space:]]*\[[[:space:]]*"([^"]*)".*/\1/')
    fi
    generation_id="default"
fi

[ -n "${cwd:-}" ] && [ "$cwd" != "null" ] && \
    printf '%s\n' "$cwd" > "/tmp/atuin-cursor-cwd-${generation_id}"

if [ -n "${ATUIN_CURSOR_LOG:-}" ]; then
    printf '[%s] pre  gen=%s cwd=%s\n' "$(date -u +%FT%TZ)" "${generation_id}" "${cwd:-<none>}" \
        >> "$ATUIN_CURSOR_LOG"
fi

exit 0
