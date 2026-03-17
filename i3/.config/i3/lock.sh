#!/bin/bash

TEXT_PRIMARY="e6edf3ff"
TEXT_SECONDARY="8b949eff"
RING_COLOR="21262daa"
RING_VER_COLOR="3fb950ff"
RING_WRONG_COLOR="f85149ff"
KEYHL_COLOR="58a6ffff"
BSHL_COLOR="da3633ff"
INSIDE_COLOR="0d111700"
LINE_COLOR="00000000"

i3lock \
  --blur=9 \
  --clock \
  --force-clock \
  --indicator \
  --no-modkey-text \
  \
  --time-str="%H:%M" \
  --time-color="$TEXT_PRIMARY" \
  --time-size=96 \
  --time-font="JetBrainsMono Nerd Font" \
  --time-pos="x+w/2:y+h/2-100" \
  \
  --date-str="%A, %d %B %Y" \
  --date-color="$TEXT_SECONDARY" \
  --date-size=16 \
  --date-font="JetBrainsMono Nerd Font" \
  --date-pos="x+w/2:y+h/2-52" \
  \
  --greeter-text="Introduce tu contraseña" \
  --greeter-color="$TEXT_SECONDARY" \
  --greeter-size=13 \
  --greeter-font="JetBrainsMono Nerd Font" \
  --greeter-pos="x+w/2:y+h/2+148" \
  \
  --ind-pos="x+w/2:y+h/2+70" \
  --radius=36 \
  --ring-width=4.0 \
  --ring-color="$RING_COLOR" \
  --ringver-color="$RING_VER_COLOR" \
  --ringwrong-color="$RING_WRONG_COLOR" \
  --keyhl-color="$KEYHL_COLOR" \
  --bshl-color="$BSHL_COLOR" \
  --inside-color="$INSIDE_COLOR" \
  --insidever-color="$INSIDE_COLOR" \
  --insidewrong-color="$INSIDE_COLOR" \
  --line-color="$LINE_COLOR" \
  --separator-color="$LINE_COLOR" \
  \
  --verif-text="" \
  --wrong-text="" \
  --noinput-text="" \
  --lock-text="" \
  --lockfailed-text=""
