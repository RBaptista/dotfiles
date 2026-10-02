### Zaral's Dotfiles

A professional, performance-oriented workstation environment built on Arch Linux. This repository serves as my personal and professional development setup: clone it on any Arch-based machine (Arch, CachyOS), run `./install.sh`, and everything is installed and configured.
🎨 Aesthetic Profile

    Theme: Tokyo Night (Modified).

    Primary Color: Cyan (#00FFFF).

    Window Manager: Hyprland (Tiling, Lua config, 0.55+).

    Status Bar: Waybar (Custom JSONC/CSS).

    Login Screen: SDDM with a vendored Tokyo Night theme.

🛠 Tech Stack & Hardware

    Distro: Arch Linux / CachyOS.

    Terminal: Alacritty with JetBrainsMono Nerd Font.

    Shell: zsh with Powerlevel10k (CachyOS zsh config).

    Editor: Neovim (LazyVim) + lazygit.

    Timezone: Atlantic/Cape_Verde (CVT).

📁 Repository Structure

Each config folder is a GNU Stow package that mirrors `$HOME`, so the real files live at `<pkg>/.config/<pkg>/` (or at the package root for `zsh/`).

```text
.
├── hypr/               # Hyprland (Lua), hypridle, hyprlock, hyprpaper
│   └── .config/hypr/hosts/   # Per-machine monitor layouts (<hostname>.lua)
├── waybar/             # Status bar config and styling
├── rofi/               # App launcher
├── alacritty/          # Terminal
├── wlogout/            # Custom logout menu with cyan highlights
├── yazi/               # File manager theme
├── nvim/               # LazyVim config (plugins pinned in lazy-lock.json)
├── zsh/                # .zshrc and .p10k.zsh
├── cyan_wall/          # Wallpapers (referenced by path, not stowed)
├── system/sddm/        # Tokyo Night SDDM theme & config (copied with sudo)
├── packages.txt        # Packages installed by install.sh (via yay)
└── install.sh          # One-shot setup script
```

🚀 Installation

1. Clone the Repository

The repo must live at `~/dotfiles`: the wallpaper paths are hardcoded to it.

```Bash
git clone https://github.com/RBaptista/dotfiles.git ~/dotfiles
cd ~/dotfiles
```

1. Run the Installer

Run it as your normal user (it uses sudo when it needs to):

```Bash
./install.sh
```

It will:

- install `yay` if needed, then everything in `packages.txt` (plus the zsh prompt packages for your distro);
- symlink every config with Stow (anything already in the way is moved to `~/.dotfiles-backup/<timestamp>/`, nothing is deleted);
- set zsh as your login shell and install nvm + Node LTS;
- install the Neovim plugins at the versions in `lazy-lock.json`;
- install the SDDM theme, make SDDM your display manager (replacing any other one), and enable NetworkManager.

It's safe to run again. Reboot afterwards and pick Hyprland in SDDM.

1. Monitors on a New Machine

Monitors are auto-detected by default. For a custom layout (resolution, scale, which workspaces go on which screen), add `hypr/.config/hypr/hosts/<hostname>.lua`, using `hosts/laptop.lua` as a template. The installer tells you whether a host file was found.

1. Deploying Individual Pieces

Symlink a single config:

```Bash
stow -d ~/dotfiles -t ~ waybar
```

Re-apply the SDDM theme after editing anything in `system/sddm/`:

```Bash
./system/sddm/install_sddm.sh
```

Maintained by RBaptista.
