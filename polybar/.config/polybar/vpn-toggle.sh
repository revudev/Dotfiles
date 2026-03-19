#!/bin/bash

available=$(sudo find /etc/wireguard -name "*.conf" 2>/dev/null | xargs -I{} basename {} .conf)

if [ -z "$available" ]; then
  notify-send "VPN" "No WireGuard configs found in /etc/wireguard/"
  exit 1
fi

active=$(sudo wg show interfaces 2>/dev/null)

menu=""
while IFS= read -r iface; do
  if echo "$active" | grep -qw "$iface"; then
    menu+="󰦝 $iface\n"
  else
    menu+="󰦞 $iface\n"
  fi
done <<< "$available"

chosen=$(printf "%b" "$menu" | rofi -dmenu -i -p " VPN")
[ -z "$chosen" ] && exit 0

iface=$(echo "$chosen" | awk '{print $2}')

if echo "$active" | grep -qw "$iface"; then
  sudo wg-quick down "$iface"
  notify-send -a "󰦞 WireGuard" "Disconnected from $iface"
else
  sudo wg-quick up "$iface"
  notify-send -a "󰦝 WireGuard" "Connected to $iface"
fi
