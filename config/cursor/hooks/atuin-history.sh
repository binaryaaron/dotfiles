#!/usr/bin/env bash
# afterShellExecution hook: record the command that Cursor just ran into atuin,
# tagged with author "cursor-agent" so it can be filtered from personal history.
#
# Cursor's afterShellExecution payload contains: command, output, duration (ms),
# sandbox. It does NOT expose exit code -- see
# https://cursor.com/docs/agent/hooks#aftershellexecution -- so we record with
# --exit 0. Duration is passed through faithfully.
#
# Pairing back to cwd uses generation_id, set by atuin-capture-cwd.sh in a
# /tmp sidecar file.

set -euo pipefail

input=$(cat)

if command -v jq >/dev/null 2>&1; then
    command_str=$(jq -r '.command // empty' <<<"$input")
    generation_id=$(jq -r '.generation_id // "default"' <<<"$input")
    duration_ms=$(jq -r '.duration // 0' <<<"$input")
else
    command_str=$(printf '%s' "$input" | grep -oE '"command"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed -E 's/.*"command"[[:space:]]*:[[:space:]]*"([^"]*)".*/\1/')
    generation_id="default"
    duration_ms=0
fi

if [ -n "${ATUIN_CURSOR_LOG:-}" ]; then
    printf '[%s] post gen=%s dur=%s cmd=%q\n' \
        "$(date -u +%FT%TZ)" "$generation_id" "$duration_ms" "${command_str:-<empty>}" \
        >> "$ATUIN_CURSOR_LOG"
fi

if [ -z "${command_str:-}" ] || [ "$command_str" = "null" ]; then
    exit 0
fi

cwd_file="/tmp/atuin-cursor-cwd-${generation_id}"
if [ -f "$cwd_file" ]; then
    cwd=$(cat "$cwd_file")
    rm -f "$cwd_file"
else
    cwd="${CURSOR_PROJECT_DIR:-$PWD}"
fi

# Subshell so we don't leak the cd into the hook's parent process.
(
    cd "$cwd" 2>/dev/null || exit 0

    # atuin history start emits the entry id on stdout.
    id=$(atuin history start --author cursor-agent -- "$command_str" 2>/dev/null) || exit 0
    [ -z "$id" ] && exit 0

    # Cursor reports duration in ms; atuin expects duration via --duration
    # in nanoseconds. Convert; fall back to no flag if math fails.
    if [ -n "${duration_ms:-}" ] && [ "$duration_ms" -gt 0 ] 2>/dev/null; then
        dur_ns=$(( duration_ms * 1000000 ))
        atuin history end --exit 0 --duration "$dur_ns" "$id" 2>/dev/null || \
            atuin history end --exit 0 "$id" 2>/dev/null || true
    else
        atuin history end --exit 0 "$id" 2>/dev/null || true
    fi
)

exit 0
