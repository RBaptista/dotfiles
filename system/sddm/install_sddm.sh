#!/bin/bash
# install_sddm.sh

# 1. Create the system config directory
sudo mkdir -p /etc/sddm.conf.d

# 2. Copy the theme to the system directory
sudo cp -r ~/dotfiles/system/sddm/tokyo-night-sddm /usr/share/sddm/themes/

# 3. Copy the configuration file
sudo cp ~/dotfiles/system/sddm/theme.conf /etc/sddm.conf.d/theme.conf

# 4. Fix permissions so SDDM can read your cyan wallpaper
sudo chmod -R 755 /usr/share/sddm/themes/tokyo-night-sddm
