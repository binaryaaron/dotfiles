DOTFILES="${DOTFILES:-$HOME/dotfiles}"

. "$DOTFILES/shells/envvars.sh"
. "$DOTFILES/shells/xdg_home/init_xdg_stuff.sh"
. "$DOTFILES/shells/posix_compatible.sh"
. "$DOTFILES/shells/aliases/aliases.sh"
. "$DOTFILES/shells/aliases/bazel_aliases.sh"
. "$DOTFILES/shells/completions.sh"

set -o vi
