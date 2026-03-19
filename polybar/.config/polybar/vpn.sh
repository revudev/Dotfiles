#!/bin/bash

if sudo wg show interfaces | grep -q .; then
  echo "%{T2}%{F#98c379}󰦝%{F-}%{T-}"
else
  echo "%{T2}%{F#e06c75}󰦞%{F-}%{T-}"
fi
