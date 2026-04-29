# dotfiles

Shell config, git aliases, and bootstrap for new machines.

## Just want the git aliases?

```bash
git clone https://github.com/binaryaaron/dotfiles.git ~/dotfiles
cd ~/dotfiles
make gitconfig EMAIL=you@example.com
```

`NAME` and `SIGNINGKEY` are optional. `SIGNINGKEY` defaults to the first of `id_ed25519`, `id_ecdsa`, `id_rsa` found in `~/.ssh/`.

This writes `git/generated_config` and prepends one `[include]` line to your existing `~/.gitconfig`. Your identity, credential helpers, and everything else stay put -- sections after the include win.

No `~/.gitconfig` yet? A minimal one gets created with your identity and an OS-appropriate credential helper.

### What's included

Aliases: `git l`, `git brs`, `git brsa`, `git ls`, `git ll`, `git incoming`, `git outgoing`, `git prune-local`, `git restore-all`, and more.

Settings: `push.autoSetupRemote`, `pull.rebase`, `rerere`, SSH commit signing, LFS filters, global gitignore.

---

## Full bootstrap

```bash
git clone https://github.com/binaryaaron/dotfiles.git ~/dotfiles
cd ~/dotfiles
make install EMAIL=you@example.com NAME="Your Name"
```

Installs gitconfig, shell rc symlinks, XDG dirs, and every CLI tool declared in `config/mise/config.toml` (starship, atuin, neovim, node, uv, jq, yq, ripgrep, github-cli, tree-sitter, bottom, ...) via [mise](https://mise.jdx.dev/). `make tools` installs mise itself (GPG-verified when `gpg` is present) and then runs `mise install`.

### Cloning somewhere other than `~/dotfiles`

All shell entrypoints resolve `DOTFILES` at runtime, defaulting to `$HOME/dotfiles`. If you clone elsewhere, export `DOTFILES` before starting a shell:

```bash
git clone https://github.com/binaryaaron/dotfiles.git ~/src/dotfiles
cd ~/src/dotfiles
DOTFILES=~/src/dotfiles make install EMAIL=you@example.com NAME="Your Name"
# Persist for future shells:
echo 'export DOTFILES=$HOME/src/dotfiles' >> ~/.profile
```

### Non-root hosts

Tool installation no longer needs root. `make tools` installs mise into `~/.local/bin` (via the official installer) and mise drops all managed binaries as shims under `~/.local/share/mise/shims`. `apt-get` is used only for `bash-completion` when running as root on Debian-family; everything else is user-scope.

## Targets

```text
make install       EMAIL=...   full bootstrap (ensure-dirs + xdg + gitconfig + shell-links + tools)
make gitconfig     EMAIL=...   shared gitconfig + [include] in ~/.gitconfig
make xdg                       XDG dirs + symlink configs, nvim, and bins
make shell-links               ~/.bashrc, ~/.zshrc, ~/.zprofile, ~/.bash_profile, ~/.bashenv, ~/.dircolors
make vim                       symlink ~/.vimrc and ~/.vim, install Vundle plugins
make nvim                      reminder target (nvim is installed by 'make tools' via mise)
make install-mise              install mise itself (GPG-verified when gpg is available)
make mise-install              trust global mise config and run 'mise install'
make tools                     mise + tools in config/mise/config.toml; ble.sh/bash-preexec only for bash login shells
make ensure-dirs               ~/.local/bin, ~/.config, ~/.cache
make restore                   restore .bak files and remove dotfile symlinks
```

---

## Layout

```text
config/        symlinked into ~/.config/ (atuin, blesh, ghostty, mise, starship)
home/          symlinked 1:1 into $HOME (entrypoints: .bashrc, .zshrc, etc.)
shell/         sourced at runtime by entrypoints (aliases, envvars, completions, utils)
git/           gitconfig generator, global ignore, generated_config (gitignored)
nvim/          neovim config, symlinked to ~/.config/nvim by make xdg
vim/           vim config, symlinked to ~/.vimrc and ~/.vim by make vim
bin/           scripts symlinked into ~/.local/bin/
assets/        fonts, macOS utilities, pandoc templates, avatars
```

---

## Configs

### mise

Tool-version manager. Global config at `config/mise/config.toml`, symlinked to `~/.config/mise/config.toml` by `make xdg`. Every CLI tool this repo used to `curl | sh` (starship, atuin, neovim, tree-sitter, node/nvm, bottom, jq, ...) is now declared there and installed by `make tools`.

Shell activation happens in `shell/completions.sh` via `mise activate`, which puts mise shims on PATH, auto-installs missing tools on `cd`, and evaluates `[env]`/`_.file` blocks from any `mise.toml` in an ancestor directory. This replaces the previous `direnv` hook -- mise covers the same per-directory env/tool loading with one binary.

Add or pin a tool: edit `config/mise/config.toml` and `mise install`, or run `mise use -g <tool>@<version>`.

Per-machine overrides: drop a `~/.config/mise/config.local.toml` next to the tracked config. mise merges `config.local.toml` on top of the committed `config.toml`, so you can pin a tool locally (e.g., match a project's node version) without editing anything under version control.

Worktree trust: if you use git worktrees and don't want to run `mise trust` in every new checkout, export `MISE_TRUSTED_CONFIG_PATHS` from your host-local rc file (`~/.local.bashrc` / `~/.local.zshrc`, sourced by `commonrc.sh`):

```bash
export MISE_TRUSTED_CONFIG_PATHS="$HOME/dev"
```

### atuin

History search. Config at `config/atuin/config.toml`, symlinked to `~/.config/atuin/` by `make xdg`. Binary installed by mise (`make tools`). Bash uses `ble.sh` as the preferred preexec backend when installed, with `bash-preexec` kept as fallback. `make tools` installs those Bash-only backends only when the login shell is Bash; pass `BASH_TOOLS=1` to force them.

Non-defaults: `inline_height = 20`, `enter_accept = true` (Tab to edit before running), sync v2 on.

### Cursor hooks (optional)

Capture shell commands that the Cursor agent runs into your atuin history, tagged with author `cursor-agent`.

Install:

```bash
make cursor-hooks   # merges entries into ~/.cursor/hooks.json, symlinks scripts
```

What it does:

- Registers `beforeShellExecution` and `afterShellExecution` hooks pointing at scripts symlinked from `config/cursor/hooks/` in this repo.
- Preserves any existing `hooks.json` entries (audit scripts, guards, etc.) — the target uses `jq` to merge idempotently and backs up the original to `hooks.json.bak` on first run.
- Records every agent-executed command with `--author cursor-agent`, `--exit 0` (Cursor's payload doesn't expose exit codes), and the real duration from the payload.

Query them:

```bash
atuin search --author cursor-agent -- ''   # all Cursor-run commands
atuin search --author '$all-user' -- ''    # human-run only (default behavior)
```

Debugging: set `ATUIN_CURSOR_LOG=/tmp/atuin-cursor.log` in Cursor's environment to see every hook invocation logged with timestamps.

Limitations:

- Cursor's `afterShellExecution` payload lacks exit code; all commands record as successful. [Upstream docs](https://cursor.com/docs/agent/hooks#aftershellexecution).
- Atuin's `$all-agent` search selector only groups built-in agents (`claude-code`, `codex`, `copilot`, `pi`); until atuin adds Cursor, use `--author cursor-agent` directly.
- Requires `jq`, which `make tools` installs via mise (from `config/mise/config.toml`).

### starship

Prompt at `config/starship.toml`, symlinked to `~/.config/starship.toml` by `make xdg`. Binary installed by mise (`make tools`).

Two-line layout: `user@hostname:os git_branch kube python` / `directory`. Branch hidden on `main`/`master`. Kube context always shown -- edit `[kubernetes].contexts` for your clusters. Hostname trimmed at `nvidia.com`.
