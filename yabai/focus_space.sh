#!/usr/bin/env sh
SPACE="$1"
[ -z "$SPACE" ] && exit 0

yabai -m space --focus "$SPACE"
