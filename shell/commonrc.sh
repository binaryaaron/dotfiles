DOTFILES="${DOTFILES:-$HOME/dotfiles}"

. "$DOTFILES/shell/envvars.sh"
. "$DOTFILES/shell/init_xdg.sh"
. "$DOTFILES/shell/posix_compatible.sh"
. "$DOTFILES/shell/aliases.sh"
. "$DOTFILES/shell/bazel_aliases.sh"
. "$DOTFILES/shell/completions.sh"
. "$DOTFILES/shell/starship.sh"

set -o vi
