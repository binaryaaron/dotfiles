# Dotfiles bootstrap interface.
#
# Design:
#   - DOTFILES is derived from this file's location so targets work from any
#     working directory.
#   - Subcomponent targets source only what they need and are safe to re-run
#     in isolation (e.g. `make gitconfig` after editing aliases).
#   - EMAIL is required for any target touching ~/.gitconfig identity; no
#     defaults so teammates can't silently bootstrap with someone else's name.
#   - gitconfig strategy: dist/generated_gitconfig holds shared portable prefs;
#     ~/.gitconfig on each machine keeps local identity and gets a single
#     [include] prepended. Sections after the include take precedence.

DOTFILES := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
SHELL    := /usr/bin/env bash

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
. $(DOTFILES)/shells/utils.sh; \
. $(DOTFILES)/shells/envvars.sh
endef

.DEFAULT_GOAL := help

.PHONY: help install gitconfig xdg shell-links vim nvim tools check-email check-signingkey ensure-dirs restore

help:
	@echo "Usage: make <target> EMAIL=you@example.com [NAME='Your Name'] [SIGNINGKEY=~/.ssh/id_ed25519.pub] [FORCE=1]"
	@echo "       SIGNINGKEY defaults to ~/.ssh/id_ed25519.pub if not specified"
	@echo ""
	@echo "Targets:"
	@echo "  install      Full bootstrap: ensure-dirs + xdg + gitconfig + shell-links
	@echo "  gitconfig    Write shared .gitconfig and inject [include] into ~/.gitconfig"
	@echo "  xdg          Create XDG dirs and symlink configs/bins into ~/.config and ~/.local/bin"
	@echo "  shell-links  Symlink shell rc files (~/.bashrc, ~/.zshrc, etc.)"
	@echo "  vim          Symlink ~/.vimrc and ~/.vim, install Vundle plugins"
	@echo "  nvim         Symlink ~/.config/nvim and install neovim if missing"
	@echo "  tools        Install bash-completion, starship, atuin, bash-preexec if not already present"
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
		echo "WARNING: SIGNINGKEY not found at $(SIGNINGKEY) -- git commits will not be signed" >&2; \
		echo "         Generate one with: ssh-keygen -t ed25519 -C you@example.com" >&2; \
		echo "         Or pass a different path: make gitconfig SIGNINGKEY=~/.ssh/other.pub" >&2; \
	fi

ensure-dirs:
	@mkdir -p "$(LOCAL_BIN)" "$(XDG_CONFIG)" "$(XDG_CACHE)"
	@echo "dirs: $(LOCAL_BIN), $(XDG_CONFIG), $(XDG_CACHE)"

install: check-email ensure-dirs xdg gitconfig tools shell-links

gitconfig: check-email check-signingkey ensure-dirs
	@$(BASH_INIT); \
	. $(DOTFILES)/shells/gitconfigs/init_gitconfig.sh && \
	setup_gitconfig "$(EMAIL)" "$(NAME)" "$(SIGNINGKEY)"

xdg: ensure-dirs
	@$(BASH_INIT); \
	. $(DOTFILES)/shells/xdg_home/init_xdg_stuff.sh && \
	init_xdg_home

shell-links: ensure-dirs
	@$(BASH_INIT); \
	_safe_symlink "$(DOTFILES)/shells/.bashrc"       "$(HOME)/.bashrc" && \
	_safe_symlink "$(DOTFILES)/shells/.bash_profile" "$(HOME)/.bash_profile" && \
	_safe_symlink "$(DOTFILES)/shells/.bashenv"      "$(HOME)/.bashenv" && \
	_safe_symlink "$(DOTFILES)/shells/.zshrc"        "$(HOME)/.zshrc" && \
	_safe_symlink "$(DOTFILES)/shells/.dircolors"    "$(HOME)/.dircolors"

nvim:
	@_nvim_ok=0; \
	if command -v nvim > /dev/null 2>&1; then \
		_major=$$(nvim --version | head -1 | grep -oP 'v\K\d+'); \
		_minor=$$(nvim --version | head -1 | grep -oP 'v\d+\.\K\d+'); \
		[ "$$_major" -gt 0 ] || [ "$$_minor" -ge 10 ] && _nvim_ok=1; \
	fi; \
	if [ "$$_nvim_ok" -eq 0 ]; then \
		echo "installing neovim (latest stable)..."; \
		if command -v brew > /dev/null 2>&1; then \
			brew install neovim; \
		else \
			curl -fsSL https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz \
				| tar -xz -C /usr/local --strip-components=1; \
		fi; \
	else \
		echo "neovim $$(nvim --version | head -1) already installed, skipping"; \
	fi
	@$(BASH_INIT); \
	_safe_symlink "$(DOTFILES)/shells/xdg_home/config/nvim" "$(HOME)/.config/nvim"
	@echo "neovim ready -- run 'nvim' to trigger lazy.nvim bootstrap on first launch"

tools:
	@if command -v apt-get > /dev/null 2>&1; then \
		dpkg -l bash-completion 2>/dev/null | grep -q '^ii' || \
			{ echo "installing bash-completion..."; apt-get install -y bash-completion; }; \
	elif command -v brew > /dev/null 2>&1; then \
		brew list bash-completion@2 > /dev/null 2>&1 || \
			{ echo "installing bash-completion..."; brew install bash-completion@2; }; \
	fi
	@command -v tree-sitter > /dev/null 2>&1 || \
		{ echo "installing tree-sitter CLI..."; \
		  if command -v brew > /dev/null 2>&1; then \
		      brew install tree-sitter; \
		  else \
		      curl -fsSL https://github.com/tree-sitter/tree-sitter/releases/latest/download/tree-sitter-linux-x64.gz \
		          | gunzip > /usr/local/bin/tree-sitter && chmod +x /usr/local/bin/tree-sitter; \
		  fi; }
	@command -v starship > /dev/null 2>&1 || \
		{ echo "installing starship..."; FORCE=1 curl -sS https://starship.rs/install.sh | sh; }
		# FORCE=1 above is the starship installer's own flag to skip version checks, unrelated to dotfiles FORCE
	@command -v atuin > /dev/null 2>&1 || \
		{ echo "installing atuin..."; curl --proto '=https' --tlsv1.2 -LsSf https://setup.atuin.sh | sh -s -- --non-interactive }
	@[ -f "$(HOME)/.bash-preexec.sh" ] || \
		{ echo "installing bash-preexec..."; curl -sS https://raw.githubusercontent.com/rcaloras/bash-preexec/master/bash-preexec.sh -o "$(HOME)/.bash-preexec.sh"; }

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
	_restore_symlink "$(HOME)/.dircolors"; \
	_restore_symlink "$(HOME)/.vimrc"; \
	_restore_symlink "$(HOME)/.vim"

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
