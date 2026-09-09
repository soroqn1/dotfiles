#!/usr/bin/env bash

if [ "$1" = "click" ]; then
  TARGET_SID="${2:-$SID}"
  # macOS Mission Control keycodes for 1..10 (^1 .. ^0)
  case "$TARGET_SID" in
    1) KEY=18 ;; 2) KEY=19 ;; 3) KEY=20 ;; 4) KEY=21 ;; 5) KEY=23 ;;
    6) KEY=22 ;; 7) KEY=26 ;; 8) KEY=28 ;; 9) KEY=25 ;; 10) KEY=29 ;;
  esac
  if [ -n "$KEY" ]; then
    osascript -e "tell application \"System Events\" to key code $KEY using control down" 2>/dev/null
  fi
  exit 0
fi

STATE_DIR="/tmp/sketchybar_native_spaces"
mkdir -p "$STATE_DIR"

NAME="${NAME:-space.$1}"
SID="${SID:-${NAME#space.}}"

if [ "$SENDER" = "space_windows_change" ]; then
  event_space=$(echo "$INFO" | jq -r '.space // empty' 2>/dev/null)
  if [ -n "$event_space" ] && [ "$event_space" != "$SID" ]; then
    exit 0
  fi
  new_app=$(echo "$INFO" | jq -r '(.apps | keys) as $k | ($k - ["Finder"] | .[0]) // $k[0] // empty' 2>/dev/null)
  if [ -n "$new_app" ] && [ "$new_app" != "null" ]; then
    echo "$new_app" > "$STATE_DIR/app_$SID"
    APP="$new_app"
  else
    rm -f "$STATE_DIR/app_$SID"
    APP=""
  fi
elif [ "$SENDER" = "front_app_switched" ]; then
  if [ "$SELECTED" = "true" ]; then
    APP="$INFO"
    echo "$APP" > "$STATE_DIR/app_$SID"
  else
    exit 0
  fi
fi

if [ -z "$APP" ] && [ -f "$STATE_DIR/app_$SID" ]; then
  APP=$(cat "$STATE_DIR/app_$SID" 2>/dev/null)
fi

if [ -z "$APP" ] && [ "$SELECTED" = "true" ]; then
  APP=$(lsappinfo info -only name -app "$(lsappinfo front 2>/dev/null)" 2>/dev/null | cut -d'"' -f4)
  [ -n "$APP" ] && echo "$APP" > "$STATE_DIR/app_$SID"
fi

declare -A ICON_MAP=(
  # Terminals & Editors
  ["Ghostty"]=":ghostty:"
  ["Alacritty"]=":alacritty:"
  ["kitty"]=":kitty:"
  ["WezTerm"]=":wezterm:"
  ["iTerm"]=":iterm:"
  ["iTerm2"]=":iterm:"
  ["Terminal"]=":terminal:"
  ["Neovide"]=":neovide:"
  ["neovide"]=":neovide:"
  ["MacVim"]=":vim:"
  ["VimR"]=":vim:"
  ["Emacs"]=":emacs:"
  ["Code"]=":code:"
  ["Code - Insiders"]=":code:"
  ["Visual Studio Code"]=":code:"
  ["Cursor"]=":cursor:"
  ["Zed"]=":zed:"
  ["Sublime Text"]=":sublime_text:"
  ["Xcode"]=":xcode:"
  ["IntelliJ IDEA"]=":idea:"
  ["PyCharm"]=":pycharm:"
  ["WebStorm"]=":web_storm:"
  ["GoLand"]=":goland:"
  ["DataGrip"]=":datagrip:"
  ["Rider"]=":rider:"
  ["Android Studio"]=":android_studio:"
  ["Godot"]=":godot:"

  # Browsers
  ["Dia"]=":dia:"
  ["dia"]=":dia:"
  ["company.thebrowser.dia"]=":dia:"
  ["Safari"]=":safari:"
  ["Safari Technology Preview"]=":safari:"
  ["Google Chrome"]=":google_chrome:"
  ["Google Chrome Canary"]=":google_chrome:"
  ["Chromium"]=":google_chrome:"
  ["Arc"]=":arc:"
  ["Brave Browser"]=":brave_browser:"
  ["Zen Browser"]=":zen_browser:"
  ["Zen"]=":zen_browser:"
  ["Firefox"]=":firefox:"
  ["Firefox Developer Edition"]=":firefox_developer_edition:"
  ["Firefox Nightly"]=":firefox_developer_edition:"
  ["LibreWolf"]=":libre_wolf:"
  ["Vivaldi"]=":vivaldi:"
  ["Microsoft Edge"]=":microsoft_edge:"
  ["Opera"]=":opera:"
  ["Tor Browser"]=":tor_browser:"
  ["Orion"]=":orion:"
  ["Yandex Browser"]=":yandex_browser:"
  ["Yandex"]=":yandex_browser:"
  ["Yandex Browser"]=":yandex_browser:"

  # Communication & Social
  ["Telegram"]=":telegram:"
  ["Discord"]=":discord:"
  ["Discord Canary"]=":discord:"
  ["Slack"]=":slack:"
  ["Messages"]=":messages:"
  ["Signal"]=":signal:"
  ["WhatsApp"]=":whats_app:"
  ["‎WhatsApp"]=":whats_app:"
  ["Element"]=":element:"
  ["Mattermost"]=":mattermost:"
  ["Zulip"]=":zulip:"
  ["Session"]=":session:"
  ["zoom.us"]=":zoom:"
  ["Zoom"]=":zoom:"
  ["Microsoft Teams"]=":microsoft_teams:"
  ["Microsoft Teams (work or school)"]=":microsoft_teams:"
  ["Skype"]=":skype:"
  ["WeChat"]=":wechat:"
  ["FaceTime"]=":face_time:"
  ["Mail"]=":mail:"
  ["Canary Mail"]=":mail:"
  ["Superhuman"]=":mail:"
  ["Thunderbird"]=":thunderbird:"
  ["Spark"]=":spark:"
  ["Proton Mail"]=":proton_mail:"
  ["Microsoft Outlook"]=":microsoft_outlook:"

  # Productivity & Notes
  ["Obsidian"]=":obsidian:"
  ["Notion"]=":notion:"
  ["Notion Calendar"]=":calendar:"
  ["Notes"]=":notes:"
  ["Reminders"]=":reminders:"
  ["Calendar"]=":calendar:"
  ["Fantastical"]=":calendar:"
  ["Cron"]=":calendar:"
  ["Things"]=":things:"
  ["Todoist"]=":todoist:"
  ["TickTick"]=":tick_tick:"
  ["Linear"]=":linear:"
  ["Trello"]=":trello:"
  ["ClickUp"]=":click_up:"
  ["Miro"]=":miro:"
  ["Freeform"]=":freeform:"
  ["Logseq"]=":logseq:"
  ["Bear"]=":bear:"
  ["Anytype"]=":anytype:"
  ["Typora"]=":text:"
  ["ChatGPT"]=":openai:"
  ["Claude"]=":claude:"
  ["LM Studio"]=":lm_studio:"

  # Design & Media
  ["Figma"]=":figma:"
  ["Sketch"]=":sketch:"
  ["Adobe Photoshop"]=":photoshop:"
  ["Photoshop"]=":photoshop:"
  ["Adobe Illustrator"]=":illustrator:"
  ["Illustrator"]=":illustrator:"
  ["Adobe Lightroom"]=":lightroom:"
  ["Affinity Designer"]=":affinity_designer:"
  ["Affinity Photo"]=":affinity_photo:"
  ["Blender"]=":blender:"
  ["DaVinci Resolve"]=":davinciresolve:"
  ["Final Cut Pro"]=":final_cut_pro:"
  ["Music"]=":music:"
  ["Spotify"]=":spotify:"
  ["Apple Music"]=":music:"
  ["Yandex Music"]=":yandex_music:"
  ["TIDAL"]=":tidal:"
  ["Deezer"]=":deezer:"
  ["VLC"]=":vlc:"
  ["IINA"]=":iina:"
  ["mpv"]=":mpv:"
  ["QuickTime Player"]=":quicktime:"
  ["Podcasts"]=":podcasts:"
  ["OBS"]=":obsstudio:"

  # Utilities & Tools
  ["Finder"]=":finder:"
  ["System Settings"]=":gear:"
  ["System Preferences"]=":gear:"
  ["Activity Monitor"]=":activity_monitor:"
  ["1Password"]=":one_password:"
  ["Bitwarden"]=":bit_warden:"
  ["KeePassXC"]=":kee_pass_x_c:"
  ["Docker"]=":docker:"
  ["Docker Desktop"]=":docker:"
  ["OrbStack"]=":orbstack:"
  ["Postman"]=":postman:"
  ["Insomnia"]=":insomnia:"
  ["TablePlus"]=":tableplus:"
  ["DBeaver"]=":dbeaver:"
  ["Sequel Ace"]=":sequel_ace:"
  ["Fork"]=":fork:"
  ["GitHub Desktop"]=":git_hub:"
  ["Tower"]=":tower:"
  ["Raycast"]=":raycast:"
  ["Calculator"]=":calculator:"
  ["Preview"]=":preview:"
  ["PDF Expert"]=":pdf_expert:"
  ["CleanMyMac X"]=":desktop:"
  ["Pearcleaner"]=":pearcleaner:"
  ["UTM"]=":utm:"
  ["Parallels Desktop"]=":parallels:"
  ["qBittorrent"]=":qbittorrent:"
)

# Resolve icon ligature with fallback matching
get_icon() {
  local app="$1"
  local icon="${ICON_MAP[$app]:-}"
  if [[ -z "$icon" ]]; then
    local lower="${app,,}"
    icon="${ICON_MAP[$lower]:-}"
    if [[ -z "$icon" ]]; then
      case "$lower" in
        *dia*) icon=":dia:" ;;
        *chrome*) icon=":google_chrome:" ;;
        *ghostty*) icon=":ghostty:" ;;
        *telegram*) icon=":telegram:" ;;
        *obsidian*) icon=":obsidian:" ;;
        *safari*) icon=":safari:" ;;
        *firefox*) icon=":firefox:" ;;
        *code*|*cursor*) icon=":code:" ;;
        *) icon=":default:" ;;
      esac
    fi
  fi
  echo "$icon"
}

icon=$([ -n "$APP" ] && get_icon "$APP" || echo "")

if [ "$SELECTED" = "true" ]; then
  if [ -n "$icon" ]; then
    sketchybar --set "$NAME" \
      icon.color=0xffffffff \
      icon.padding_left=8 \
      icon.padding_right=4 \
      label="$icon" \
      label.color=0xffffffff \
      label.padding_left=4 \
      label.padding_right=8 \
      label.drawing=on \
      background.color=0x38ffffff \
      background.border_color=0x55ffffff \
      background.border_width=1 \
      background.drawing=on
  else
    sketchybar --set "$NAME" \
      icon.color=0xffffffff \
      icon.padding_left=8 \
      icon.padding_right=8 \
      label.drawing=off \
      background.color=0x38ffffff \
      background.border_color=0x55ffffff \
      background.border_width=1 \
      background.drawing=on
  fi
else
  if [ -n "$icon" ]; then
    sketchybar --set "$NAME" \
      icon.color=0xd0ffffff \
      icon.padding_left=8 \
      icon.padding_right=4 \
      label="$icon" \
      label.color=0xd0ffffff \
      label.padding_left=4 \
      label.padding_right=8 \
      label.drawing=on \
      background.color=0x14ffffff \
      background.border_color=0x20ffffff \
      background.border_width=1 \
      background.drawing=on
  else
    sketchybar --set "$NAME" \
      icon.color=0xd0ffffff \
      icon.padding_left=8 \
      icon.padding_right=8 \
      label.drawing=off \
      background.color=0x14ffffff \
      background.border_color=0x20ffffff \
      background.border_width=1 \
      background.drawing=on
  fi
fi
