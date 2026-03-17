#!/bin/bash

TIMER_COLOR="#e5c07b"
STATE_FILE="/tmp/.polybar_timer_state"
DURATION=7200  

show() {
    if [ ! -f "$STATE_FILE" ]; then
        echo "%{F${TIMER_COLOR}}󱎫 2:00:00%{F-}"
        exit 0
    fi

    START=$(cat "$STATE_FILE")
    NOW=$(date +%s)
    REMAINING=$(( DURATION - (NOW - START) ))

    if [ "$REMAINING" -le 0 ]; then
        rm -f "$STATE_FILE"
        dunstify -u critical -i dialog-information -t 0 \
            "󱎫 Temporizador" "¡Toma un descanso! Llevas 2 horas trabajando."
        echo "%{F${TIMER_COLOR}}󱎫 2:00:00%{F-}"
        exit 0
    fi

    H=$(( REMAINING / 3600 ))
    M=$(( (REMAINING % 3600) / 60 ))
    S=$(( REMAINING % 60 ))

    printf "%%{F${TIMER_COLOR}}󱎫 %d:%02d:%02d%%{F-}\n" "$H" "$M" "$S"
}

toggle() {
    if [ -f "$STATE_FILE" ]; then
        rm -f "$STATE_FILE"  
    else
        echo "$(date +%s)" > "$STATE_FILE"  
    fi
}

case "$1" in
    toggle) toggle ;;
    *)      show   ;;
esac
