Zaral's Dotfiles

A professional, performance-oriented workstation environment built on Arch Linux. This repository serves as my personal and professional development setup.
🎨 Aesthetic Profile

    Theme: Tokyo Night (Modified).

    Primary Color: Cyan (#00FFFF).

    Window Manager: Hyprland (Tiling).

    Status Bar: Waybar (Custom JSONC/CSS).

🛠 Tech Stack & Hardware

    Distro: Arch Linux.

    Shell: Alacritty / Kitty with JetBrainsMono Nerd Font.

    Timezone: Atlantic/Cape_Verde (CVT).

📁 Repository Structure
```text
.
├── hypr/               # Hyprland window manager settings
├── waybar/             # Status bar config and styling
├── wlogout/            # Custom logout menu with cyan highlights
├── system/             # System-level configs
│   └── sddm/           # Tokyo Night SDDM theme & custom config
└── install.sh          # Deployment script for symlinks
```

🚀 Installation
1. Clone the Repository

This repo uses Git Submodules for the SDDM theme, so use the recursive flag:
```Bash
git clone --recursive git@github.com:YOUR_USERNAME/dotfiles.git ~/dotfiles
```
2. Deploy User Configs

Use GNU Stow or the manual symlink method for your user-level configurations:
```Bash

ln -s /home/$USER/dotfiles/waybar /home/$USER/.config/waybar
ln -s /home/$USER/dotfiles/hypr /home/$USER/.config/hypr
```
3. Deploy System SDDM Theme

Run the included deployment script to set up the login screen:
```Bash

chmod +x ~/dotfiles/system/sddm/install_sddm.sh
./~/dotfiles/system/sddm/install_sddm.sh
```

Maintained by RBaptista.
