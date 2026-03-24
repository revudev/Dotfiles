# VPN Setup (WireGuard + polybar module)

The polybar VPN module shows connection status and opens a rofi menu on click to
connect/disconnect any WireGuard profile stored in `/etc/wireguard/`.

## Requirements

Packages (already in `pkglist.txt`):
- `wireguard-tools` — provides `wg` and `wg-quick`
- `systemd-resolvconf` — bridges wg-quick DNS with systemd-resolved

## 1. Enable systemd-resolved

```bash
sudo systemctl enable --now systemd-resolved
sudo ln -sf /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf
```

## 2. Configure NetworkManager to use systemd-resolved

Edit `/etc/NetworkManager/NetworkManager.conf`:

```ini
[main]
dns=systemd-resolved
```

Restart NetworkManager:

```bash
sudo systemctl restart NetworkManager
```

## 3. Configure passwordless sudo for WireGuard

> **Important:** The polybar VPN module runs `sudo wg show interfaces` every 5 seconds
> without a terminal. Without this rule, PAM will log a failed auth attempt each time,
> and after ~50 failures `pam_faillock` will lock your account — breaking **all** sudo
> commands. The `install.sh` script sets this up automatically.

Create `/etc/sudoers.d/polybar-wireguard` with the following (replace `your_user`):

```bash
printf 'your_user ALL=(ALL) NOPASSWD: /usr/bin/wg show interfaces\nyour_user ALL=(ALL) NOPASSWD: /usr/bin/wg-quick up *\nyour_user ALL=(ALL) NOPASSWD: /usr/bin/wg-quick down *\nyour_user ALL=(ALL) NOPASSWD: /usr/bin/find /etc/wireguard -name *.conf\n' | sudo tee /etc/sudoers.d/polybar-wireguard
sudo chmod 440 /etc/sudoers.d/polybar-wireguard
sudo visudo -c -f /etc/sudoers.d/polybar-wireguard
```

If your account gets locked before you set this up, unlock it with:

```bash
sudo faillock --user your_user --reset
```

## 4. Add VPN profiles

Copy your `.conf` files to `/etc/wireguard/` with restricted permissions:

```bash
sudo cp my-vpn.conf /etc/wireguard/
sudo chmod 600 /etc/wireguard/my-vpn.conf
```

Any `.conf` added here will automatically appear in the polybar rofi menu — no
further configuration needed.

## 5. Troubleshoot: resolv.conf signature mismatch

If `wg-quick up` fails with `resolvconf: signature mismatch`:

```bash
sudo rm /etc/resolv.conf
sudo ln -sf /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf
```
