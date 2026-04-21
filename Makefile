# Dotfiles bootstrap interface.
#
# Design:
#   - DOTFILES is derived from this file's location so targets work from any
#     working directory.
#   - Subcomponent targets source only what they need and are safe to re-run
#     in isolation (e.g. `make gitconfig` after editing aliases).
#   - EMAIL is required for any target touching ~/.gitconfig identity; no
#     defaults so teammates can't silently bootstrap with someone else's name.
#   - gitconfig strategy: git/generated_config holds shared portable prefs;
#     ~/.gitconfig on each machine keeps local identity and gets a single
#     [include] prepended. Sections after the include take precedence.

DOTFILES := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
SHELL    := bash
UNAME_S := $(shell uname -s)
ARCH := $(shell uname -m)
PLATFORM := $(shell echo $(UNAME_S) | tr '[:upper:]' '[:lower:]')

# Put mise shims on PATH for recipes so `tree-sitter`, `jq`, etc. resolve to
# mise-managed versions during bootstrap without requiring shell activation.
export PATH := $(HOME)/.local/share/mise/shims:$(HOME)/.local/bin:$(PATH)

# mise install pinning -- bumped in lockstep with Safe-Synthesizer/other repos.
MISE_GPG_KEY := 24853EC9F655CE80B48E6C3A8B81C9D17413A06D

ifeq ($(ARCH),x86_64)
	ARCH := amd64
endif
ifeq ($(ARCH),aarch64)
	ARCH := arm64
endif

ifeq ($(PLATFORM),darwin)
	OS := darwin
endif
ifeq ($(PLATFORM),linux)
	OS := linux
endif

# Identity — required for gitconfig/install, no defaults by design.
EMAIL      ?=
NAME       ?=
SIGNINGKEY ?= $(HOME)/.ssh/id_ed25519.pub
FORCE      ?= 0

VIM_DIR    := $(DOTFILES)/vim
LOCAL_BIN  := $(HOME)/.local/bin
XDG_CONFIG := $(HOME)/.config
XDG_CACHE  := $(HOME)/.cache

# Common preamble: export DOTFILES and source shared helpers into the recipe shell.
define BASH_INIT
export DOTFILES=$(DOTFILES); \
export FORCE=$(FORCE); \
. $(DOTFILES)/shell/utils.sh; \
. $(DOTFILES)/shell/envvars.sh
endef

.DEFAULT_GOAL := help

.PHONY: help install gitconfig xdg shell-links vim nvim tools cursor-hooks check-email check-signingkey ensure-dirs restore install-mise mise-install

help:
	@echo "Usage: make <target> EMAIL=you@example.com [NAME='Your Name'] [SIGNINGKEY=~/.ssh/id_ed25519.pub] [FORCE=1]"
	@echo "       SIGNINGKEY defaults to ~/.ssh/id_ed25519.pub if not specified"
	@echo ""
	@echo "Targets:"
	@echo "  install      Full bootstrap: ensure-dirs + xdg + gitconfig + shell-links"
	@echo "  gitconfig    Write shared .gitconfig and inject [include] into ~/.gitconfig"
	@echo "  xdg          Create XDG dirs and symlink configs/bins into ~/.config and ~/.local/bin"
	@echo "  shell-links  Symlink shell rc files (~/.bashrc, ~/.zshrc, etc.)"
	@echo "  vim          Symlink ~/.vimrc and ~/.vim, install Vundle plugins"
	@echo "  nvim         Reminder: nvim is installed via mise (make tools); config symlinked by 'make xdg'"
	@echo "  install-mise Install mise itself (GPG-verified if gpg is available)"
	@echo "  mise-install Trust global mise config and run 'mise install' (tools list lives in config/mise/config.toml)"
	@echo "  tools        Install system bits mise can't own (bash-completion, bash-preexec) then run mise-install"
	@echo "  cursor-hooks Merge atuin capture hooks into ~/.cursor/hooks.json (idempotent); symlinks scripts into ~/.cursor/hooks/atuin/"
	@echo "  restore      Restore .bak files and remove dotfile symlinks"
	@echo "  ensure-dirs  Create $(LOCAL_BIN), $(XDG_CONFIG), $(XDG_CACHE) if missing"
	@echo ""
	@echo "Examples:"
	@echo "  make install EMAIL=you@example.com NAME='Your Name'"
	@echo "  make gitconfig EMAIL=you@example.com"
	@echo "  make gitconfig EMAIL=you@example.com SIGNINGKEY=~/.ssh/id_rsa.pub"
	@echo "  make xdg"

check-email:
	@if [ -z "$(EMAIL)" ]; then \
		echo "ERROR: EMAIL is required. Usage: make $(MAKECMDGOALS) EMAIL=you@example.com" >&2; \
		exit 1; \
	fi

check-signingkey:
	@if [ ! -f "$(SIGNINGKEY)" ]; then \
		echo "note: SIGNINGKEY not found at $(SIGNINGKEY) -- commit.gpgsign will be skipped on this host." >&2; \
		echo "      generate one with: ssh-keygen -t ed25519 -C you@example.com" >&2; \
		echo "      or pass a different path: make gitconfig SIGNINGKEY=~/.ssh/other.pub" >&2; \
	fi

ensure-dirs:
	@mkdir -p "$(LOCAL_BIN)" "$(XDG_CONFIG)" "$(XDG_CACHE)"
	@echo "dirs: $(LOCAL_BIN), $(XDG_CONFIG), $(XDG_CACHE)"

# Order matters: tools first so mise-managed binaries (gh, jq, ...) are on
# PATH before gitconfig runs -- gitconfig emits the gh credential helper
# only when `command -v gh` succeeds at generation time.
install: check-email ensure-dirs tools xdg gitconfig shell-links

# Note: the former `profile` target (which appended `export BASH_ENV=...`
# to ~/.profile) has been removed. BASH_ENV caused non-interactive `bash -c`
# invocations -- of which the Cursor persistent-shell wrapper issues many --
# to re-source ~/.bashenv on every call, amplifying startup cost and
# stacking wrapper bashes. Interactive shell setup is handled by ~/.bashrc;
# non-interactive shells inherit the parent environment.

gitconfig: check-email check-signingkey ensure-dirs
	@$(BASH_INIT); \
	. $(DOTFILES)/git/init.sh && \
	setup_gitconfig "$(EMAIL)" "$(NAME)" "$(SIGNINGKEY)"

xdg: ensure-dirs
	@$(BASH_INIT); \
	. $(DOTFILES)/shell/init_xdg.sh && \
	init_xdg_home

shell-links: ensure-dirs
	@$(BASH_INIT); \
	_safe_symlink "$(DOTFILES)/home/.bashrc"       "$(HOME)/.bashrc" && \
	_safe_symlink "$(DOTFILES)/home/.bash_profile" "$(HOME)/.bash_profile" && \
	_safe_symlink "$(DOTFILES)/home/.bashenv"      "$(HOME)/.bashenv" && \
	_safe_symlink "$(DOTFILES)/home/.zshrc"        "$(HOME)/.zshrc" && \
	_safe_symlink "$(DOTFILES)/home/.zprofile"     "$(HOME)/.zprofile" && \
	_safe_symlink "$(DOTFILES)/home/.dircolors"    "$(HOME)/.dircolors" && \
	_safe_symlink "$(DOTFILES)/home/.latexmkrc"    "$(HOME)/.latexmkrc"

nvim: tools
	@echo "neovim is managed by mise (declared in config/mise/config.toml)."
	@echo "'make tools' already installed it; check with: mise ls neovim"
	@echo "run 'nvim' to trigger lazy.nvim bootstrap on first launch"
	@echo "(nvim config is symlinked by 'make xdg' -- run that if ~/.config/nvim is missing)"
	@# Alias `vim` to nvim via a $(LOCAL_BIN) exec wrapper. $(LOCAL_BIN)
	@# precedes /usr/bin on PATH (see shell/envvars.sh), so this shadows any
	@# system vim. A wrapper is used instead of a symlink because mise shims
	@# dispatch on $$argv[0]: a symlink named `vim` pointing at the nvim shim
	@# makes mise reject it ("vim is not a valid shim").
	@printf '#!/usr/bin/env bash\nexec nvim "$$@"\n' > "$(LOCAL_BIN)/vim"
	@chmod +x "$(LOCAL_BIN)/vim"
	@echo "wrote $(LOCAL_BIN)/vim (exec wrapper -> nvim)"

# install mise itself. GPG-verified when gpg is available, per upstream
# recommendation (https://mise.jdx.dev/installing-mise.html). install.sh.sig is
# a GPG clearsigned document (script + signature in one file), so --decrypt
# both verifies and extracts.
install-mise:
	@command -v mise > /dev/null 2>&1 || { \
		set -euo pipefail; \
		echo "mise not found -- installing..."; \
		if command -v gpg > /dev/null 2>&1; then \
			echo "verifying installer signature..."; \
			gpg --batch --no-tty --keyserver hkps://keys.openpgp.org --recv-keys $(MISE_GPG_KEY); \
			_tmp=$$(mktemp); \
			curl -fsSL https://mise.jdx.dev/install.sh.sig | gpg --batch --no-tty --decrypt > "$$_tmp"; \
			sh "$$_tmp"; \
			rm -f "$$_tmp"; \
		else \
			echo "WARNING: gpg not available -- installing without signature verification" >&2; \
			curl -fsSL https://mise.run | sh; \
		fi; \
		command -v mise > /dev/null 2>&1 || { echo "ERROR: mise not found on PATH after install -- ensure $$HOME/.local/bin is on PATH" >&2; exit 1; }; \
	}
	@mise --version

# Install all tools declared in the global mise config
# (config/mise/config.toml). Symlinks just the mise config dir into place
# (full XDG linking happens via `make xdg`); mise trust then makes the config
# auto-load without an interactive prompt.
mise-install: install-mise ensure-dirs
	@$(BASH_INIT); \
	_safe_symlink "$(DOTFILES)/config/mise" "$(XDG_CONFIG)/mise"
	MISE_YES=1 mise trust "$(XDG_CONFIG)/mise/config.toml"
	MISE_YES=1 mise install
	@# reshim is implicit after install, but keep it explicit: catches tools
	@# that drop binaries mise didn't auto-detect, and restores shims if
	@# ~/.local/share/mise/shims was nuked (rm -rf, container rebuild).
	mise reshim
	@echo "mise tools installed. PATH activation happens in commonrc.sh via 'mise activate'."

tools: ensure-dirs mise-install
	@set -e; \
	_install() { \
		local name="$$1" check="$$2" install="$$3"; \
		if eval "$$check" > /dev/null 2>&1; then \
			echo "$$name already installed, skipping"; \
		else \
			echo "installing $$name..."; \
			eval "$$install"; \
		fi; \
	}; \
	if [ "$(OS)" = "darwin" ]; then \
		_install bash-completion 'brew list bash-completion@2' 'brew install bash-completion@2'; \
	else \
		if command -v apt-get > /dev/null 2>&1 && [ "$$(id -u)" = "0" ]; then \
			_install bash-completion "dpkg -l bash-completion 2>/dev/null | grep -q '^ii'" 'apt-get install -y bash-completion'; \
		fi; \
	fi; \
	_install bash-preexec '[ -f "$(HOME)/.bash-preexec.sh" ]' \
		'curl -sS https://raw.githubusercontent.com/rcaloras/bash-preexec/master/bash-preexec.sh -o "$(HOME)/.bash-preexec.sh"'

## Merge atuin capture hooks into ~/.cursor/hooks.json idempotently.
## - Symlinks dotfiles scripts into ~/.cursor/hooks/atuin/ so edits in the repo
##   propagate instantly.
## - Backs up hooks.json to hooks.json.bak on first run (never overwrites).
## - Uses absolute script paths; existing entries with the same command are
##   deduplicated so repeated invocations are no-ops.
cursor-hooks:
	@set -e; \
	command -v jq > /dev/null 2>&1 || { echo "ERROR: jq is required for cursor-hooks (install with 'make tools')" >&2; exit 1; }; \
	_cursor_dir="$(HOME)/.cursor"; \
	_hooks_json="$$_cursor_dir/hooks.json"; \
	_atuin_dir="$$_cursor_dir/hooks/atuin"; \
	_src_dir="$(DOTFILES)/config/cursor/hooks"; \
	_pre="$$_atuin_dir/atuin-capture-cwd.sh"; \
	_post="$$_atuin_dir/atuin-history.sh"; \
	mkdir -p "$$_atuin_dir"; \
	ln -sfn "$$_src_dir/atuin-capture-cwd.sh" "$$_pre"; \
	ln -sfn "$$_src_dir/atuin-history.sh"     "$$_post"; \
	echo "cursor-hooks: symlinked scripts into $$_atuin_dir"; \
	if [ ! -f "$$_hooks_json" ]; then \
		echo '{"version":1,"hooks":{}}' > "$$_hooks_json"; \
		echo "cursor-hooks: created $$_hooks_json"; \
	elif [ ! -f "$$_hooks_json.bak" ]; then \
		cp "$$_hooks_json" "$$_hooks_json.bak"; \
		echo "cursor-hooks: backed up existing hooks.json -> hooks.json.bak"; \
	fi; \
	jq --arg pre "$$_pre" --arg post "$$_post" \
		'.hooks |= (. // {}) | .hooks.beforeShellExecution |= ((. // []) | map(select(.command != $$pre)) + [{"command": $$pre}]) | .hooks.afterShellExecution |= ((. // []) | map(select(.command != $$post)) + [{"command": $$post}])' \
		"$$_hooks_json" > "$$_hooks_json.tmp" && mv "$$_hooks_json.tmp" "$$_hooks_json"; \
	echo "cursor-hooks: merged atuin entries into $$_hooks_json"; \
	echo ""; \
	echo "Active shell-execution hooks:"; \
	jq -r '.hooks.beforeShellExecution[]?.command | "  pre:  " + .' "$$_hooks_json"; \
	jq -r '.hooks.afterShellExecution[]?.command  | "  post: " + .' "$$_hooks_json"; \
	echo ""; \
	echo "Reload Cursor (or save hooks.json) to activate. Verify with:"; \
	echo "  ATUIN_CURSOR_LOG=/tmp/atuin-cursor.log  # set in Cursor env, then run a shell command"; \
	echo "  atuin search --author cursor-agent -- ''"

restore:
	@$(BASH_INIT); \
	_restore_symlink() { \
		local dst="$$1"; \
		if [ -f "$${dst}.bak" ] || [ -L "$${dst}.bak" ]; then \
			[ -L "$$dst" ] && rm "$$dst" && echo "removed symlink $$dst"; \
			mv "$${dst}.bak" "$$dst" && echo "restored $${dst}.bak -> $$dst"; \
		elif [ -L "$$dst" ]; then \
			echo "warning: no backup for $$dst, leaving symlink in place" >&2; \
		fi; \
	}; \
	_restore_symlink "$(HOME)/.bashrc"; \
	_restore_symlink "$(HOME)/.bash_profile"; \
	_restore_symlink "$(HOME)/.bashenv"; \
	_restore_symlink "$(HOME)/.zshrc"; \
	_restore_symlink "$(HOME)/.zprofile"; \
	_restore_symlink "$(HOME)/.dircolors"; \
	_restore_symlink "$(HOME)/.latexmkrc"; \
	_restore_symlink "$(HOME)/.vimrc"; \
	_restore_symlink "$(HOME)/.vim"; \
	if [ -f "$(LOCAL_BIN)/vim" ] && grep -q 'exec nvim' "$(LOCAL_BIN)/vim" 2>/dev/null; then \
		rm -f "$(LOCAL_BIN)/vim" && echo "removed $(LOCAL_BIN)/vim (vim->nvim wrapper)"; \
	fi

vim:
	@if [ ! -d "$(VIM_DIR)/bundle/Vundle.vim" ]; then \
		echo "installing Vundle..."; \
		git clone https://github.com/VundleVim/Vundle.vim.git "$(VIM_DIR)/bundle/Vundle.vim"; \
	else \
		echo "Vundle already installed, skipping"; \
	fi
	@$(BASH_INIT); \
	_safe_symlink "$(VIM_DIR)/.vimrc" "$(HOME)/.vimrc" && \
	_safe_symlink "$(VIM_DIR)"         "$(HOME)/.vim"
	@echo "installing/updating Vundle plugins..."
	@vim -u "$(VIM_DIR)/.vimrc" +PluginInstall +qall 2>/dev/null || \
		echo "warning: vim plugin install failed -- run 'vim +PluginInstall +qall' manually"
