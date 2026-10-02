#!/usr/bin/env bash
# install_sddm.sh — copy the vendored Tokyo Night theme and its config into place.
# SDDM reads from system dirs, so these are copies (re-run after editing).
set -euo pipefail

SDDM_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 1. Create the system config directory
sudo mkdir -p /etc/sddm.conf.d /usr/share/sddm/themes

# 2. Copy the theme to the system directory (replace any older copy)
sudo rm -rf /usr/share/sddm/themes/tokyo-night-sddm
sudo cp -r "$SDDM_DIR/tokyo-night-sddm" /usr/share/sddm/themes/

# 3. Copy the configuration file
sudo cp "$SDDM_DIR/theme.conf" /etc/sddm.conf.d/theme.conf

# 4. Fix permissions so SDDM can read the theme and wallpaper
sudo chmod -R 755 /usr/share/sddm/themes/tokyo-night-sddm
