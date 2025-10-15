# ----------------------------
#  Apply dotfiles using stow
# ----------------------------
# stow -d ~/Projects/myhyprland-rice/ -t ~/ dotfiles
PROJECTS_DIR="$HOME/Projects"
RICE_DIR="$PROJECTS_DIR/myhyprland-rice"
mkdir -p "$PROJECTS_DIR"

echo ">>> Creating symlinks with stow..."
stow -d "$RICE_DIR" -t "$HOME" dotfiles || echo ">>> Some links may already exist."
