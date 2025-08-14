DOTFILES="${DOTFILES:-$(git rev-parse --show-toplevel)}"

source "$DOTFILES/shells/envvars.sh"
source "$DOTFILES/shells/xdg_home/init_xdg_stuff.sh"
source "$DOTFILES/shells/posix_compatible.sh"
source "$DOTFILES/shells/aliases/aliases.sh"
source "$DOTFILES/shells/aliases/bazel_aliases.sh"
source "$DOTFILES/shells/completions.sh"

set -o vi
