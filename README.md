# Dotfiles

Arch Linux · i3 · kitty · polybar · picom · dunst · rofi · yazi

## Stack

| Component | Tool |
|:----------|:-----|
| WM | i3-gaps |
| Terminal | kitty |
| Bar | polybar |
| Compositor | picom |
| Notifications | dunst |
| Launcher | rofi |
| File manager | yazi / thunar |
| Shell | zsh + oh-my-zsh |
| Theme | Tokyo Night |
| Font | JetBrainsMono Nerd Font |

## Install

```bash
git clone <repo-url> ~/Dotfiles
cd ~/Dotfiles
chmod +x install.sh
./install.sh
```

The install script:
1. Installs `yay` (AUR helper) if not already present
2. Installs all packages from `packages/pkglist.txt` (official) and `packages/aur_pkglist.txt` (AUR)
3. Installs `oh-my-zsh` if not already present
4. Creates symlinks for all configs via GNU Stow

### Optional hardware packages

Install only what applies to your machine:

```bash
# NVIDIA GPU
sudo pacman -S --needed - < packages/pkglist_nvidia.txt

# AMD CPU microcode
sudo pacman -S --needed - < packages/pkglist_amd.txt

# Btrfs filesystem (snapshots with snapper)
sudo pacman -S --needed - < packages/pkglist_btrfs.txt

# Razer peripherals (OpenRazer + Polychromatic)
yay -S --needed - < packages/aur_pkglist_razer.txt
```

## Machine-specific configuration

After running `install.sh`, adjust these two files to match your hardware:

### Monitor (i3)

Edit `~/.config/i3/config`, last line:

```
exec_always --no-startup-id xrandr --output HDMI-0 --mode 1920x1080 --rate 180.00
```

Replace `HDMI-0` with your actual output name (`xrandr` lists them), and set
your resolution and refresh rate accordingly.

### Monitor (polybar)

Edit `~/.config/polybar/config.ini`:

```ini
[bar/top]
monitor = HDMI-0   # replace with your output name
```

### Intel integrated GPU (picom)

The default picom config uses `backend = "glx"` with `dual_kawase` blur. On Intel iGPU this
usually works fine via the `i915` driver, but if you see tearing or crashes, try switching to
the EGL backend (keeps blur):

```
backend = "egl";
```

If problems persist, fall back to `xrender` — note that `dual_kawase` blur is not supported
with `xrender`, so you must also remove the blur block:

```
backend = "xrender";
# remove blur-background, blur-method, blur-strength lines
```

### Weather location

Create `~/.config/polybar/weather.conf` with your coordinates:

```bash
WEATHER_LAT=40.4165
WEATHER_LON=-3.7026
```

If the file does not exist, the polybar weather module defaults to Madrid.
Coordinates can be found at [open-meteo.com](https://open-meteo.com).

## Guides

- [VPN setup (WireGuard + polybar module)](docs/vpn-setup.md)

## Structure

```
Dotfiles/
├── i3/               → ~/.config/i3/
├── kitty/            → ~/.config/kitty/
├── polybar/          → ~/.config/polybar/
├── picom/            → ~/.config/picom/
├── dunst/            → ~/.config/dunst/
├── rofi/             → ~/.config/rofi/
├── fontconfig/       → ~/.config/fontconfig/
├── betterlockscreen/ → ~/.config/betterlockscreen/
├── zsh/              → ~/.zshrc
├── packages/
│   ├── pkglist.txt           ← official packages (base)
│   ├── aur_pkglist.txt       ← AUR packages (base)
│   ├── pkglist_nvidia.txt    ← optional: NVIDIA GPU
│   ├── pkglist_amd.txt       ← optional: AMD CPU microcode
│   ├── pkglist_btrfs.txt     ← optional: Btrfs + snapper
│   └── aur_pkglist_razer.txt ← optional: Razer peripherals
├── install.sh
└── README.md
```

## Adding a new config

```bash
mkdir -p ~/Dotfiles/<name>/.config/<name>
mv ~/.config/<name>/* ~/Dotfiles/<name>/.config/<name>/
cd ~/Dotfiles && stow <name>
```

## Updating package lists

```bash
pacman -Qqen > ~/Dotfiles/packages/pkglist.txt
pacman -Qqem > ~/Dotfiles/packages/aur_pkglist.txt
```
