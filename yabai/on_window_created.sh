#!/usr/bin/env bash
export PATH="/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"

wid="$YABAI_WINDOW_ID"
[ -z "$wid" ] && exit 0

# Route newly created windows to the current space under mouse
yabai -m window "$wid" --space mouse 2>/dev/null || true

# Check window details
win_info=$(yabai -m query --windows --window "$wid" 2>/dev/null)
[ -z "$win_info" ] && exit 0

subrole=$(echo "$win_info" | jq -r '.subrole // empty')
is_floating=$(echo "$win_info" | jq -r '.["is-floating"]')
app=$(echo "$win_info" | jq -r '.app // empty')

# Center modal dialogs and popups (e.g. Prism Launcher Modrinth dialog, AXDialog, etc.)
if [ "$subrole" = "AXDialog" ] || [ "$subrole" = "AXSystemDialog" ] || [ "$is_floating" = "true" ]; then
    case "$app" in
        "Telegram"|"Finder"|"Preview") exit 0 ;;
    esac

    ww=$(echo "$win_info" | jq -r '.frame.w // 0' | cut -d. -f1)
    wh=$(echo "$win_info" | jq -r '.frame.h // 0' | cut -d. -f1)

    if [ -z "$ww" ] || [ "$ww" -le 0 ]; then
        sleep 0.05
        win_info=$(yabai -m query --windows --window "$wid" 2>/dev/null)
        ww=$(echo "$win_info" | jq -r '.frame.w // 0' | cut -d. -f1)
        wh=$(echo "$win_info" | jq -r '.frame.h // 0' | cut -d. -f1)
    fi

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
fi
