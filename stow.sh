# ----------------------------
#  Apply dotfiles using stow
# ----------------------------
# stow -d ~/Projects/myhyprland-rice/ -t ~/ dotfiles
PROJECTS_DIR="$HOME/Projects"
RICE_DIR="$PROJECTS_DIR/myhyprland-rice"
mkdir -p "$PROJECTS_DIR"

if [ -d "$RICE_DIR/dotfiles" ]; then
    info "Creating symlinks with stow..."
    stow -d "$RICE_DIR" -t "$HOME" dotfiles || warn "Some links may already exist."
else
    warn "No dotfiles directory found, skipping stow."
fi