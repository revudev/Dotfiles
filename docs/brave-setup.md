# Brave — GPU optimization (Xorg / i3)

## Flags (`~/.config/brave-flags.conf`)

The dotfile at `brave/.config/brave-flags.conf` is tuned for **Intel integrated graphics**.  
For AMD, see the section below.

### Intel (default)

Required packages:
```bash
sudo pacman -S intel-media-driver libva-utils
```

Verify VAAPI is working:
```bash
vainfo
```

Flags used (already in the dotfile):
```
--enable-features=VaapiVideoDecodeLinuxGL,VaapiVideoEncoder,WebRTCPipeWireCapturer
--use-gl=angle
--use-angle=gl
--enable-gpu-rasterization
--enable-zero-copy
--ignore-gpu-blocklist
--ozone-platform=x11
```

### AMD

Required packages:
```bash
sudo pacman -S libva-mesa-driver mesa-vdpau libva-utils
```

Replace `~/.config/brave-flags.conf` with:
```
--enable-features=VaapiVideoDecodeLinuxGL,VaapiVideoEncoder,WebRTCPipeWireCapturer
--use-gl=angle
--use-angle=vulkan
--enable-gpu-rasterization
--enable-zero-copy
--ignore-gpu-blocklist
--ozone-platform=x11
```

The only difference is `--use-angle=vulkan` instead of `--use-angle=gl` — AMD performs better through Vulkan/RADV.

## Brave flags (in-browser)

Open `brave://flags` and enable:
- `Override software rendering list` → Enabled
- `GPU rasterization` → Enabled
- `Zero-copy rasterizer` → Enabled
- `Hardware-accelerated video decode` → Enabled

## Verify hardware acceleration

Open `brave://gpu` — **Video Decode** and **Rasterization** must say `Hardware accelerated`.

## Profile in RAM (optional, big speedup)

Install `profile-sync-daemon` from AUR:
```bash
yay -S profile-sync-daemon
psd                          # generates ~/.config/psd/psd.conf
# set BROWSERS=(brave) in that file
systemctl --user enable --now psd.service
psd preview                  # verify
```
