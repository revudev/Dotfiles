#!/bin/bash

count=$(journalctl --since "24 hours ago" -q 2>/dev/null \
  | grep -ciE "pam_unix.*(authentication failure|failed)|sshd.*(Failed password|Invalid user|authentication failure)|sudo.*authentication failure|PAM.*authentication failure")

if [[ "$count" -eq 0 ]]; then
  echo "%{T2}%{F#98c379}󰷌%{F-}%{T-} 0"
elif [[ "$count" -lt 20 ]]; then
  echo "%{T2}%{F#e5c07b}󰷌%{F-}%{T-} ${count}"
else
  echo "%{T2}%{F#e06c75}󰷌%{F-}%{T-} ${count}"
fi
