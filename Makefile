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
SIGNINGKEY ?=

VIMSTUFF_REPO ?= https://github.com/binaryaaron/vimstuff.git
VIMSTUFF_DIR  := $(HOME)/vimstuff
LOCAL_BIN  := $(HOME)/.local/bin
XDG_CONFIG := $(HOME)/.config
XDG_CACHE  := $(HOME)/.cache

.DEFAULT_GOAL := help

.PHONY: help install gitconfig xdg shell-links vim check-email ensure-dirs

help:
	@echo "Usage: make <target> EMAIL=you@example.com [NAME='Your Name']"
	@echo ""
	@echo "Targets:"
	@echo "  install      Full bootstrap: dirs + xdg + gitconfig + shell-links + vim + tools"
	@echo "  gitconfig    Write shared .gitconfig and inject [include] into ~/.gitconfig"
	@echo "  xdg          Create XDG dirs and symlink configs/bins into ~/.config and ~/.local/bin"
	@echo "  shell-links  Symlink shell rc files (~/.bashrc, ~/.zshrc, etc.)"
	@echo "  vim          Clone vimstuff and symlink ~/.vimrc and ~/.vim"
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

ensure-dirs:
	@mkdir -p "$(LOCAL_BIN)" "$(XDG_CONFIG)" "$(XDG_CACHE)"
	@echo "dirs: $(LOCAL_BIN), $(XDG_CONFIG), $(XDG_CACHE)"

install: check-email ensure-dirs vim
	EMAIL=$(EMAIL) NAME=$(NAME) SIGNINGKEY=$(SIGNINGKEY) DOTFILES=$(DOTFILES) bash $(DOTFILES)/initdotfiles.sh $(EMAIL) $(NAME) $(SIGNINGKEY)

gitconfig: check-email ensure-dirs
	@bash -c '\
		DOTFILES=$(DOTFILES) \
		. $(DOTFILES)/shells/utils.sh && \
		. $(DOTFILES)/shells/envvars.sh && \
		. $(DOTFILES)/shells/gitconfigs/init_gitconfig.sh && \
		setup_gitconfig "$(EMAIL)" "$(NAME)" "$(SIGNINGKEY)"'

xdg: ensure-dirs
	@bash -c '\
		DOTFILES=$(DOTFILES) \
		. $(DOTFILES)/shells/utils.sh && \
		. $(DOTFILES)/shells/envvars.sh && \
		. $(DOTFILES)/shells/xdg_home/init_xdg_stuff.sh && \
		init_xdg_home'

shell-links: ensure-dirs
	@bash -c '\
		DOTFILES=$(DOTFILES) \
		. $(DOTFILES)/shells/utils.sh && \
		_safe_symlink "$(DOTFILES)/shells/.bashrc"       "$(HOME)/.bashrc" && \
		_safe_symlink "$(DOTFILES)/shells/.bash_profile" "$(HOME)/.bash_profile" && \
		_safe_symlink "$(DOTFILES)/shells/.bashenv"      "$(HOME)/.bashenv" && \
		_safe_symlink "$(DOTFILES)/shells/.zshrc"        "$(HOME)/.zshrc" && \
		_safe_symlink "$(DOTFILES)/shells/.dircolors"    "$(HOME)/.dircolors"'

vim:
	@if [ ! -d "$(VIMSTUFF_DIR)" ]; then \
		git clone --recurse-submodules $(VIMSTUFF_REPO) $(VIMSTUFF_DIR); \
	else \
		echo "$(VIMSTUFF_DIR) already exists, skipping clone"; \
	fi
	@bash -c '\
		. $(DOTFILES)/shells/utils.sh && \
		_safe_symlink "$(VIMSTUFF_DIR)/.vimrc" "$(HOME)/.vimrc" && \
		_safe_symlink "$(VIMSTUFF_DIR)"         "$(HOME)/.vim"'
