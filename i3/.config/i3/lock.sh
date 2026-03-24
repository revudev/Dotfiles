#!/bin/bash

TEXT_PRIMARY="ffffffff"
TEXT_SECONDARY="ffffff88"

RING_IDLE="ffffff1a"
RING_VER="3fb950ff"
RING_WRONG="f85149ff"
KEYHL="64b5f6ff"
BSHL="8b949eff"

INSIDE="00000000"
INSIDE_VER="1a3a2200"
INSIDE_WRONG="3d0f0e00"

LINE="00000000"

i3lock \
  --blur=10 \
  --clock \
  --force-clock \
  --indicator \
  --no-modkey-text \
  \
  --time-str="%I:%M %p" \
  --time-color="$TEXT_PRIMARY" \
  --time-size=108 \
  --time-font="JetBrainsMono Nerd Font" \
  --time-pos="x+w/2:y+h/2-80" \
  \
  --date-str="%A, %d %B %Y" \
  --date-color="$TEXT_SECONDARY" \
  --date-size=17 \
  --date-font="JetBrainsMono Nerd Font" \
  --date-pos="x+w/2:y+h/2-16" \
  \
  --ind-pos="x+w/2:y+h/2+95" \
  --radius=42 \
  --ring-width=4.5 \
  --ring-color="$RING_IDLE" \
  --ringver-color="$RING_VER" \
  --ringwrong-color="$RING_WRONG" \
  --keyhl-color="$KEYHL" \
  --bshl-color="$BSHL" \
  --inside-color="$INSIDE" \
  --insidever-color="$INSIDE_VER" \
  --insidewrong-color="$INSIDE_WRONG" \
  --line-color="$LINE" \
  --separator-color="$LINE" \
  \
  --verif-text="" \
  --wrong-text="" \
  --noinput-text="" \
  --lock-text="" \
  --lockfailed-text=""
