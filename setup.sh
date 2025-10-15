#!/usr/bin/env bash

# ============================
#  Arch Linux Rebuild Script
# ============================

set -e  # Exit immediately on error

echo ">>> Updating system..."
sudo pacman -Syu --noconfirm

# ----------------------------
#  1. Install base packages
# ----------------------------
echo ">>> Installing base packages..."
sudo pacman -S --needed --noconfirm \
    git base-devel curl wget neovim zsh htop unzip stow

# ----------------------------
#  2. Restore package list
# ----------------------------
if [ -f pkglist.txt ]; then
    echo ">>> Installing packages from pkglist.txt..."
    sudo pacman -S --needed - < pkglist.txt
else
    echo ">>> No pkglist.txt found, skipping."
fi

# ----------------------------
#  3. Install paru (AUR helper)
# ----------------------------
if ! command -v paru &> /dev/null; then
    echo ">>> Installing paru (AUR helper)..."
    git clone https://aur.archlinux.org/paru.git /tmp/paru
    cd /tmp/paru
    makepkg -si --noconfirm
    cd -
fi

# ----------------------------
#  4. Restore AUR packages
# ----------------------------
if [ -f aurlist.txt ]; then
    echo ">>> Installing AUR packages from aurlist.txt..."
    paru -S --needed - < aurlist.txt
else
    echo ">>> No aurlist.txt found, skipping."
fi

# ----------------------------
#  5. Clone Hyprland rice repo
# ----------------------------
PROJECTS_DIR="$HOME/Projects"
RICE_DIR="$PROJECTS_DIR/myhyprland-rice"
REPO_URL="https://github.com/slMiSFiT/myhyprland-rice.git"

mkdir -p "$PROJECTS_DIR"

if [ -d "$RICE_DIR" ]; then
    echo ">>> myhyprland-rice already exists, pulling latest changes..."
    git -C "$RICE_DIR" pull
else
    echo ">>> Cloning Hyprland rice repository..."
    git clone "$REPO_URL" "$RICE_DIR"
fi

# ----------------------------
#  6. Apply dotfiles using stow
# ----------------------------
echo ">>> Creating symlinks with stow..."
stow -d "$RICE_DIR" -t "$HOME" /dotfiles || echo ">>> Some links may already exist."

# ----------------------------
#  7. Final touches
# ----------------------------
echo ">>> Setting zsh as default shell..."
su
chsh -s "$(which zsh)"
exit

echo ">>> Setup complete! Log out and back in to enjoy your Hyprland rice."
