#!/bin/bash

count=$(journalctl --since "24 hours ago" -q 2>/dev/null \
  | grep -ciE "pam_unix.*(authentication failure|failed)|sshd.*(Failed password|Invalid user|authentication failure)|sudo.*authentication failure|PAM.*authentication failure")

if [[ "$count" -eq 0 ]]; then
  echo "%{F#98c379}󰷌 0%{F-}"
elif [[ "$count" -lt 20 ]]; then
  echo "%{F#e5c07b}󰷌 ${count}%{F-}"
else
  echo "%{F#e06c75}󰷌 ${count}%{F-}"
fi
