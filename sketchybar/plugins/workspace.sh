#!/usr/bin/env bash

STATE_DIR="/tmp/sketchybar_native_spaces"
mkdir -p "$STATE_DIR"

# Click handler: instant 0ms switch via Yabai SA
if [ "$1" = "click" ]; then
  TARGET_SID="${2:-$SID}"
  [ -z "$TARGET_SID" ] && exit 0

  OLD_FOCUSED=$(cat "$STATE_DIR/focused" 2>/dev/null || echo 1)
  if [ "$TARGET_SID" != "$OLD_FOCUSED" ]; then
    echo "$TARGET_SID" > "$STATE_DIR/focused"
    sketchybar \
      --set "space.$OLD_FOCUSED" background.drawing=off icon.color=0x55ffffff \
      --set "space.$TARGET_SID" background.drawing=on background.color=0x25ffffff background.border_width=0 background.height=22 background.corner_radius=6 icon.color=0xffffffff
  fi

  yabai -m space --focus "$TARGET_SID" 2>/dev/null || true
  exit 0
fi

# Instant space switch (<5ms)
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
      --set "space.$OLD_FOCUSED" background.drawing=off icon.color=0x55ffffff \
      --set "space.$FOCUSED" background.drawing=on background.color=0x25ffffff background.border_width=0 background.height=22 background.corner_radius=6 icon.color=0xffffffff
  else
    sketchybar \
      --set "space.$FOCUSED" background.drawing=on background.color=0x25ffffff background.border_width=0 background.height=22 background.corner_radius=6 icon.color=0xffffffff
  fi
  exit 0
fi

# Initial sync
FOCUSED=$(yabai -m query --spaces --space 2>/dev/null | jq -r .index // 1)
[ -z "$FOCUSED" ] && FOCUSED=1
echo "$FOCUSED" > "$STATE_DIR/focused"

ARGS=()
for sid in {1..10}; do
  if [ "$sid" -eq "$FOCUSED" ]; then
    ARGS+=(
      --set "space.$sid"
      icon.color=0xffffffff
      background.drawing=on
      background.color=0x25ffffff
      background.border_width=0
      background.height=22
      background.corner_radius=6
    )
  else
    ARGS+=(
      --set "space.$sid"
      icon.color=0x55ffffff
      background.drawing=off
    )
  fi
done
sketchybar "${ARGS[@]}"
