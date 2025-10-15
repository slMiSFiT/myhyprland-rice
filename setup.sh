#!/usr/bin/env bash


set -euo pipefail  # Exit on error, unset variable, or failed pipe

# ----------------------------
#  Functions
# ----------------------------
info() { echo -e "\e[34m>>> $1\e[0m"; }
warn() { echo -e "\e[33m>> $1\e[0m"; }
needed() { echo -e "\e[32m> $1\e[0m"; }
error() { echo -e "\e[31m $1\e[0m"; exit 1; }

# ----------------------------
#  0. Configure pacman
# ----------------------------
info "Configuring pacman..."

PACMAN_CONF="/etc/pacman.conf"
# Enable some Misc options
sudo sed -i \
    -e 's/^#Color/Color/' \
    -e 's/^#CheckSpace/CheckSpace/' \
    -e 's/^#ParallelDownloads.*/ParallelDownloads = 5/' \
    -e 's/^#DownloadUser.*/DownloadUser = alpm/' \
    "$PACMAN_CONF"
# Add ILoveCandy if not present
if ! grep -q '^ILoveCandy' "$PACMAN_CONF"; then
    sudo sed -i '/Color/a ILoveCandy' "$PACMAN_CONF"
fi
# Enable multilib if not already
if ! grep -q '^\[multilib\]' /etc/pacman.conf; then
    sudo sed -i '/#\[multilib\]/s/^#//' /etc/pacman.conf         # Uncomment [multilib] line
    sudo sed -i '/#Include = \/etc\/pacman.d\/mirrorlist/s/^#//' /etc/pacman.conf  # Uncomment the Include line below it
fi

# ----------------------------
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
#info "Updating mirrorlist..."
#sudo reflector --country Morocco,Germany --protocol https --age 12 --latest 5 --sort rate --save /etc/pacman.d/mirrorlist

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
#  7. Apply dotfiles using stow
# ----------------------------
if [ -d "$RICE_DIR/dotfiles" ]; then
    info "Creating symlinks with stow..."
    stow -d "$RICE_DIR" -t "$HOME" dotfiles || warn "Some links may already exist."
else
    warn "No dotfiles directory found, skipping stow."
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
#  9. Enable and start essential services
# ----------------------------
info "Enabling essential services..."
sudo systemctl enable --now NetworkManager
sudo systemctl enable --now reflector.service
# needed "configure /etc/xdg/reflector/reflector.conf"
# add other services (sddm,paccache,...)"

# ----------------------------
# Done
# ----------------------------
info "Setup complete! fulfill the needed configs (>) and Reboot your system to start using it."
