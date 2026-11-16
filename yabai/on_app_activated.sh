#!/usr/bin/env bash
export PATH="/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"

lock_file="/tmp/yabai_app_activate.pid"
if [ -f "$lock_file" ]; then
    old_pid=$(cat "$lock_file" 2>/dev/null)
    if [ -n "$old_pid" ] && kill -0 "$old_pid" 2>/dev/null; then
        exit 0
    fi
fi
echo "$$" > "$lock_file"
trap 'rm -f "$lock_file"' EXIT

pid="${YABAI_PROCESS_ID:-}"
[ -z "$pid" ] && exit 0

cur_space=$(yabai -m query --spaces --space 2>/dev/null | jq -r .index)
[ -z "$cur_space" ] && exit 0

# Find non-minimized windows for this PID
win_list=$(yabai -m query --windows 2>/dev/null | jq --arg pid "$pid" \
  '[.[] | select(.pid == ($pid | tonumber) and .["is-minimized"] == false)]')

[ -z "$win_list" ] || [ "$win_list" = "[]" ] && exit 0

app=$(echo "$win_list" | jq -r '.[0].app // empty')
[ -z "$app" ] && exit 0

# -------------------------------------------------------------
# Case 1: Scratchpad Apps (Telegram, Finder)
# Behavior: NEVER switch spaces. Bring window to user's current space!
# -------------------------------------------------------------
if [ "$app" = "Telegram" ] || [ "$app" = "Finder" ]; then
    wid=$(echo "$win_list" | jq -r '.[0].id // empty')
    is_visible=$(echo "$win_list" | jq -r '.[0]["is-visible"]')

    # If window was closed with Cmd+W (invisible), tell app to reopen
    if [ "$is_visible" != "true" ]; then
        osascript -e "tell application \"$app\" to reopen" 2>/dev/null || open -a "$app"
        sleep 0.1
        wid=$(yabai -m query --windows 2>/dev/null | jq -r --arg a "$app" '[.[] | select(.app == $a)] | .[0].id // empty')
    fi

    if [ -n "$wid" ]; then
        win_space=$(yabai -m query --windows --window "$wid" 2>/dev/null | jq -r .space)
        if [ "$win_space" != "$cur_space" ]; then
            yabai -m window "$wid" --space "$cur_space" 2>/dev/null || true
        fi
        yabai -m window --focus "$wid" 2>/dev/null || true

        if [ "$app" = "Telegram" ]; then
            yabai -m window "$wid" --grid 956:1470:188:113:1094:730 2>/dev/null || true
        elif [ "$app" = "Finder" ]; then
            yabai -m window "$wid" --grid 956:1470:285:178:900:600 2>/dev/null || true
        fi
    fi
    exit 0
fi

# -------------------------------------------------------------
# Case 2: Regular Apps (Zen, Ghostty, Zed, Obsidian, Prism Launcher, etc.)
# Behavior: 1-click switch to the space where the app is open!
# -------------------------------------------------------------
wid=$(echo "$win_list" | jq -r '[.[] | select(.subrole != "AXDialog" and .subrole != "AXSystemDialog")] | .[0].id // empty')
[ -z "$wid" ] && wid=$(echo "$win_list" | jq -r '.[0].id // empty')

if [ -n "$wid" ]; then
    win_space=$(yabai -m query --windows --window "$wid" 2>/dev/null | jq -r .space)
    if [ -n "$win_space" ] && [ "$win_space" != "$cur_space" ]; then
        yabai -m space --focus "$win_space" 2>/dev/null || true
        yabai -m window --focus "$wid" 2>/dev/null || true
    fi
fi
