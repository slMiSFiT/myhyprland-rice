#!/usr/bin/env bash


set -euo pipefail  # Exit on error, unset variable, or failed pipe

# ----------------------------
#  Functions
# ----------------------------
info() { echo -e "\e[34m>>> $1\e[0m"; }
warn() { echo -e "\e[33m>> $1\e[0m"; }
suggested() { echo -e "\e[32m> $1\e[0m"; }
error() { echo -e "\e[31m $1\e[0m"; exit 1; }

----------------------
#  1. Update system
# ----------------------------
info "Updating system..."
sudo pacman -Syu --noconfirm

# ----------------------------
#  2. Install base packages
# ----------------------------
info "Installing base packages..."
sudo pacman -S --needed --noconfirm\
    git base-devel curl wget neovim zsh unzip stow reflector

# ----------------------------
#  3. Update the mirrorlist
# ----------------------------
info "Updating mirrorlist..."
sudo reflector --country Morocco,Germany --protocol https --age 12 --latest 5 --sort rate --save /etc/pacman.d/mirrorlist

# ----------------------------
#  4. Install paru (AUR helper)
# ----------------------------
if ! command -v paru &> /dev/null; then
    info "Installing paru (AUR helper)..."
    git clone https://aur.archlinux.org/paru.git /tmp/paru
    cd /tmp/paru
    makepkg -si --noconfirm
    cd -
    rm -rf /tmp/paru
else
    info "paru is already installed, skipping..."
fi

# ----------------------------
#  5. Clone HyprArch dotfiles repo
# ----------------------------
PROJECTS_DIR="$HOME/Projects"
RICE_DIR="$PROJECTS_DIR/myhyprland-rice"
REPO_URL="https://github.com/slMiSFiT/myhyprland-rice.git"

mkdir -p "$PROJECTS_DIR"

if [ -d "$RICE_DIR" ]; then
    warn "myhyprland-rice already exists, skipping."
else
    info "Cloning Hyprland rice repository..."
    git clone "$REPO_URL" "$RICE_DIR"
fi

# ----------------------------
#  6. Install packages from pkglist
# ----------------------------

if [ -f "$RICE_DIR/pkglist.txt" ]; then
    info "Installing packages from pkglist.txt..."
    sudo paru -S --needed - < "$RICE_DIR/pkglist.txt"
else
    warn "No pkglist.txt found, skipping."
fi

# ----------------------------
#  8. Set zsh the default shell
# ----------------------------
info "Setting zsh as default shell..."
if [ "$(basename "$SHELL")" != "zsh" ]; then
    chsh -s "$(which zsh)"
else
    warn "zsh is already default..."
fi

# ----------------------------
#  3. create symlinks using stow.sh 
# ----------------------------
info "copying dotfiles..."
sudo "$RICE_DIR/setup.sh"

# ----------------------------
#  3. sddm theme 
# ----------------------------
sh -c "$(curl -fsSL https://raw.githubusercontent.com/keyitdev/sddm-astronaut-theme/master/setup.sh)"
# source: https://github.com/Keyitdev/sddm-astronaut-theme


# ----------------------------
#  9. Enable and start essential services
# ----------------------------
info "Enabling essential services..."
sudo systemctl enable NetworkManager
sudo systemctl enable ufw
sudo systemctl enable sddm
sudo systemctl disable bleutooth

# add other services (paccache,...)"


# ----------------------------
# Done
# ----------------------------
info "Setup complete! Reboot required."
