#!/usr/bin/env bash
#
# install.sh — one-shot setup for RBaptista/dotfiles
#
# Run this from inside the cloned repo:
#   git clone --recursive https://github.com/RBaptista/dotfiles.git ~/dotfiles
#   cd ~/dotfiles
#   ./install.sh
#
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STOW_PACKAGES=(hypr waybar rofi alacritty wlogout yazi starship)

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
# 1. Submodules (SDDM theme)
# ---------------------------------------------------------------------------
log "Fetching submodules (SDDM theme)..."
git -C "$DOTFILES_DIR" submodule update --init --recursive

# ---------------------------------------------------------------------------
# 2. yay (AUR helper)
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
# 3. Packages
# ---------------------------------------------------------------------------
log "Installing packages from packages.txt..."
mapfile -t PKGS < <(grep -vE '^\s*(#|$)' "$DOTFILES_DIR/packages.txt")
yay -S --needed --noconfirm "${PKGS[@]}"

# ---------------------------------------------------------------------------
# 4. Symlink dotfiles with GNU Stow
# ---------------------------------------------------------------------------
log "Symlinking configs into \$HOME with stow..."
mkdir -p "$HOME/.config"
for pkg in "${STOW_PACKAGES[@]}"; do
    log "  stow: $pkg"
    # --adopt pulls any pre-existing real file into the repo instead of
    # failing on conflict, then we discard that change so the repo's
    # version always wins. Safe for a fresh machine; on a machine with
    # existing configs it backs nothing up, so back up ~/.config yourself
    # first if it's not empty.
    stow --adopt -d "$DOTFILES_DIR" -t "$HOME" "$pkg"
    git -C "$DOTFILES_DIR" checkout -- "$pkg" 2>/dev/null || true
done

# ---------------------------------------------------------------------------
# 5. zsh: default shell, yazi cwd-on-exit function, starship prompt, ls colors
# ---------------------------------------------------------------------------
if [[ "$SHELL" != *"/zsh" ]]; then
    log "Setting zsh as your login shell (takes effect next login)..."
    chsh -s /usr/bin/zsh "$USER" || warn "chsh failed, set it manually: chsh -s /usr/bin/zsh"
fi

MARKER="# >>> dotfiles: yazi cwd function >>>"
if ! grep -qF "$MARKER" "$HOME/.zshrc" 2>/dev/null; then
    log "Adding yazi 'y' function to ~/.zshrc..."
    {
        echo ""
        echo "$MARKER"
        tail -n +2 "$DOTFILES_DIR/yazi_bash"   # skip the "in ~/.zshrc" comment line
        echo "# <<< dotfiles: yazi cwd function <<<"
    } >> "$HOME/.zshrc"
else
    log "yazi 'y' function already in ~/.zshrc, skipping."
fi

if ! grep -qF 'starship init zsh' "$HOME/.zshrc" 2>/dev/null; then
    log "Adding starship init to ~/.zshrc..."
    echo 'eval "$(starship init zsh)"' >> "$HOME/.zshrc"
else
    log "starship init already in ~/.zshrc, skipping."
fi

LS_MARKER="# >>> dotfiles: ls colors >>>"
if ! grep -qF "$LS_MARKER" "$HOME/.zshrc" 2>/dev/null; then
    log "Adding ls colors to ~/.zshrc..."
    {
        echo ""
        echo "$LS_MARKER"
        echo "alias ls='ls --color=auto'"
        echo 'export LS_COLORS="di=1;36:ln=1;35:ex=1;32:*.tar=1;31:*.zip=1;31"'
        echo "# <<< dotfiles: ls colors <<<"
    } >> "$HOME/.zshrc"
else
    log "ls colors already in ~/.zshrc, skipping."
fi

# ---------------------------------------------------------------------------
# 6. System-level: SDDM theme (needs sudo)
# ---------------------------------------------------------------------------
log "Installing SDDM theme (requires sudo)..."
chmod +x "$DOTFILES_DIR/system/sddm/install_sddm.sh"
"$DOTFILES_DIR/system/sddm/install_sddm.sh"

# ---------------------------------------------------------------------------
# Done
# ---------------------------------------------------------------------------
log "All done."
echo "  - Log out and back into Hyprland (or reboot) to pick everything up."
echo "  - SDDM theme takes effect on next login screen / reboot."
echo "  - Re-run this script any time; it's safe to run repeatedly."
