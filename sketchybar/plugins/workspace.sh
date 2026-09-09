#!/usr/bin/env bash

STATE_DIR="/tmp/sketchybar_native_spaces"
mkdir -p "$STATE_DIR"

if [ "$1" = "click" ]; then
  TARGET_SID="${2:-$SID}"
  OLD_FOCUSED=$(cat "$STATE_DIR/focused" 2>/dev/null || echo 1)
  if [ "$TARGET_SID" != "$OLD_FOCUSED" ]; then
    echo "$TARGET_SID" > "$STATE_DIR/focused"
    sketchybar \
      --set "space.$OLD_FOCUSED" background.color=0x14ffffff background.border_color=0x20ffffff icon.color=0x90ffffff label.color=0x90ffffff icon.highlight=off \
      --set "space.$TARGET_SID" background.color=0x38ffffff background.border_color=0x55ffffff icon.color=0xffffffff label.color=0xffffffff icon.highlight=off
  fi

  # macOS Mission Control keycodes (^1..^0)
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
      --set "space.$OLD_FOCUSED" background.color=0x14ffffff background.border_color=0x20ffffff icon.color=0x90ffffff label.color=0x90ffffff icon.highlight=off \
      --set "space.$FOCUSED" background.color=0x38ffffff background.border_color=0x55ffffff icon.color=0xffffffff label.color=0xffffffff icon.highlight=off
  else
    sketchybar \
      --set "space.$FOCUSED" background.color=0x38ffffff background.border_color=0x55ffffff icon.color=0xffffffff label.color=0xffffffff icon.highlight=off
  fi
  exit 0
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
  [ -z "$app" ] && return
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

get_total_spaces() {
  local cache_file="$STATE_DIR/total_spaces"
  if [ ! -f "$cache_file" ] || [ $(($(date +%s) - $(stat -f %m "$cache_file" 2>/dev/null || echo 0))) -gt 10 ]; then
    local count
    count=$(defaults read com.apple.spaces SpacesDisplayConfiguration 2>/dev/null | awk '/Spaces =/ { in_spaces=1; next } in_spaces && /ManagedSpaceID/ { c++ } in_spaces && /\);/ { exit } END { print (c ? c : 1) }')
    echo "${count:-1}" > "$cache_file"
  fi
  cat "$cache_file"
}

update_space_label() {
  local sid="$1"
  local total_spaces
  total_spaces=$(get_total_spaces)

  local max_icons=1
  if [ "$total_spaces" -le 4 ]; then
    max_icons=3
  elif [ "$total_spaces" -le 6 ]; then
    max_icons=2
  fi

  local apps_json="{}"
  if [ -s "$STATE_DIR/apps_$sid" ]; then
    apps_json=$(cat "$STATE_DIR/apps_$sid")
    [ -z "$apps_json" ] && apps_json="{}"
  fi
  local recent=""
  [ -f "$STATE_DIR/recent_$sid" ] && recent=$(cat "$STATE_DIR/recent_$sid")

  local app_list
  app_list=$(jq -r -n \
    --argjson apps "$apps_json" \
    --arg recent "$recent" \
    --argjson max_icons "$max_icons" \
    '
    ["loginwindow", "WindowServer", "Dock", "SystemUIServer", "ControlCenter", "NotificationCenter", "Spotlight", "universalaccessd"] as $sys |
    (($apps | to_entries | map(select(.value > 0)) | map(.key)) - $sys) as $raw |
    (if ($raw | length) == 0 and $recent != "" and ($sys | index($recent) | not) then [$recent] else $raw end) as $all |
    (if ($all | length) > 1 then ($all - ["Finder"]) else $all end) as $filtered |
    (if ($recent != "" and ($filtered | index($recent))) then
       [$recent] + ($filtered - [$recent])
     else
       $filtered
     end) as $ordered |
    $ordered[0:$max_icons][]
    ' 2>/dev/null)

  local icons=()
  while IFS= read -r app; do
    if [ -n "$app" ]; then
      icon=$(get_icon "$app")
      [ -n "$icon" ] && icons+=("$icon")
    fi
  done <<< "$app_list"

  local label_str="${icons[*]}"
  if [ -n "$label_str" ]; then
    sketchybar --set "space.$sid" \
      icon.padding_left=8 \
      icon.padding_right=4 \
      label="$label_str" \
      label.padding_left=4 \
      label.padding_right=8 \
      label.drawing=on
  else
    sketchybar --set "space.$sid" \
      icon.padding_left=8 \
      icon.padding_right=8 \
      label.drawing=off
  fi
}

if [ "$SENDER" = "front_app_switched" ]; then
  APP="$INFO"
  case "$APP" in
    ""|loginwindow|WindowServer|Dock|SystemUIServer|ControlCenter|NotificationCenter|Spotlight|universalaccessd)
      exit 0
      ;;
  esac

  FOCUSED=$(cat "$STATE_DIR/focused" 2>/dev/null || echo 1)
  OLD_APP=$(cat "$STATE_DIR/recent_$FOCUSED" 2>/dev/null || echo "")
  [ "$APP" = "$OLD_APP" ] && exit 0
  echo "$APP" > "$STATE_DIR/recent_$FOCUSED"

  update_space_label "$FOCUSED"
  exit 0
fi

if [ "$SENDER" = "space_windows_change" ]; then
  EVENT_SPACE=$(jq -r '.space // empty' <<< "$INFO" 2>/dev/null)
  [ -z "$EVENT_SPACE" ] && exit 0

  APPS_JSON=$(jq -c '.apps // {}' <<< "$INFO" 2>/dev/null)
  OLD_APPS_JSON=$(cat "$STATE_DIR/apps_$EVENT_SPACE" 2>/dev/null || echo "")
  [ "$APPS_JSON" = "$OLD_APPS_JSON" ] && exit 0
  echo "$APPS_JSON" > "$STATE_DIR/apps_$EVENT_SPACE"

  update_space_label "$EVENT_SPACE"
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

FRONT_APP=$(lsappinfo info -only name -app "$(lsappinfo front 2>/dev/null)" 2>/dev/null | cut -d'"' -f4)
if [ -n "$FRONT_APP" ]; then
  echo "$FRONT_APP" > "$STATE_DIR/recent_${FOCUSED:-1}"
fi

ARGS=()
for sid in {1..10}; do
  if [ "$sid" -eq "${FOCUSED:-1}" ]; then
    ARGS+=(
      --set "space.$sid"
      icon.color=0xffffffff
      icon.highlight_color=0xffffffff
      icon.highlight=off
      label.color=0xffffffff
      label.highlight_color=0xffffffff
      label.highlight=off
      background.color=0x38ffffff
      background.border_color=0x55ffffff
      background.border_width=1
      background.drawing=on
    )
  else
    ARGS+=(
      --set "space.$sid"
      icon.color=0x90ffffff
      icon.highlight_color=0xffffffff
      icon.highlight=off
      label.color=0x90ffffff
      label.highlight_color=0xffffffff
      label.highlight=off
      background.color=0x14ffffff
      background.border_color=0x20ffffff
      background.border_width=1
      background.drawing=on
    )
  fi
done
sketchybar "${ARGS[@]}"

for sid in {1..10}; do
  update_space_label "$sid"
done
