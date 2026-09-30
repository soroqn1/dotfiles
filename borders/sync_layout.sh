#!/usr/bin/env bash

# Query current keyboard layout
LAYOUT=$(defaults read ~/Library/Preferences/com.apple.HIToolbox.plist AppleSelectedInputSources 2>/dev/null | awk -F'= ' '/"KeyboardLayout Name" =/ {gsub(/[" ;]/, "", $2); print $2}')

case "$LAYOUT" in
  *Russian*|*ru*|*Ru*)
    # RU: Lavender to Light Amethyst (Frieren deep-pine-sea palette 5 & 13)
    COLOR="gradient(top_left=0xcc8d9bf4,bottom_right=0xccaeb8ff)"
    ;;
  *Ukrainian*|*ua*)
    # UA: Lake Blue to Water Lily Gold (Frieren deep-pine-sea palette 12 & 3)
    COLOR="gradient(top_left=0xcc74bad9,bottom_right=0xccf3c36d)"
    ;;
  *)
    # EN: Foreground Mist to Pine Green (Frieren deep-pine-sea foreground & palette 10)
    COLOR="gradient(top_left=0xccffffff,bottom_right=0xcc86d1a5)"
    ;;
esac

borders active_color="$COLOR" 2>/dev/null || true
