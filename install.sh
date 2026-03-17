#!/bin/bash
set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

command -v stow >/dev/null 2>&1 || { echo "stow not found. Install it first: sudo pacman -S stow"; exit 1; }

if ! command -v yay >/dev/null 2>&1; then
  echo "Installing yay..."
  sudo pacman -S --needed git base-devel
  git clone https://aur.archlinux.org/yay.git /tmp/yay-install
  cd /tmp/yay-install && makepkg -si --noconfirm
  cd "$DOTFILES_DIR"
fi

echo "Installing packages..."
sudo pacman -S --needed - < "$DOTFILES_DIR/packages/pkglist.txt"
yay -S --needed - < "$DOTFILES_DIR/packages/aur_pkglist.txt"

if [ ! -d "$HOME/.oh-my-zsh" ]; then
  echo "Installing oh-my-zsh..."
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

echo "Stowing dotfiles..."
cd "$DOTFILES_DIR"
stow i3 kitty polybar picom dunst rofi fontconfig betterlockscreen zsh

echo ""
echo "Done. Review these machine-specific settings before logging into i3:"
echo "  - Monitor output name and resolution: i3/.config/i3/config (last line)"
echo "  - Polybar monitor: polybar/.config/polybar/config.ini (monitor = HDMI-0)"
echo "  - Weather location: polybar/.config/polybar/weather.conf (auto-created on first run)"
echo ""
echo "Optional hardware packages:"
echo "  NVIDIA : sudo pacman -S --needed - < packages/pkglist_nvidia.txt"
echo "  AMD CPU: sudo pacman -S --needed - < packages/pkglist_amd.txt"
echo "  Btrfs  : sudo pacman -S --needed - < packages/pkglist_btrfs.txt"
echo "  Razer  : yay -S --needed - < packages/aur_pkglist_razer.txt"
