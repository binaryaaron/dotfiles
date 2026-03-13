# dotfiles

Shell config, git aliases, and bootstrap for new machines.

## Just want the git aliases?

```bash
git clone https://github.com/binaryaaron/dotfiles.git ~/dotfiles
cd ~/dotfiles
make gitconfig EMAIL=you@example.com
```

`NAME` and `SIGNINGKEY` are optional. `SIGNINGKEY` defaults to the first of `id_ed25519`, `id_ecdsa`, `id_rsa` found in `~/.ssh/`.

This writes `dist/generated_gitconfig` and prepends one `[include]` line to your existing `~/.gitconfig`. Your identity, credential helpers, and everything else stay put — sections after the include win.

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

Installs gitconfig, shell rc symlinks, XDG dirs, vim, starship, and atuin.

## Targets

```
make gitconfig    EMAIL=...   shared gitconfig + [include] in ~/.gitconfig
make vim                      clone vimstuff, symlink ~/.vimrc and ~/.vim
make xdg                      XDG dirs + symlink configs and bins
make shell-links              ~/.bashrc, ~/.zshrc, ~/.bash_profile, ~/.bashenv
make ensure-dirs              ~/.local/bin, ~/.config, ~/.cache
```

---

## Configs

### atuin

History search. Config at `shells/xdg_home/config/atuin/config.toml`, symlinked to `~/.config/atuin/` by `make xdg`.

Non-defaults: `inline_height = 20`, `enter_accept = true` (Tab to edit before running), sync v2 on.

Install: `curl --proto '=https' --tlsv1.2 -LsSf https://setup.atuin.sh | sh`

### starship

Prompt at `shells/xdg_home/config/starship.toml`, symlinked to `~/.config/starship.toml` by `make xdg`.

Two-line layout: `user@hostname:os git_branch kube python` / `directory`. Branch hidden on `main`/`master`. Kube context always shown — edit `[kubernetes].contexts` for your clusters. Hostname trimmed at `nvidia.com`.

Install: `curl -sS https://starship.rs/install.sh | sh`

---

## Layout

```
shells/
  gitconfigs/
    .gitignore_global     symlinked to ~/.gitignore_global
    init_gitconfig.sh     setup_gitconfig() and friends
  xdg_home/
    config/               symlinked into ~/.config (atuin, ghostty, starship)
    bin/                  symlinked into ~/.local/bin
  .bashrc / .zshrc / .bashenv / .bash_profile
  aliases/
  completions.sh
  utils.sh                _safe_symlink and friends
dist/                     generated artifacts (gitignored)
initdotfiles.sh           called by `make install`
Makefile
```
