#!/bin/bash
set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CURRENT_USER="${USER:-$(whoami)}"

command -v stow >/dev/null 2>&1 || { echo "stow not found. Install it first: sudo pacman -S stow"; exit 1; }

if ! command -v yay >/dev/null 2>&1; then
  echo "Installing yay..."
  sudo pacman -S --needed git base-devel
  git clone https://aur.archlinux.org/yay.git /tmp/yay-install
  cd /tmp/yay-install && makepkg -si --noconfirm
  cd "$DOTFILES_DIR"
fi

echo "Applying pacman config (Color, ILoveCandy, VerbosePkgLists)..."
sudo cp "$DOTFILES_DIR/packages/pacman.conf" /etc/pacman.conf

echo "Installing packages..."
sudo pacman -S --needed - < "$DOTFILES_DIR/packages/pkglist.txt"
yay -S --needed - < "$DOTFILES_DIR/packages/aur_pkglist.txt"

if [ ! -d "$HOME/.oh-my-zsh" ]; then
  echo "Installing oh-my-zsh..."
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

mkdir -p "$HOME/.oh-my-zsh/custom/plugins"
ln -sf /usr/share/zsh/plugins/zsh-syntax-highlighting "$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting"
ln -sf /usr/share/zsh/plugins/zsh-autosuggestions "$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions"

echo "Backing up conflicting dotfiles..."
BACKUP_STAMP=$(date +%Y%m%d_%H%M%S)
for f in "$HOME/.zshrc" "$HOME/.config/i3/config"; do
  if [ -e "$f" ] && [ ! -L "$f" ]; then
    mv -v "$f" "${f}.bak_${BACKUP_STAMP}"
  fi
done

echo "Stowing dotfiles..."
cd "$DOTFILES_DIR"
stow i3 kitty polybar picom dunst rofi fontconfig betterlockscreen zsh gtk wallpaper autostart brave nvim

echo "Deploying Firefox user.js to all profiles..."
FIREFOX_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/mozilla/firefox"
if [ -f "$DOTFILES_DIR/firefox/user.js" ] && [ -d "$FIREFOX_DIR" ]; then
  while IFS= read -r profile_dir; do
    cp -v "$DOTFILES_DIR/firefox/user.js" "$profile_dir/user.js"
  done < <(find "$FIREFOX_DIR" -maxdepth 1 -mindepth 1 -type d ! -name "Crash Reports" ! -name "Pending Pings" ! -name "Profile Groups")
else
  echo "No Firefox profiles found, skipping."
fi

echo ""
echo "=== Weather module ==="
read -rp "Enter your latitude: " WEATHER_LAT
read -rp "Enter your longitude: " WEATHER_LON
mkdir -p "$HOME/.config/polybar"
printf "WEATHER_LAT=%s\nWEATHER_LON=%s\n" "$WEATHER_LAT" "$WEATHER_LON" > "$HOME/.config/polybar/weather.conf"
echo "Weather config saved to ~/.config/polybar/weather.conf"

echo ""
echo "=== WireGuard / polybar VPN module ==="
echo "The polybar VPN module runs 'sudo wg' every 5 seconds without a terminal."
echo "Without a NOPASSWD rule, pam_faillock will lock your account after ~50 failed"
echo "attempts, breaking ALL sudo commands (including sudo pacman)."
read -rp "Set up passwordless sudo for WireGuard commands? [Y/n] " wg_choice
if [[ ! "$wg_choice" =~ ^[Nn]$ ]]; then
  printf '%s ALL=(ALL) NOPASSWD: /usr/bin/wg show interfaces\n%s ALL=(ALL) NOPASSWD: /usr/bin/wg-quick up *\n%s ALL=(ALL) NOPASSWD: /usr/bin/wg-quick down *\n%s ALL=(ALL) NOPASSWD: /usr/bin/find /etc/wireguard -name *.conf\n' \
    "$CURRENT_USER" "$CURRENT_USER" "$CURRENT_USER" "$CURRENT_USER" \
    | sudo tee /etc/sudoers.d/polybar-wireguard > /dev/null
  sudo chmod 440 /etc/sudoers.d/polybar-wireguard
  if sudo visudo -c -f /etc/sudoers.d/polybar-wireguard > /dev/null 2>&1; then
    echo "Sudoers rule created OK. See docs/vpn-setup.md to add VPN profiles."
  else
    echo "ERROR: sudoers syntax check failed. Removing file to be safe."
    sudo rm /etc/sudoers.d/polybar-wireguard
  fi
fi

echo ""
echo "=== Laptop lid close ==="
read -rp "Laptop with external display? Turn off internal screen on lid close? [y/N] " lid_choice
if [[ "$lid_choice" =~ ^[Yy]$ ]]; then
  sudo pacman -S --needed acpid autorandr
  sudo systemctl enable --now acpid

  sudo sed -i 's/#HandleLidSwitch=suspend/HandleLidSwitch=ignore/' /etc/systemd/logind.conf
  sudo sed -i 's/#HandleLidSwitchExternalPower=suspend/HandleLidSwitchExternalPower=ignore/' /etc/systemd/logind.conf
  sudo systemctl restart systemd-logind

  printf '#!/bin/bash\nUSER="%s"\nUSER_DISPLAY=":0"\nXAUTHORITY="/home/%s/.Xauthority"\nLID_STATE=$(cat /proc/acpi/button/lid/LID0/state 2>/dev/null || cat /proc/acpi/button/lid/LID/state 2>/dev/null)\nif echo "$LID_STATE" | grep -q "closed"; then\n    sudo -u $USER DISPLAY=$USER_DISPLAY XAUTHORITY=$XAUTHORITY xrandr --output eDP-1 --off\nelse\n    sudo -u $USER DISPLAY=$USER_DISPLAY XAUTHORITY=$XAUTHORITY xrandr --output eDP-1 --auto\n    sudo -u $USER DISPLAY=$USER_DISPLAY XAUTHORITY=$XAUTHORITY autorandr --change\nfi\n' \
    "$CURRENT_USER" "$CURRENT_USER" | sudo tee /etc/acpi/lid.sh > /dev/null
  sudo chmod +x /etc/acpi/lid.sh

  if ! grep -q "lid.sh" /etc/acpi/handler.sh; then
    sudo sed -i "/logger 'LID closed'/a\\                /etc/acpi/lid.sh" /etc/acpi/handler.sh
    sudo sed -i "/logger 'LID opened'/a\\                /etc/acpi/lid.sh" /etc/acpi/handler.sh
  fi

  sudo systemctl restart acpid
  echo "Lid close configured. See docs/lid-setup.md for details."
fi

echo ""
echo "Done. Review these machine-specific settings:"
echo "  - Monitor name in polybar : polybar/.config/polybar/config.ini (monitor = HDMI-1)"
echo "  - Monitor name in i3      : i3/.config/i3/config (xrandr line near the bottom)"
echo ""
echo "Optional hardware packages:"
echo "  NVIDIA : sudo pacman -S --needed - < packages/pkglist_nvidia.txt"
echo "  AMD CPU: sudo pacman -S --needed - < packages/pkglist_amd.txt"
echo "  Btrfs  : sudo pacman -S --needed - < packages/pkglist_btrfs.txt"
echo "  Razer  : yay -S --needed - < packages/aur_pkglist_razer.txt"
