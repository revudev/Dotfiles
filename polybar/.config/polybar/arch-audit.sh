#!/bin/bash

command -v arch-audit &>/dev/null || { echo "%{F#e06c75}󰒃 no arch-audit%{F-}"; exit 0; }

check_online() {
  if command -v nmcli &>/dev/null; then
    local state
    state=$(nmcli networking connectivity 2>/dev/null)
    [[ "$state" == "full" || "$state" == "limited" ]]
  else
    curl -sf --max-time 5 https://security.archlinux.org/json -o /dev/null 2>/dev/null
  fi
}

check_online || { echo "%{F#707880}󰒃 offline%{F-}"; exit 0; }

all=$(arch-audit 2>&1)

if [[ -z "$all" ]]; then
  echo "%{F#98c379}󰙔 $(pacman -Q 2>/dev/null | wc -l)%{F-}"
  exit 0
fi

build_details() {
  local out="$1" details=""
  local critical high medium low unknown
  critical=$(grep -ic "critical risk" <<< "$out")
  high=$(grep -ic "high risk" <<< "$out")
  medium=$(grep -ic "medium risk" <<< "$out")
  low=$(grep -ic "low risk" <<< "$out")
  unknown=$(grep -ic "unknown risk" <<< "$out")
  [[ $critical -gt 0 ]] && details+="%{F#ff00ff}${critical}%{F-}"
  [[ $high -gt 0 ]]     && details+="%{F#cc6666}${high}%{F-}"
  [[ $medium -gt 0 ]]   && details+="%{F#e5c07b}${medium}%{F-}"
  [[ $low -gt 0 ]]      && details+="%{F#98c379}${low}%{F-}"
  [[ $unknown -gt 0 ]]  && details+="%{F#abb2bf}${unknown}%{F-}"
  echo "$details"
}

fixable=$(arch-audit -u 2>&1)

if [[ -n "$fixable" ]]; then
  echo "%{T2}%{F#e06c75}󰒃%{F-}%{T-} $(build_details "$fixable")"
else
  echo "%{T2}%{F#98c379}󰒃%{F-}%{T-} $(build_details "$all")"
fi
