#!/bin/bash

NET_COLOR="#81a2be"
STATE="/tmp/.polybar_net_state"

WIFI_IF=$(ip -br link show | awk '/^wl/ && / UP /{print $1; exit}')
ETH_IF=$(ip -br link show | awk '/^(en|eth)/ && / UP /{print $1; exit}')

if [[ -n "$WIFI_IF" ]]; then
  ICON="󰤨"
  IF="$WIFI_IF"
elif [[ -n "$ETH_IF" ]]; then
  ICON="󰈀"
  IF="$ETH_IF"
else
  echo "%{F#707880}󰤭%{F-}"
  exit 0
fi

RX_PATH="/sys/class/net/$IF/statistics/rx_bytes"
[[ ! -f "$RX_PATH" ]] && echo "%{F${NET_COLOR}}${ICON}%{F-}" && exit 0

read -r CURR_RX < "$RX_PATH"
printf -v NOW '%(%s)T' -1
SPEED_LABEL=""

if [[ -f "$STATE" ]]; then
  IFS=' ' read -r PREV_RX PREV_TIME PREV_IF < "$STATE"
  if [[ "$PREV_IF" == "$IF" ]]; then
    ELAPSED=$(( NOW - PREV_TIME ))
    if [[ "$ELAPSED" -gt 0 && "$CURR_RX" -ge "$PREV_RX" ]]; then
      SPEED_KB=$(( (CURR_RX - PREV_RX) / 1024 / ELAPSED ))
      if [[ "$SPEED_KB" -ge 1024 ]]; then
        SPEED_MB=$(( SPEED_KB / 1024 ))
        SPEED_LABEL=" ${SPEED_MB}M"
      else
        SPEED_LABEL=" ${SPEED_KB}K"
      fi
    fi
  fi
fi

echo "$CURR_RX $NOW $IF" > "$STATE"
echo "%{F${NET_COLOR}}${ICON}%{F-}${SPEED_LABEL}"
