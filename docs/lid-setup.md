# Laptop Lid Close Setup

When the lid is closed with an external monitor connected, the internal screen (`eDP-1`)
turns off automatically. When the lid reopens, the internal screen comes back and
`autorandr` restores the saved display layout.

## How it works

1. `acpid` detects the lid open/close ACPI event
2. `/etc/acpi/lid.sh` reads the lid state and runs `xrandr` accordingly
3. `systemd-logind` is configured to **not suspend** on lid close — the script handles it

## Automatic setup

Run `install.sh` and answer **y** when asked about laptop lid close.

## Manual setup

### 1. Install and enable acpid

```bash
sudo pacman -S acpid autorandr
sudo systemctl enable --now acpid
```

### 2. Configure logind to ignore lid switch

Edit `/etc/systemd/logind.conf` and set:

```ini
HandleLidSwitch=ignore
HandleLidSwitchExternalPower=ignore
```

Then restart:

```bash
sudo systemctl restart systemd-logind
```

### 3. Create the lid handler script

Replace `your_user` with your actual username:

```bash
printf '#!/bin/bash\nUSER="your_user"\nUSER_DISPLAY=":0"\nXAUTHORITY="/home/your_user/.Xauthority"\nLID_STATE=$(cat /proc/acpi/button/lid/LID0/state 2>/dev/null || cat /proc/acpi/button/lid/LID/state 2>/dev/null)\nif echo "$LID_STATE" | grep -q "closed"; then\n    sudo -u $USER DISPLAY=$USER_DISPLAY XAUTHORITY=$XAUTHORITY xrandr --output eDP-1 --off\nelse\n    sudo -u $USER DISPLAY=$USER_DISPLAY XAUTHORITY=$XAUTHORITY xrandr --output eDP-1 --auto\n    sudo -u $USER DISPLAY=$USER_DISPLAY XAUTHORITY=$XAUTHORITY autorandr --change\nfi\n' | sudo tee /etc/acpi/lid.sh
sudo chmod +x /etc/acpi/lid.sh
```

### 4. Hook into acpid's event handler

Edit `/etc/acpi/handler.sh` and add the call to `lid.sh` inside the `button/lid` section:

```bash
button/lid)
    case "$3" in
        close)
            logger 'LID closed'
            /etc/acpi/lid.sh   # <-- add this
            ;;
        open)
            logger 'LID opened'
            /etc/acpi/lid.sh   # <-- add this
            ;;
    esac
    ;;
```

Then restart acpid:

```bash
sudo systemctl restart acpid
```

## Saving display profiles with autorandr

After setting up your monitors the way you want them, save the profile:

```bash
# With both screens active (lid open)
autorandr --save dual --force

# With only external screen (lid closed)
xrandr --output eDP-1 --off
autorandr --save docked --force
xrandr --output eDP-1 --auto  # restore
```

`autorandr --change` (called by `lid.sh` on lid open) will auto-detect and apply
the right profile.
