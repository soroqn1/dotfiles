#!/usr/bin/env bash

export PATH="/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"

# If no PID was passed from yabai signal, exit
if [ -z "$YABAI_PROCESS_ID" ]; then
  exit 0
fi

# Find the first valid, non-minimized standard window for this process
wid=$(yabai -m query --windows | jq -r \
  "[.[] | select(.pid == $YABAI_PROCESS_ID and .[\"is-minimized\"] == false and .subrole != \"AXDialog\" and .subrole != \"AXSystemDialog\")] | .[0].id // empty")

# If an open window exists, switch to its space and focus it
if [ -n "$wid" ]; then
  target_space=$(yabai -m query --windows --window "$wid" | jq -r .space)
  current_space=$(yabai -m query --spaces --space | jq -r .index)
  if [ -n "$target_space" ] && [ "$target_space" != "$current_space" ]; then
    yabai -m space --focus "$target_space"
  fi
  yabai -m window --focus "$wid"
fi
