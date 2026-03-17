#!/bin/bash

if ip -br a | grep -q -E 'tun|wg|tailscale|anyconnect'; then
  echo "%{T2}%{F#98c379}󰦝%{F-}%{T-}"
else
  echo "%{T2}%{F#e06c75}󰦞%{F-}%{T-}"
fi
