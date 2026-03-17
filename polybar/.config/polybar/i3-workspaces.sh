#!/bin/bash

COLOR_FOCUSED="#81a2be"
COLOR_UNFOCUSED="#c5c8c6"
COLOR_EMPTY="#444444"

ICONS=("" "" "" "" "" "" "")

update_workspaces() {
  local ws_json=$(i3-msg -t get_workspaces)
  local out=""

  for i in {1..6}; do
    local is_focused=$(echo "$ws_json" | jq -e ".[] | select(.num == $i and .focused == true)" > /dev/null && echo "true" || echo "false")
    local exists=$(echo "$ws_json" | jq -e ".[] | select(.num == $i)" > /dev/null && echo "true" || echo "false")
    local icon="${ICONS[$i]}"

    if [ "$i" -eq 5 ]; then
      out+="%{F${COLOR_UNFOCUSED}}|  %{F-}"
    fi
    
    if [ "$is_focused" = "true" ]; then
      out+="%{A1:i3-msg workspace $i:}%{F$COLOR_FOCUSED}%{T2}$icon%{T-}%{F-}%{A}  "
    elif [ "$exists" = "true" ]; then
      out+="%{A1:i3-msg workspace $i:}%{F$COLOR_UNFOCUSED}%{T2}$icon%{T-}%{F-}%{A}  "
    else
      out+="%{A1:i3-msg workspace $i:}%{F$COLOR_EMPTY}%{T2}$icon%{T-}%{F-}%{A}  "
    fi
  done

  echo "$out"
}

update_workspaces
i3-msg -t subscribe -m '["workspace"]' | while read -r event; do
  update_workspaces
done
