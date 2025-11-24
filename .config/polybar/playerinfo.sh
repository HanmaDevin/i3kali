#!/bin/bash

# Icon map
declare -A icons=(
  ["default"]=""
  ["mpv"]=""
  ["chromium"]=""
  ["spotify"]=""
)

# Truncate text
truncate() {
  local text="$1"
  local maxlen="$2"
  [[ ${#text} -le $maxlen ]] && echo "$text" || echo "${text:0:maxlen}…"
}

# Get player metadata
players=($(playerctl -l 2>/dev/null | grep -o -P "^\w+"))
player=""
for p in "${players[@]}"; do
  status=$(playerctl --player="$p" status 2>/dev/null)
  if [[ "$status" == "Playing" ]]; then
    player="$p"
    break
  fi
done

if [[ -z "$player" ]]; then
  echo "Nothing Playing"
  exit 0
fi

status=$(playerctl --player=$player status 2>/dev/null)
artist=$(playerctl --player=$player metadata artist 2>/dev/null)
title=$(playerctl --player=$player metadata title 2>/dev/null)

icon="${icons[$player]:-${icons["default"]}}"

# Truncate artist and title to 10 chars
artist=$(truncate "$artist" 15)
title=$(truncate "$title" 15)

if [[ "$status" == "Playing" ]]; then
  echo "$icon $title - $artist"
fi
