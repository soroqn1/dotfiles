#!/usr/bin/env bash

# ---------------------------------------------------------
# Yabai & Sketchybar Service & Layout Manager
# ---------------------------------------------------------

YABAI_PLIST="$HOME/Library/LaunchAgents/com.asmvik.yabai.plist"
SKETCHYBAR_PLIST="$HOME/Library/LaunchAgents/homebrew.mxcl.sketchybar.plist"

notify() {
  local title="$1"
  local message="$2"
  local sound="${3:-Pop}"

  osascript -e "display notification \"$message\" with title \"$title\" sound name \"$sound\"" 2>/dev/null &
}

is_yabai_running() {
  pgrep -x yabai >/dev/null 2>&1
}

start_yabai() {
  if [ -f "$YABAI_PLIST" ]; then
    launchctl bootstrap "gui/$(id -u)" "$YABAI_PLIST" 2>/dev/null || launchctl kickstart -k "gui/$(id -u)/com.asmvik.yabai" 2>/dev/null || true
  else
    yabai --start-service 2>/dev/null || yabai &
  fi
}

stop_yabai() {
  launchctl bootout "gui/$(id -u)/com.asmvik.yabai" 2>/dev/null || pkill -x yabai 2>/dev/null || true
}

start_sketchybar() {
  if ! pgrep -x sketchybar >/dev/null 2>&1; then
    if [ -f "$SKETCHYBAR_PLIST" ]; then
      launchctl bootstrap "gui/$(id -u)" "$SKETCHYBAR_PLIST" 2>/dev/null || true
    else
      sketchybar &
    fi
  else
    sketchybar --bar hidden=off 2>/dev/null || true
  fi
}

stop_sketchybar() {
  sketchybar --bar hidden=on 2>/dev/null || true
}

start_services() {
  start_yabai
  start_sketchybar
  notify "Tiling Environment" "🟢 Включен (Yabai, Sketchybar)" "Pop"
  echo "Yabai and Sketchybar started"
}

stop_services() {
  stop_yabai
  stop_sketchybar
  notify "Tiling Environment" "🔴 Выключен (плавающий режим)" "Tink"
  echo "Yabai and Sketchybar stopped"
}

toggle_service() {
  if is_yabai_running; then
    stop_services
  else
    start_services
  fi
}

toggle_layout() {
  if ! is_yabai_running; then
    start_services
    return
  fi

  local current_layout
  current_layout=$(yabai -m config layout 2>/dev/null)

  if [ "$current_layout" = "bsp" ]; then
    yabai -m config layout float
    notify "Yabai" "🟡 Режим Float (окна свободны)" "Tink"
    echo "Layout switched to float"
  else
    yabai -m config layout bsp
    notify "Yabai" "🟢 Режим BSP (тайлинг активен)" "Pop"
    echo "Layout switched to bsp"
  fi
}

show_status() {
  local yabai_stat="STOPPED"
  local sketchybar_stat="HIDDEN"

  if is_yabai_running; then
    local layout=""
    for _ in 1 2 3 4 5; do
      layout=$(yabai -m config layout 2>/dev/null) && [ -n "$layout" ] && break
      sleep 0.1
    done
    yabai_stat="RUNNING (layout: ${layout:-bsp})"
  fi

  if pgrep -x sketchybar >/dev/null 2>&1; then
    local hidden
    hidden=$(sketchybar --query bar 2>/dev/null | awk -F'"' '/"hidden":/ {print $4}')
    if [ "$hidden" != "on" ]; then
      sketchybar_stat="VISIBLE"
    fi
  fi

  echo "Yabai: $yabai_stat"
  echo "Sketchybar: $sketchybar_stat"
}

case "${1:-toggle}" in
  on|start)
    start_services
    ;;
  off|stop)
    stop_services
    ;;
  layout)
    toggle_layout
    ;;
  status)
    show_status
    ;;
  toggle|*)
    toggle_service
    ;;
esac
