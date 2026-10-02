#!/usr/bin/env bash
#
# install.sh — one-shot setup for RBaptista/dotfiles (Arch / CachyOS)
#
# Run this from inside the cloned repo:
#   git clone https://github.com/RBaptista/dotfiles.git ~/dotfiles
#   cd ~/dotfiles
#   ./install.sh
#
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STOW_PACKAGES=(hypr waybar rofi alacritty wlogout yazi nvim zsh)
BACKUP_DIR="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"

log()  { printf '\033[1;36m==>\033[0m %s\n' "$1"; }
warn() { printf '\033[1;33m!!\033[0m %s\n' "$1"; }
die()  { printf '\033[1;31mERROR:\033[0m %s\n' "$1" >&2; exit 1; }

# ---------------------------------------------------------------------------
# 0. Sanity checks
# ---------------------------------------------------------------------------
[[ "$EUID" -eq 0 ]] && die "Don't run this as root. Run as your normal user; it will sudo when needed."
command -v pacman >/dev/null 2>&1 || die "This script is Arch-only (pacman not found)."

if [[ "$DOTFILES_DIR" != "$HOME/dotfiles" ]]; then
    warn "Repo is at $DOTFILES_DIR, not \$HOME/dotfiles."
    warn "hyprpaper.conf and hyprlock.conf hardcode ~/dotfiles/cyan_wall for wallpapers."
    read -rp "Continue anyway? [y/N] " reply
    [[ "$reply" =~ ^[Yy]$ ]] || exit 1
fi

# ---------------------------------------------------------------------------
# 1. yay (AUR helper)
# ---------------------------------------------------------------------------
if ! command -v yay >/dev/null 2>&1; then
    log "yay not found, installing it..."
    sudo pacman -S --needed --noconfirm base-devel git
    tmp_yay="$(mktemp -d)"
    git clone https://aur.archlinux.org/yay-bin.git "$tmp_yay/yay-bin"
    (cd "$tmp_yay/yay-bin" && makepkg -si --noconfirm)
    rm -rf "$tmp_yay"
fi

# ---------------------------------------------------------------------------
# 2. Packages
# ---------------------------------------------------------------------------
log "Installing packages from packages.txt..."
mapfile -t PKGS < <(grep -vE '^\s*(#|$)' "$DOTFILES_DIR/packages.txt")

# zsh prompt + plugins: CachyOS bundles them in cachyos-zsh-config, which
# .zshrc sources when present; on plain Arch, install the pieces directly.
if pacman -Si cachyos-zsh-config >/dev/null 2>&1; then
    PKGS+=(cachyos-zsh-config)
else
    PKGS+=(zsh-theme-powerlevel10k zsh-autosuggestions zsh-syntax-highlighting)
fi

yay -S --needed --noconfirm "${PKGS[@]}"

hypr_ver="$(pacman -Q hyprland | awk '{print $2}')"
if [[ "$(vercmp "$hypr_ver" 0.55)" -lt 0 ]]; then
    die "Hyprland $hypr_ver is too old: this config is Lua (hyprland.lua), which needs 0.55+."
fi

# ---------------------------------------------------------------------------
# 3. Symlink dotfiles with GNU Stow
# ---------------------------------------------------------------------------
# Anything already at a target path that isn't ours is moved to $BACKUP_DIR
# (same relative path) so stow never hits a conflict and nothing is lost:
# files, and symlinked dirs pointing elsewhere (e.g. an old manual
# `ln -s ~/dotfiles/waybar ~/.config/waybar`). Real dirs are kept; stow links
# into them. Re-runs find only our symlinks and move nothing.
log "Symlinking configs into \$HOME with stow..."
mkdir -p "$HOME/.config"
backed_up=0
for pkg in "${STOW_PACKAGES[@]}"; do
    # find lists parents before children, so a moved dir symlink means its
    # children simply no longer exist when we reach them.
    while IFS= read -r -d '' src; do
        rel="${src#"$DOTFILES_DIR/$pkg/"}"
        target="$HOME/$rel"
        [[ -e "$target" || -L "$target" ]] || continue
        [[ "$(readlink -f "$target")" == "$src" ]] && continue
        [[ -d "$src" && -d "$target" && ! -L "$target" ]] && continue
        mkdir -p "$(dirname "$BACKUP_DIR/$rel")"
        mv "$target" "$BACKUP_DIR/$rel"
        backed_up=1
    done < <(find "$DOTFILES_DIR/$pkg" -mindepth 1 -print0)

    log "  stow: $pkg"
    stow -d "$DOTFILES_DIR" -t "$HOME" "$pkg"
done
if (( backed_up )); then
    warn "Existing configs were moved to $BACKUP_DIR"
fi

# Per-host monitor layout (see hypr/.config/hypr/monitors.lua)
host="$(cat /etc/hostname 2>/dev/null || uname -n)"
if [[ -f "$DOTFILES_DIR/hypr/.config/hypr/hosts/$host.lua" ]]; then
    log "Using monitor layout hosts/$host.lua"
else
    warn "No hosts/$host.lua: monitors will be auto-detected."
    warn "  For a custom layout, create hypr/.config/hypr/hosts/$host.lua (see hosts/laptop.lua)."
fi

# ---------------------------------------------------------------------------
# 4. Shell: zsh as login shell, nvm + Node LTS (Copilot, Mason servers)
# ---------------------------------------------------------------------------
if [[ "$(getent passwd "$USER" | cut -d: -f7)" != */zsh ]]; then
    log "Setting zsh as your login shell (takes effect next login)..."
    chsh -s /usr/bin/zsh "$USER" || warn "chsh failed, set it manually: chsh -s /usr/bin/zsh"
fi

if [[ ! -s "$HOME/.nvm/nvm.sh" ]]; then
    log "Installing nvm into ~/.nvm..."
    git clone --quiet https://github.com/nvm-sh/nvm.git "$HOME/.nvm"
    git -C "$HOME/.nvm" checkout --quiet "$(git -C "$HOME/.nvm" describe --abbrev=0 --tags --match 'v[0-9]*' "$(git -C "$HOME/.nvm" rev-list --tags --max-count=1)")"
fi
# nvm.sh isn't written for `set -u`
set +u
# shellcheck source=/dev/null
. "$HOME/.nvm/nvm.sh"
if [[ "$(nvm version 'lts/*')" == "N/A" ]]; then
    log "Installing Node LTS via nvm..."
    nvm install --lts
fi
set -u

# ---------------------------------------------------------------------------
# 5. Neovim: install plugins at the versions pinned in lazy-lock.json
# ---------------------------------------------------------------------------
log "Installing Neovim plugins (lazy.nvim restore)..."
nvim --headless "+Lazy! restore" +qa || warn "Plugin restore failed; open nvim and run :Lazy restore"

# ---------------------------------------------------------------------------
# 6. System-level: SDDM login screen + NetworkManager (needs sudo)
# ---------------------------------------------------------------------------
log "Installing SDDM theme (requires sudo)..."
"$DOTFILES_DIR/system/sddm/install_sddm.sh"

current_dm="$(readlink /etc/systemd/system/display-manager.service 2>/dev/null || true)"
if [[ "$current_dm" != */sddm.service ]]; then
    if [[ -n "$current_dm" ]]; then
        warn "Replacing display manager $(basename "$current_dm") with SDDM."
    fi
    sudo systemctl enable -f sddm.service
fi

if ! systemctl is-enabled --quiet NetworkManager.service 2>/dev/null; then
    log "Enabling NetworkManager..."
    sudo systemctl enable NetworkManager.service
fi

# ---------------------------------------------------------------------------
# Done
# ---------------------------------------------------------------------------
log "All done."
echo "  - Reboot (or log out) and pick Hyprland in SDDM."
echo "  - Re-run this script any time; it's safe to run repeatedly."
