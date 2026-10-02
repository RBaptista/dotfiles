# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

Personal Arch Linux / CachyOS dotfiles: Hyprland desktop (Tokyo Night theme with cyan `#00FFFF` accent), zsh + Powerlevel10k, LazyVim. Goal: on any Arch-based machine, clone to `~/dotfiles`, run `./install.sh`, done. No build, lint, or test tooling — "testing" a change means deploying it and reloading the relevant program (e.g. `hyprctl reload`, restarting `waybar`).

## Commands

- `./install.sh` — full, idempotent setup: installs `yay` if missing, everything in `packages.txt` (+ zsh prompt packages chosen per distro), stows all packages, sets zsh as login shell, installs nvm + Node LTS, restores Neovim plugins from `lazy-lock.json`, installs the SDDM theme and force-enables SDDM, enables NetworkManager. Refuses to run as root.
- `stow -d ~/dotfiles -t ~ <pkg>` — symlink a single package into `$HOME`.
- `system/sddm/install_sddm.sh` — copies (not symlinks) the SDDM theme to `/usr/share/sddm/themes/` and `theme.conf` to `/etc/sddm.conf.d/`. Must be re-run after editing anything under `system/sddm/`.
- `luac -p hypr/.config/hypr/**/*.lua` — offline syntax check of the Hyprland config; on a running session use `hyprctl reload && hyprctl configerrors`.

## Layout / architecture

- **GNU Stow packages**: each top-level dir in `STOW_PACKAGES` (`install.sh`: hypr, waybar, rofi, alacritty, wlogout, yazi, nvim, zsh) mirrors `$HOME`: config lives at `<pkg>/.config/<pkg>/...`, except `zsh/` whose `.zshrc`/`.p10k.zsh` sit at the package root because they belong in `~`. Edit files in the repo; the live paths are symlinks into it. Adding a package = create that structure + add it to `STOW_PACKAGES`. Files at a package root land directly in `~/`, so don't put stray files there.
- **Conflicts are backed up, never adopted**: before stowing, `install.sh` moves anything at a target path that isn't already our symlink (files, or dir symlinks pointing elsewhere) to `~/.dotfiles-backup/<timestamp>/`. It never touches the repo's working tree.
- **Hyprland config is Lua (0.55+)**: `hyprland.lua` `require`s `monitors.lua`, `autostart.lua`, `keybinds.lua`. Each `require` runs in an isolated scope, so locals don't cross files — keep shared values in the file that uses them. Hyprland ignores `.conf` files once `hyprland.lua` exists; only hypridle/hyprlock/hyprpaper still use `.conf`. `hyprctl dispatch` takes Lua in 0.55 (e.g. `hyprctl dispatch 'hl.dsp.exit()'`), which matters for commands in hypridle.conf and wlogout's `layout`.
- **Per-host monitors**: `monitors.lua` sets an auto-detect fallback, then loads `hosts/<hostname>.lua` (hostname from `/etc/hostname`) if it exists. Host files hold that machine's `hl.monitor` and `hl.workspace_rule` calls (workspaces are `persistent`, so waybar shows them). Nothing else (waybar, hyprlock) should name specific monitors.
- **Hardcoded repo path**: `hyprpaper.conf` and `hyprlock.conf` reference wallpapers at `~/dotfiles/cyan_wall/`. The repo must live at `~/dotfiles`.
- **Not stowed**: `system/` (SDDM, installed via copy with sudo), `cyan_wall/` (wallpapers referenced by path).
- **SDDM theme is vendored**: `system/sddm/tokyo-night-sddm/` is plain files (upstream went private). It's a Qt5 theme, hence the `qt5-*` packages.
- **Packages**: `packages.txt` is the source of truth (one per line, `#` comments allowed, installed via `yay` so AUR names are fine). Every config dependency must be listed there — a name that doesn't exist makes `yay` and therefore the whole install fail.
- **zsh**: `zsh/.zshrc` sources `cachyos-zsh-config` (oh-my-zsh + p10k + plugins) when present; on plain Arch it falls back to sourcing p10k/autosuggestions/syntax-highlighting from `/usr/share`. `install.sh` installs whichever set matches the distro. Node comes from nvm in `~/.nvm`, not pacman.
- **Neovim**: LazyVim starter in `nvim/.config/nvim/`; extras are in `lazyvim.json`, plugin versions pinned in `lazy-lock.json` (commit it after `:Lazy update`). lazygit uses its defaults (no config tracked).
