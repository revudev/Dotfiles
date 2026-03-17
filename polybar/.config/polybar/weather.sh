#!/bin/bash

CONFIG_FILE="${XDG_CONFIG_HOME:-$HOME/.config}/polybar/weather.conf"
if [ -f "$CONFIG_FILE" ]; then
  source "$CONFIG_FILE"
fi

LAT="${WEATHER_LAT:-xx.xxxx}"
LON="${WEATHER_LON:-xx.xxxx}"

for i in 1 2 3; do
  WEATHER_JSON=$(curl -sf --max-time 5 "https://api.open-meteo.com/v1/forecast?latitude=${LAT}&longitude=${LON}&current_weather=true" 2>/dev/null)
  [ -n "$WEATHER_JSON" ] && break
  sleep 3
done

if echo "$WEATHER_JSON" | grep -q "error" || [ -z "$WEATHER_JSON" ]; then
  echo "..."
  exit 0
fi

TEMP=$(echo "$WEATHER_JSON" | jq -r '.current_weather.temperature' | awk '{print int($1+0.5)}')
CODE=$(echo "$WEATHER_JSON" | jq -r '.current_weather.weathercode')

ICON=""
case "$CODE" in
  0|1|2|3)
    HOUR=$(date +%H)
    if [ "$HOUR" -ge 19 ] || [ "$HOUR" -lt 7 ]; then
      ICON=" "
    else
      ICON=" "
    fi
    ;;
  45|48)
    ICON=" "
    ;;
  51|53|55|56|57|61|63|65|66|67|80|81|82)
    ICON=" "
    ;;
  71|73|75|77|85|86)
    ICON=" "
    ;;
  95|96|99)
    ICON=" "
    ;;
  *)
    ICON=""
    ;;
esac

echo "${ICON}${TEMP}°C"
