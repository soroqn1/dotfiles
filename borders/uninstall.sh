#!/usr/bin/env sh

echo "Stopping and disabling borders..."
brew services stop borders 2>/dev/null
killall borders 2>/dev/null
pkill -f borders_layout_daemon 2>/dev/null

sketchybar --remove borders_sync 2>/dev/null

echo "Done! Borders disabled and Sketchybar cleaned up."
