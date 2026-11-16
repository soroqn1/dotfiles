#!/usr/bin/env bash

STATE_DIR="/tmp/sketchybar_native_spaces"
mkdir -p "$STATE_DIR"

if [ "$1" = "click" ]; then
  TARGET_SID="${2:-$SID}"
  OLD_FOCUSED=$(cat "$STATE_DIR/focused" 2>/dev/null || echo 1)
  if [ "$TARGET_SID" != "$OLD_FOCUSED" ]; then
    echo "$TARGET_SID" > "$STATE_DIR/focused"
    sketchybar \
      --set "space.$OLD_FOCUSED" background.drawing=off icon.color=0x75ffffff \
      --set "space.$TARGET_SID" background.drawing=on background.color=0x3affffff background.border_color=0x50ffffff background.border_width=1 background.height=20 background.corner_radius=5 icon.color=0xffffffff
  fi

  case "$TARGET_SID" in
    1) KEY=18 ;; 2) KEY=19 ;; 3) KEY=20 ;; 4) KEY=21 ;; 5) KEY=23 ;;
    6) KEY=22 ;; 7) KEY=26 ;; 8) KEY=28 ;; 9) KEY=25 ;; 10) KEY=29 ;;
  esac
  if [ -n "$KEY" ]; then
    osascript -e "tell application \"System Events\" to key code $KEY using control down" 2>/dev/null
  fi
  exit 0
fi

# Instant space switch (<10ms) without process overhead
if [ "$SENDER" = "space_change" ]; then
  FOCUSED="${INFO##*\"display-1\": }"
  FOCUSED="${FOCUSED%%\}*}"
  FOCUSED="${FOCUSED//[[:space:]]/}"
  [ -z "$FOCUSED" ] && exit 0

  OLD_FOCUSED=$(cat "$STATE_DIR/focused" 2>/dev/null || echo "")
  [ "$FOCUSED" = "$OLD_FOCUSED" ] && exit 0
  echo "$FOCUSED" > "$STATE_DIR/focused"

  if [ -n "$OLD_FOCUSED" ]; then
    sketchybar \
      --set "space.$OLD_FOCUSED" background.drawing=off icon.color=0x75ffffff \
      --set "space.$FOCUSED" background.drawing=on background.color=0x3affffff background.border_color=0x50ffffff background.border_width=1 background.height=20 background.corner_radius=5 icon.color=0xffffffff
  else
    sketchybar \
      --set "space.$FOCUSED" background.drawing=on background.color=0x3affffff background.border_color=0x50ffffff background.border_width=1 background.height=20 background.corner_radius=5 icon.color=0xffffffff
  fi
  exit 0
fi

# Initial startup / sync
FOCUSED=$(defaults read com.apple.spaces SpacesDisplayConfiguration 2>/dev/null | awk '
/Monitors =/ { in_monitors=1 }
in_monitors && /"Current Space"/ { in_curr=1 }
in_curr && /ManagedSpaceID =/ { curr_id=$3; gsub(";", "", curr_id); in_curr=0 }
in_monitors && /Spaces =/ { in_spaces=1 }
in_spaces && /ManagedSpaceID =/ {
  total++
  id=$3; gsub(";", "", id)
  if (id == curr_id) { curr=total }
}
in_spaces && /\);/ { exit }
END { print (curr ? curr : 1) }
')
echo "${FOCUSED:-1}" > "$STATE_DIR/focused"

ARGS=()
for sid in {1..10}; do
  if [ "$sid" -eq "${FOCUSED:-1}" ]; then
    ARGS+=(
      --set "space.$sid"
      icon.color=0xffffffff
      background.drawing=on
      background.color=0x3affffff
      background.border_color=0x50ffffff
      background.border_width=1
      background.height=20
      background.corner_radius=5
    )
  else
    ARGS+=(
      --set "space.$sid"
      icon.color=0x75ffffff
      background.drawing=off
    )
  fi
done
sketchybar "${ARGS[@]}"
