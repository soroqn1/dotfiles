#!/usr/bin/env bash
export PATH="/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"

app="${1:-Telegram}"
cur_space=$(yabai -m query --spaces --space 2>/dev/null | jq -r .index)
[ -z "$cur_space" ] && exit 0

wid=$(yabai -m query --windows 2>/dev/null | jq -r --arg a "$app" '[.[] | select(.app == $a)] | .[0].id // empty')
[ -z "$wid" ] && exit 0

win_space=$(yabai -m query --windows --window "$wid" 2>/dev/null | jq -r .space)
if [ -n "$win_space" ] && [ "$win_space" != "$cur_space" ]; then
    yabai -m window "$wid" --space "$cur_space"
    yabai -m window --focus "$wid"
fi

# Ensure standard centered size
if [ "$app" = "Telegram" ]; then
    yabai -m window "$wid" --grid 956:1470:188:113:1094:730 2>/dev/null || true
elif [ "$app" = "Finder" ]; then
    yabai -m window "$wid" --grid 956:1470:285:178:900:600 2>/dev/null || true
fi
