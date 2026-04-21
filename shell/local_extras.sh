# Machine-local shell extras. Sourced last from commonrc.sh so overrides
# take precedence over dotfiles-provided aliases, functions, and env.
#
# Nothing here is required to exist -- every block is a source-if-exists,
# so this file is a no-op on fresh clones.

_shell="${_shell:-$(basename "$SHELL")}"

# Per-user machine-local overrides: ~/.local.bashrc or ~/.local.zshrc
[ -f "$HOME/.local.${_shell}rc" ] && . "$HOME/.local.${_shell}rc"

# Optional kubernetes config aggregator (may be defined by host extras).
command -v add_kube_configs > /dev/null 2>&1 && add_kube_configs
