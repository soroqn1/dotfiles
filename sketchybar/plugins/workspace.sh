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
STATE_FILE="$STATE_DIR/state.json"
[ -f "$STATE_FILE" ] || echo '{"focused":1,"recent":{},"apps":{}}' > "$STATE_FILE"

# Acquire file lock to serialize concurrent updates
LOCK_DIR="$STATE_DIR/.lock"
for ((i=0; i<40; i++)); do
  if mkdir "$LOCK_DIR" 2>/dev/null; then
    break
  fi
  sleep 0.005
done
if [ "$i" -ge 40 ]; then
  rmdir "$LOCK_DIR" 2>/dev/null || true
  mkdir "$LOCK_DIR" 2>/dev/null || true
fi
trap 'rmdir "$LOCK_DIR" 2>/dev/null' EXIT

SPACE_INFO=$(defaults read com.apple.spaces SpacesDisplayConfiguration 2>/dev/null | awk '
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
END { print (total ? total : 1) " " (curr ? curr : 1) }
')
read -r TOTAL_SPACES FALLBACK_FOCUSED <<< "$SPACE_INFO"

FRONT_APP=""
if [ -z "$SENDER" ] || [ "$SENDER" = "space_change" ]; then
  FRONT_APP=$(lsappinfo info -only name -app "$(lsappinfo front 2>/dev/null)" 2>/dev/null | cut -d'"' -f4)
fi

# Dynamic max icons based on total active spaces
if [ "${TOTAL_SPACES:-1}" -le 4 ]; then
  MAX_ICONS=3
elif [ "${TOTAL_SPACES:-1}" -le 6 ]; then
  MAX_ICONS=2
else
  MAX_ICONS=1
fi

OUT=$(jq -r -n \
  --slurpfile state_arr "$STATE_FILE" \
  --arg sender "$SENDER" \
  --arg info "$INFO" \
  --arg fallback_focused "${FALLBACK_FOCUSED:-1}" \
  --arg front_app "$FRONT_APP" \
  --argjson max_icons "$MAX_ICONS" \
  '
  ["loginwindow", "WindowServer", "Dock", "SystemUIServer", "ControlCenter", "NotificationCenter", "Spotlight", "universalaccessd"] as $sys |
  (($state_arr[0] // {}) | if type == "object" then . else {} end) as $st |
  ($st + {
    "focused": ($st.focused // ($fallback_focused | tonumber) // 1),
    "recent": ($st.recent // {}),
    "apps": ($st.apps // {})
  }) as $state |
  ($info | try fromjson catch $info) as $pinfo |
  (if $sender == "space_change" then
     ($pinfo."display-1" // ($pinfo | try (to_entries[0].value) catch null) // $state.focused)
   else
     $state.focused
   end | tonumber) as $new_focused |
  ($new_focused | tostring) as $fkey |
  (if ($front_app | length > 0) and ($sys | index($front_app) | not) then
     (if ($state.recent[$fkey] // "") == "" then
        $state.recent + { ($fkey): $front_app }
      else
        $state.recent
      end)
   else
     $state.recent
   end) as $base_recent |
  (if $sender == "front_app_switched" and ($info | length > 0) and ($sys | index($info) | not) then
     $base_recent + { ($fkey): $info }
   else
     $base_recent
   end) as $new_recent |
  (if ($front_app | length > 0) and ($sys | index($front_app) | not) then
     (if ($state.apps[$fkey] // {}) == {} then
        $state.apps + { ($fkey): { ($front_app): 1 } }
      else
        $state.apps
      end)
   else
     $state.apps
   end) as $base_apps |
  (if $sender == "space_windows_change" and ($pinfo | type == "object") and ($pinfo.space != null) then
     $base_apps + { ($pinfo.space | tostring): ($pinfo.apps // {}) }
   else
     $base_apps
   end) as $new_apps |
  {
    "focused": $new_focused,
    "recent": $new_recent,
    "apps": $new_apps
  } as $updated_state |
  ($updated_state | tojson),
  ([range(1; 11)] | map(
    . as $sid |
    ($sid | tostring) as $skey |
    ($updated_state.apps[$skey] // {}) as $raw_apps |
    (($raw_apps | to_entries | map(select(.value > 0)) | map(.key)) - $sys) as $raw |
    ($updated_state.recent[$skey] // "") as $rec |
    ($sid == $updated_state.focused) as $is_focused |
    (if ($raw | length) == 0 and $is_focused and $rec != "" then [$rec] else $raw end) as $all |
    (if ($all | length) > 1 then ($all - ["Finder"]) else $all end) as $filtered |
    (if ($rec != "" and ($filtered | index($rec))) then
       [$rec] + ($filtered - [$rec])
     else
       $filtered
     end) as $ordered |
    "\($sid)|\($is_focused)|\($ordered[0:$max_icons] | join(";"))"
  )[])
  ')

read -r NEW_STATE <<< "$OUT"
if [ -n "$NEW_STATE" ]; then
  echo "$NEW_STATE" > "$STATE_FILE.tmp" && mv "$STATE_FILE.tmp" "$STATE_FILE"
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

ARGS=()
while IFS="|" read -r sid is_active apps_str; do
  [ -z "$sid" ] && continue
  icons=()
  if [ -n "$apps_str" ]; then
    IFS=";" read -ra apps <<< "$apps_str"
    for app in "${apps[@]}"; do
      if [ -n "$app" ]; then
        icon=$(get_icon "$app")
        [ -n "$icon" ] && icons+=("$icon")
      fi
    done
  fi
  label_str="${icons[*]}"

  if [ "$is_active" = "true" ]; then
    if [ -n "$label_str" ]; then
      ARGS+=(
        --set "space.$sid"
        icon.color=0xffffffff
        icon.padding_left=8
        icon.padding_right=4
        label="$label_str"
        label.color=0xffffffff
        label.padding_left=4
        label.padding_right=8
        label.drawing=on
        background.color=0x38ffffff
        background.border_color=0x55ffffff
        background.border_width=1
        background.drawing=on
      )
    else
      ARGS+=(
        --set "space.$sid"
        icon.color=0xffffffff
        icon.padding_left=8
        icon.padding_right=8
        label.drawing=off
        background.color=0x38ffffff
        background.border_color=0x55ffffff
        background.border_width=1
        background.drawing=on
      )
    fi
  else
    if [ -n "$label_str" ]; then
      ARGS+=(
        --set "space.$sid"
        icon.color=0xd0ffffff
        icon.padding_left=8
        icon.padding_right=4
        label="$label_str"
        label.color=0xd0ffffff
        label.padding_left=4
        label.padding_right=8
        label.drawing=on
        background.color=0x14ffffff
        background.border_color=0x20ffffff
        background.border_width=1
        background.drawing=on
      )
    else
      ARGS+=(
        --set "space.$sid"
        icon.color=0xd0ffffff
        icon.padding_left=8
        icon.padding_right=8
        label.drawing=off
        background.color=0x14ffffff
        background.border_color=0x20ffffff
        background.border_width=1
        background.drawing=on
      )
    fi
  fi
done < <(tail -n +2 <<< "$OUT")

if [ "${#ARGS[@]}" -gt 0 ]; then
  sketchybar "${ARGS[@]}"
fi
