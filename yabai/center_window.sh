#!/usr/bin/env bash
export PATH="/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"

win_info=$(yabai -m query --windows --window 2>/dev/null)
[ -z "$win_info" ] && exit 0

wid=$(echo "$win_info" | jq -r '.id')
ww=$(echo "$win_info" | jq -r '.frame.w' | cut -d. -f1)
wh=$(echo "$win_info" | jq -r '.frame.h' | cut -d. -f1)

disp_frame=$(yabai -m query --displays --display 2>/dev/null | jq -r '.frame | "\(.x) \(.y) \(.w) \(.h)"')
read -r dx dy dw dh <<< "$disp_frame"
dx=${dx%.*}
dy=${dy%.*}
dw=${dw%.*}
dh=${dh%.*}

if [ -n "$dw" ] && [ -n "$ww" ] && [ "$ww" -gt 0 ] && [ "$dw" -gt "$ww" ]; then
    cx=$(( dx + (dw - ww) / 2 ))
    cy=$(( dy + (dh - wh) / 2 ))
    yabai -m window "$wid" --move abs:$cx:$cy 2>/dev/null || true
fi
